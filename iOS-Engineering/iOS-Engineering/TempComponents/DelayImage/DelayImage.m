//
//  DelayImage.m
//  iOS-Engineering
//
//  Created by zjs on 2019/6/19.
//  Copyright © 2019 zjs. All rights reserved.
//

#import "DelayImage.h"

#define DelayImageHash(object) [NSString stringWithFormat:@"%lu", (unsigned long)[object hash]]
//字符串是否为空
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
//数组是否为空
#define IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

@interface DelayImage ()
@property(nonatomic, assign) BOOL isActive;

@property(nonatomic, strong) NSMutableDictionary *allImgDict;

// imageNamed
@property(nonatomic, strong) NSMutableArray *imageNamedArray;

@property(nonatomic, strong) NSMutableArray *imageNamedLoadArray;

@property(nonatomic, strong) dispatch_queue_t imageNamedLoadQueue;

// display
@property(nonatomic, strong) NSMutableArray *displayArray;
@end

@interface NSMutableArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index;
- (void)safeAddObject:(id)anObject;
@end

@implementation NSMutableArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (self.count > index)
    {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (void)safeAddObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}
@end

@interface NSArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index;
@end

@implementation NSArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (self.count > index)
    {
        return [self objectAtIndex:index];
    }
    return nil;
}
@end
@implementation DelayImage

+ (DelayImage *)sharedInstance{
    static DelayImage *delay = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delay = [[DelayImage alloc]init];
    });
    return delay;
}

- (id)init {
    if (self = [super init]) {
        
        _allImgDict = [NSMutableDictionary dictionary];
        _imageNamedArray = [NSMutableArray array];
        _imageNamedLoadArray = [NSMutableArray array];
        _imageNamedLoadQueue = dispatch_queue_create([[NSString stringWithFormat:@"DelayImage.imageNamedLoad.%@", self] UTF8String], NULL);
        _displayArray = [NSMutableArray array];
        
        DelayImageRunloopObserverSetup();
    }
    return self;
}

#pragma mark -------------------------- 使用入口
// 入口一
+ (void)showWithDTO:(DelayImageDto *)dto {
    dto.imgType = DelayImageTypeImageNamed;
    [[DelayImage sharedInstance] imageNamed_addDTO:dto];
}

// 入口二
+ (void)imageNamed:(NSString *)name showInView:(id)imgView {
//    [[DelayImage sharedInstance] startLoadImageWithName:name view:imgView controlState:UIControlStateNormal buttonImageMode:DelayImageModeSetImage];
}


- (void)imageNamed_addDTO:(DelayImageDto *)dto {
    
    if (!dto) {
        return;
    }
    
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self imageNamed_addDTO:dto];
        });
        return;
    }
    
    // image 使用者
    if (!dto.imgObject) {
        return;
    }
    if (IsArrEmpty(dto.imgNameArray)) {
        return;
    }
    
    // 当前imgView之前如果有加载图片，则将之前dto的imgObject置nil,后面不加载
    dto.hashKey = DelayImageHash(dto.imgObject);
    DelayImageDto *oldDTO = [_allImgDict valueForKey:dto.hashKey];
    if (oldDTO) {
        oldDTO.imgObject = nil;
    }
    [_allImgDict setValue:dto forKey:dto.hashKey];
    
    //加载待加载array
   
    [_imageNamedArray addObject:dto];
   
    
    dto.ownerArray = _imageNamedArray;
    [self imageNamed_startLoad];
}

- (void)imageNamed_startLoad{
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self imageNamed_startLoad];
        });
        return;
    }
    
    // 是否可以加载
    if (!_isActive) {
        return;
    }
    
    // 当前没有需要加载的图片,返回
    if (_imageNamedArray.count <= 0) {
        return;
    }
    
    // 有图片正在加载，返回
    if (_imageNamedLoadArray.count > 0) {
        return;
    }
    
    // 加载图片
    DelayImageDto *dto = [_imageNamedArray safeObjectAtIndex:0];
    // 从待加载array中移除
    [_imageNamedArray removeObject:dto];
    
    // 加入加载array
    [_imageNamedLoadArray safeAddObject:dto];
    dto.ownerArray = _imageNamedLoadArray;
    
    __weak typeof(self) weakSelf = self;
    // 图片加载队列
    dispatch_async(_imageNamedLoadQueue, ^{
        if (dto.imgObject) {
            for (NSString *name in dto.imgNameArray) {
                UIImage *image = [UIImage imageNamed:name];
                [dto.imgDict setValue:image forKey:name];
            }
        }
        [weakSelf imageNamed_finishLoad:dto];
    });
}

- (void)imageNamed_finishLoad:(DelayImageDto *)dto {
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self imageNamed_finishLoad:dto];
        });
        return;
    }
    
    //从加载array中移除
    [_imageNamedLoadArray removeAllObjects];
    
    // 加入展示array
    [self display_addDTO:dto];
    
    // 加载下一个
    [self imageNamed_startLoad];
}

#pragma mark display
- (void)display_addDTO:(DelayImageDto *)dto {
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self display_addDTO:dto];
        });
        return;
    }
    
    [_displayArray safeAddObject:dto];
    dto.ownerArray = _displayArray;
}

- (void)startDisplay {
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startDisplay];
        });
        return;
    }
    
    // 如果没有待展示的，返回
    if (_displayArray.count == 0) {
        return;
    }
    
    for (DelayImageDto *dto in _displayArray) {
        if (dto.imgObject) {
            if (dto.displalyBlock) {
                dto.displalyBlock(dto);
            } else if ([dto.imgObject isKindOfClass:[UIImageView class]]){
                UIImage *image = [dto.imgDict.allValues safeObjectAtIndex:0];
                [(UIImageView *)dto.imgObject setImage:image];
            }
        }
        
        // 加载完成，从allImgDict中移除
        [_allImgDict removeObjectForKey:dto.hashKey];
    }
    
    // 从展示array中移除
    [_displayArray removeAllObjects];
}


#pragma mark -------------------------- 观测
static void DelayImageRunloopObserverSetup(){
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        
        /**
         创建runloop观察者

         CFAllocatorGetDefault()                        该参数为对象内存分配器，一般使用默认的分配器kCFAllocatorDefault,或者NULL
         kCFRunLoopBeforeWaiting | kCFRunLoopExit       监听哪些状态
                                                        kCFRunLoopBeforeWaiting = (1UL << 5),//休眠前
                                                        kCFRunLoopExit = (1UL << 7),// 退出
         true                                           观察者只监听一次还是每次Run Loop运行时都监听。
         0xFFFFFF                                       观察者优先级
         DelayImageRunLoopObserverCallBack            回调
         NULL                                           上下文
         */
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,
                                           0xFFFFFF,
                                           DelayImageRunLoopObserverCallBack,
                                           NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

static void DelayImageRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    static BOOL firstCallBack = YES;
    if (firstCallBack) {
        firstCallBack = NO;
        [DelayImage sharedInstance].isActive = YES;
        [[DelayImage sharedInstance] imageNamed_startLoad];
    }
    
    [[DelayImage sharedInstance] startDisplay];
}

@end

// - button点击

// 设置点击区域
//- (void)setupTappableAreaOffset:(UIOffset)tappableAreaOffset_
//{
//    _tappableAreaOffset = tappableAreaOffset_;
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//
//    return CGRectContainsPoint(CGRectInset(self.bounds,  -_tappableAreaOffset.horizontal, -_tappableAreaOffset.vertical), point);
//
//}



//- (void)refreshRate:(SNChannelCMSModuleDTO *)model{
//    //    SNChannelNewQBuyStarImage@2x
//    if (!IsStrEmpty(model.custom_elementDesc2)) {
//        self.feedbackLabel.hidden = NO;
//        // 塞入图片转换为attributeStr
//        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
//        attach.image = [UIImage imageNamed:@"SNChannelNewQBuyStarImage"];
//        CGFloat imgH = Get375Width(11);
//        CGFloat imgW = (attach.image.size.width / attach.image.size.height) * imgH;
//        attach.bounds = CGRectMake(0, roundf(self.feedbackLabel.font.capHeight - imgH)/2.f, imgW, imgH);
//        NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc]init];
//        NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
//        NSAttributedString  *stringAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" 好评率%@%%",model.custom_elementDesc2]];
//        [finalStr appendAttributedString:imageAttr];
//        [finalStr appendAttributedString:stringAttr];
//        self.feedbackLabel.attributedText = finalStr;
//        
//    }else{
//        self.feedbackLabel.hidden = YES;
//    }
//}
