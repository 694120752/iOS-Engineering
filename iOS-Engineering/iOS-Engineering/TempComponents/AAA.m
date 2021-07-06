
#import <Foundation/Foundation.h>
#import "ReportCenter.h"
#import "sqlite3.h"
NS_ASSUME_NONNULL_BEGIN
// Column Name
static NSString *const kDtmDBid = @"id";
static NSString *const kDtmDBCreatTime = @"create_time";
static NSString *const kDtmDBUrl = @"url";
static NSString *const kDtmDBFirstsendTime = @"first_send_time";
static NSString *const kDtmDBMethod = @"method";
static NSString *const kDtmDBUniqueId = @"unique_id";
static NSString *const kDtmDBHeader = @"headers";
static NSString *const kDtmDBBody = @"body";
typedef void (^SaveComplateBlock)(void);
@interface DTMDataBaseManager : NSObject
/**
*获取单例对象
*/
+ (instancetype)sharedInstance;
/*
*  保存数据
* @param model 要保存的对象
* @return 结果
*/
- (void)dtmDataBaseSaveEvent:(id)model;
/*
*  保存数据 等待储存结束
* @param model 要保存的对象
* @return 结果
*/
- (void)dtmDataBaseSaveEvent:(id)model withComplateBlock:(SaveComplateBlock)block;
/*
*  根据id删除某条数据
* @param ID 要删除的id
*/
- (void)dtmDataBaseDeleteWithID:(NSString *)ID;
/*
*  查询指定数量的数据
*  从顶端开始查询20条
* @param count 要查询的数量
*/
- (void)dtmDataBaseQueryDataWithLength:(NSUInteger)count;
/*
*  根据id更新上报时间
* @param ID 要更新的id
*/
- (void)dtmDataBaseUpdateSendTimeWithID:(NSString *)ID;
/*
*  清理无用数据 （一个月前的 超过3000条的）
*/
- (void)dtmDataBaseClearData;
/*
*  查询指定数量的数据
*  @param count 要查询的数量
*  @param index 开始的索引
*/
- (void)dtmDataBaseQueryDataWithLength:(NSUInteger)count andStartNum:(NSInteger)index;
/*
*  检查数据库中的数据量判断是否需要停止周期性上报
*/
- (void)checkIsNeedStopCycleReport;
@end
NS_ASSUME_NONNULL_END
