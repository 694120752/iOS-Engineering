
#import "DTMDataBaseManager.h"
#import "DTMStringUtil.h"
#import "UIKit/UIKit.h"
static DTMDataBaseManager *sharedInstance;
// fileName
static NSString *const kDTMDataBaseName = @"dtm_report.sqlites";
// tableName
static NSString *const kDTMDataBaseTableName = @"dtm_report";
static NSString *const kBeginTransaction = @"BEGIN";
static NSString *const kCommitTransaction = @"COMMIT";
// Creat Table SQL
static NSString *const kCreateReportTableSQL = @"CREATE TABLE IF NOT EXISTS %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ INTEGER, %@ text, %@ INTEGER, %@ text, %@ text, %@ text, %@ text)";
// 插入数据
static NSString *const kInsertSql = @"INSERT INTO %@('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') values (?,?,?,?,?,?,?,?)";
// 查询指定数量条数据
static NSString *const kSelectSql = @"SELECT %@, %@, %@, %@, %@, %@, %@, %@  FROM %@ order by %@ asc LIMIT %lu";
// 依据索引查询指定数量条数据
static NSString *const kSelectWithIndexSql = @"SELECT %@, %@, %@, %@, %@, %@, %@, %@  FROM %@ where id > %ld order by id asc LIMIT %lu";
// 根据id删除某条数据
static NSString *const kDeleteSql = @"DELETE FROM %@ WHERE %@ = %@";
// 删除一指定时间之前的数据
static NSString *const kDeleteBeforeTimeSql = @"DELETE FROM %@ WHERE %@ < %@";
// 更新上报时间
static NSString *const kUpdateSendTime = @"UPDATE %@ SET %@ = '%@' WHERE id = '%@'";
// 查看数据总量
static NSString *const kCountSql = @"SELECT COUNT(id) FROM %@";
// 删除所有
static NSString *const kDeleteTableSql = @"DROP TABLE %@";
// 删除id靠前的数据
static NSString *const kDeleteTooMuchData = @"delete from %@ where id not in(select id from test order by id desc limit %@)";
// 最大容量
static NSUInteger MaxCount = 3000;
@interface DTMDataBaseManager ()
// db操作专用线程
@property (nonatomic, strong) NSThread *dbThread;
@end
@implementation DTMDataBaseManager {
    NSLock *lock;
    sqlite3 *conn;
}
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DTMDataBaseManager alloc] init];
        sharedInstance.dbThread = [[NSThread alloc] initWithTarget:sharedInstance selector:@selector(startRunLoppAndCreateDataBase) object:nil];
        sharedInstance.dbThread.name = @"DTMDataBaseThread";
        [sharedInstance.dbThread start];
    });
    return sharedInstance;
}
// 线程初始化
- (void)startRunLoppAndCreateDataBase {
    // 在当前线程中初始化数据库
    [self initRepository];
    // 启动runloop
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    [runLoop run];
}
// 创建数据库
- (BOOL)initRepository {
    lock = [[NSLock alloc] init];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbFile = [docPath stringByAppendingPathComponent:kDTMDataBaseName];
    DebugLog(TAG_REPORT, @"%@", dbFile);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isDerectory = NO;
    if (![fileMgr fileExistsAtPath:dbFile isDirectory:&isDerectory]) {
        [fileMgr createFileAtPath:dbFile contents:nil attributes:nil];
    }
    if (sqlite3_open_v2(dbFile.UTF8String, &conn, SQLITE_OPEN_READWRITE, nil) != SQLITE_OK) {
        [self safeClose:conn];
        return NO;
    }
    return [self createTable];
}
// 创建表
- (BOOL)createTable {
    BOOL result = [self execuSQL:[NSString stringWithFormat:kCreateReportTableSQL, kDTMDataBaseTableName, kDtmDBid, kDtmDBCreatTime, kDtmDBUrl, kDtmDBFirstsendTime, kDtmDBMethod, kDtmDBUniqueId, kDtmDBHeader, kDtmDBBody]];
    return result;
}
// 执行sql
- (BOOL)execuSQL:(NSString *)sql {
    char *error;
    if (sqlite3_exec(conn, sql.UTF8String, nil, nil, &error) == SQLITE_OK) {
        return YES;
    }
    return NO;
}
// 关闭数据库
- (void)__attribute__((annotate("oclint:suppress")))safeClose:(sqlite3 *)conn {
    int closeResult;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.2) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        closeResult = sqlite3_close_v2(conn);
#pragma clang diagnostic pop
    } else {
        closeResult = sqlite3_close(conn);
    }
    if (closeResult == SQLITE_OK) {
        conn = nil;
    }
}
- (void)dealloc {
    [self performSelector:@selector(safeClose:) onThread:self.dbThread withObject:CFBridgingRelease(conn) waitUntilDone:NO];
}
#pragma mark-------------- 数据库增删该查相关功能
#pragma mark insert
- (BOOL)save:(id)model {
    [lock lock];
    BOOL resultFlag = YES;
    sqlite3_stmt *stmt;
    // 预编译sql
    sqlite3_prepare_v2(conn, [NSString stringWithFormat:kInsertSql, kDTMDataBaseTableName, kDtmDBid, kDtmDBCreatTime, kDtmDBUrl, kDtmDBFirstsendTime, kDtmDBMethod, kDtmDBUniqueId, kDtmDBHeader, kDtmDBBody].UTF8String, -1, &stmt, nil);
    // 绑定占位参数
    NSString *create_timeStr = [model valueForKey:kDtmDBCreatTime];
    NSString *urlStr = [model valueForKey:kDtmDBUrl];
    NSString *first_send_timeStr = [model valueForKey:kDtmDBFirstsendTime];
    NSString *methodStr = [model valueForKey:kDtmDBMethod];
    NSString *unique_idStr = [model valueForKey:kDtmDBUniqueId];
    NSString *headersStr = [model valueForKey:kDtmDBHeader];
    NSString *bodyStr = [model valueForKey:kDtmDBBody];
    sqlite3_bind_int(stmt, 2, [create_timeStr intValue]);
    sqlite3_bind_text(stmt, 3, urlStr.UTF8String, -1, nil);
    sqlite3_bind_int(stmt, 4, [first_send_timeStr intValue]);
    sqlite3_bind_text(stmt, 5, methodStr.UTF8String, -1, nil);
    sqlite3_bind_text(stmt, 6, unique_idStr.UTF8String, -1, nil);
    sqlite3_bind_text(stmt, 7, headersStr.UTF8String, -1, nil);
    sqlite3_bind_text(stmt, 8, bodyStr.UTF8String, -1, nil);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        resultFlag = NO;
        DebugLog(TAG_REPORT, @"save failed %d", result);
    } else {
        DebugLog(TAG_REPORT, @"save success ");
    }
    sqlite3_finalize(stmt);
    [lock unlock];
    return resultFlag;
}
- (void)saveWithBlock:(NSArray *)paramArray {
    if (paramArray.count == 2) {
        id model = paramArray.firstObject;
        SaveComplateBlock block = paramArray.lastObject;
        [self save:model];
        if (block) {
            block();
        }
    }
}
// 查询表中数据量
- (NSUInteger)repoCount {
    [lock lock];
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(conn, [NSString stringWithFormat:kCountSql, kDTMDataBaseTableName].UTF8String, -1, &stmt, nil);
    NSInteger count = -1;
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        count = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    [lock unlock];
    return count;
}
#pragma mark query
// 根据数量查询
- (void)prepareFetchWithDic:(NSDictionary *)dic {
    char *error;
    // 数量
    NSUInteger count = [(NSNumber *)[dic objectForKey:@"count"] integerValue];
    // 索引
    NSInteger index = -1;
    index = [(NSNumber *)[dic objectForKey:@"index"] integerValue];
    [lock lock];
    sqlite3_exec(conn, kBeginTransaction.UTF8String, nil, nil, &error);
    NSMutableArray *allData = [[NSMutableArray alloc] init];
    NSArray *resultArr;
    if (index > -1) {
        // 依据索引取
        NSString *sqlString = [NSString stringWithFormat:kSelectWithIndexSql, kDtmDBid, kDtmDBCreatTime, kDtmDBUrl, kDtmDBFirstsendTime, kDtmDBMethod, kDtmDBUniqueId, kDtmDBHeader, kDtmDBBody, kDTMDataBaseTableName, (long)index, (unsigned long)count];
        resultArr = [self fetchWithNumber:count andSql:sqlString];
    } else {
        // 从顶端取
        resultArr = [self fetchWithNumber:count andSql:[NSString stringWithFormat:kSelectSql, kDtmDBid, kDtmDBCreatTime, kDtmDBUrl, kDtmDBFirstsendTime, kDtmDBMethod, kDtmDBUniqueId, kDtmDBHeader, kDtmDBBody, kDTMDataBaseTableName, kDtmDBid, (unsigned long)count]];
    }
    [allData addObjectsFromArray:resultArr];
    sqlite3_exec(conn, kCommitTransaction.UTF8String, nil, nil, &error);
    [lock unlock];
    // 将查询结果通知上报中心
    [ReportCenter performSelector:@selector(dataBaseRueryResult:) onThread:self.dbThread withObject:allData waitUntilDone:NO];
}
// 查询
- (nonnull NSArray *)fetchWithNumber:(NSUInteger)count andSql:(NSString *)sqlString {
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(conn, sqlString.UTF8String, -1, &stmt, nil);
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        // 绑定参数索引从1开始，读取字段索引从0开始 :(
        NSUInteger idChar = sqlite3_column_int(stmt, 0);
        NSString *idStr = [NSString stringWithFormat:@"%lu", (unsigned long)idChar];
        NSUInteger create_timeChar = sqlite3_column_int(stmt, 1);
        NSString *create_timeStr = [NSString stringWithFormat:@"%lu", (unsigned long)create_timeChar];
        char *urlChar = (char *)sqlite3_column_text(stmt, 2);
        if (urlChar == NULL || nil) {
            urlChar = "";
        }
        NSString *urlStr = [DTMStringUtil isEmpty:[[NSString alloc] initWithUTF8String:urlChar]] ? @"" : [[NSString alloc] initWithUTF8String:urlChar];
        NSUInteger first_send_timeChar = sqlite3_column_int(stmt, 3);
        NSString *first_send_timeStr = [NSString stringWithFormat:@"%lu", (unsigned long)first_send_timeChar];
        char *methodChar = (char *)sqlite3_column_text(stmt, 4);
        if (methodChar == NULL || nil) {
            methodChar = "";
        }
        NSString *methodStr = [DTMStringUtil isEmpty:[[NSString alloc] initWithUTF8String:methodChar]] ? @"" : [[NSString alloc] initWithUTF8String:methodChar];
        char *unique_idChar = (char *)sqlite3_column_text(stmt, 5);
        if (unique_idChar == NULL || nil) {
            unique_idChar = "";
        }
        NSString *unique_idStr = [DTMStringUtil isEmpty:[[NSString alloc] initWithUTF8String:unique_idChar]] ? @"" : [[NSString alloc] initWithUTF8String:unique_idChar];
        char *headersChar = (char *)sqlite3_column_text(stmt, 6);
        if (headersChar == NULL || nil) {
            headersChar = "";
        }
        NSString *headersStr = [DTMStringUtil isEmpty:[[NSString alloc] initWithUTF8String:headersChar]] ? @"" : [[NSString alloc] initWithUTF8String:headersChar];
        char *bodyChar = (char *)sqlite3_column_text(stmt, 7);
        if (bodyChar == NULL || nil) {
            bodyChar = "";
        }
        NSString *bodyStr = [DTMStringUtil isEmpty:[[NSString alloc] initWithUTF8String:bodyChar]] ? @"" : [[NSString alloc] initWithUTF8String:bodyChar];
        NSDictionary *resultobjDic = @{
            kDtmDBid : idStr,
            kDtmDBCreatTime : create_timeStr,
            kDtmDBUrl : urlStr,
            kDtmDBFirstsendTime : first_send_timeStr,
            kDtmDBMethod : methodStr,
            kDtmDBUniqueId : unique_idStr,
            kDtmDBHeader : headersStr,
            kDtmDBBody : bodyStr
        };
        [results safeAddObject:resultobjDic];
    }
    sqlite3_finalize(stmt);
    return [results copy];
}
#pragma mark delete
- (void) delete:(NSString *)ID {
    [lock lock];
    sqlite3_stmt *stmt;
    NSString *sql = [NSString stringWithFormat:kDeleteSql, kDTMDataBaseTableName, kDtmDBid, ID];
    sqlite3_prepare_v2(conn, sql.UTF8String, -1, &stmt, nil);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        DebugLog(TAG_REPORT, @" delete failed %d", result);
    } else {
        DebugLog(TAG_REPORT, @"delete success");
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    [lock unlock];
}
// 将自增id设为0
- (void)setIdKeyZero {
    [lock lock];
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(conn, @"DELETE FROM sqlite_sequence".UTF8String, -1, &stmt, nil);
    sqlite3_step(stmt);
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    [lock unlock];
}
#pragma mark update kUpdateSendTime
- (void)updateSendTimeWithID:(NSString *)ID {
    [lock lock];
    sqlite3_stmt *stmt;
    NSString *sql = [NSString stringWithFormat:kUpdateSendTime, kDTMDataBaseTableName, kDtmDBFirstsendTime, [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]], ID];
    sqlite3_prepare_v2(conn, sql.UTF8String, -1, &stmt, nil);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        DebugLog(TAG_REPORT, @"update fialed %d", result);
    } else {
        DebugLog(TAG_REPORT, @"update success");
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    [lock unlock];
}
// 清理一个月前的数据
- (void)dtmDataBaseCleanTooFarData {
    [lock lock];
    //当前时间
    NSString *currentTime = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *markTime = [NSString stringWithFormat:@"%ld", (long)([currentTime integerValue] - 2592000)];
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(conn, [NSString stringWithFormat:kDeleteBeforeTimeSql, kDTMDataBaseTableName, kDtmDBCreatTime, markTime].UTF8String, -1, &stmt, nil);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) {
        DebugLog(TAG_REPORT, @"clear tooFar success");
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    [lock unlock];
}
- (void)dtmDataBaseClearTooMuchData {
    // 当前数据库数量
    NSUInteger count = [self repoCount];
    if (count > MaxCount) {
        [lock lock];
        sqlite3_stmt *stmt;
        sqlite3_prepare_v2(conn, [NSString stringWithFormat:kDeleteTooMuchData, kDTMDataBaseTableName, [NSString stringWithFormat:@"%lu", (unsigned long)MaxCount]].UTF8String, -1, &stmt, nil);
        int result = sqlite3_step(stmt);
        if (result == SQLITE_DONE) {
            DebugLog(TAG_REPORT, @"clear tooMuch success");
        }
        sqlite3_reset(stmt);
        sqlite3_finalize(stmt);
        [lock unlock];
    }
    if (count == 0) {
        // 无数据 将自增id设0
        [self setIdKeyZero];
    }
}
- (void)dtmDataBaseJudgeisNeedStopCycleReport {
    // 当前数据库数量
    NSUInteger count = [self repoCount];
    if (count == 0) {
        [ReportCenter stopCycyleReport];
        [self setIdKeyZero];
    }
}
#pragma mark----------------------------------- 业务功能
// 保存动作无回调
- (void)dtmDataBaseSaveEvent:(id)model {
    [self performSelector:@selector(save:) onThread:self.dbThread withObject:model waitUntilDone:NO];
}
// 保存动作有储存结束回调
- (void)dtmDataBaseSaveEvent:(id)model withComplateBlock:(SaveComplateBlock)complate {
    [self performSelector:@selector(saveWithBlock:) onThread:self.dbThread withObject:@[ model, complate ] waitUntilDone:NO];
}
// 更新动作
- (void)dtmDataBaseUpdateSendTimeWithID:(NSString *)ID {
    if (![DTMStringUtil isEmpty:ID]) {
        [self performSelector:@selector(updateSendTimeWithID:) onThread:self.dbThread withObject:ID waitUntilDone:NO];
    }
}
// 查询动作
- (void)dtmDataBaseQueryDataWithLength:(NSUInteger)count {
    [self performSelector:@selector(prepareFetchWithDic:)
                 onThread:self.dbThread
               withObject:@{ @"count" : @(count),
                             @"index" : @(0) }
            waitUntilDone:NO];
}
// 带索引的查询
- (void)dtmDataBaseQueryDataWithLength:(NSUInteger)count andStartNum:(NSInteger)index {
    if (index > -1) {
        [self performSelector:@selector(prepareFetchWithDic:)
                     onThread:self.dbThread
                   withObject:@{ @"count" : @(count),
                                 @"index" : @(index) }
                waitUntilDone:NO];
    }
}
// 删除动作
- (void)dtmDataBaseDeleteWithID:(NSString *)ID {
    if (![DTMStringUtil isEmpty:ID]) {
        [self performSelector:@selector(delete:) onThread:self.dbThread withObject:ID waitUntilDone:NO];
    }
}
// 清理数据
- (void)dtmDataBaseClearData{
    [self performSelector:@selector(dtmDataBaseCleanTooFarData) onThread:self.dbThread withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(dtmDataBaseClearTooMuchData) onThread:self.dbThread withObject:nil waitUntilDone:NO];
}
// 检测数量 判断是否要停止上报
- (void)checkIsNeedStopCycleReport{
    [self performSelector:@selector(dtmDataBaseJudgeisNeedStopCycleReport) onThread:self.dbThread withObject:nil waitUntilDone:NO];
}
@end
