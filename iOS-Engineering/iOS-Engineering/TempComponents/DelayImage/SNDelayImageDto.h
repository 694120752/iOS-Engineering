//
//  SNDelayImageDto.h
//  iOS-Engineering
//
//  Created by sn_zjs on 2019/6/19.
//  Copyright © 2019 sn_zjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SNDelayImageDto;
typedef void (^SNDelayImageDisplayBlock)(SNDelayImageDto *delayDto);

typedef NS_ENUM(NSInteger, SNDelayImageType) {
    SNDelayImageTypeImageNamed      = 0,  
    SNDelayImageTypeImagUrled       = 1
};

@interface SNDelayImageDto : NSObject
@property(nonatomic, assign) SNDelayImageType imgType;

//使用image的对象
@property(nonatomic, weak) id imgObject;

//获取image的name或者url
@property(nonatomic, strong) NSArray *imgNameArray;

//image存储dict
@property(nonatomic, strong) NSMutableDictionary *imgDict;

//自定义展示block，如果赋值，底层不会自动渲染
@property(nonatomic, copy) SNDelayImageDisplayBlock displalyBlock;

//imgObject的hash值，作为key使用
@property(nonatomic, copy) NSString *hashKey;

//所属array，用作判断状态
@property(nonatomic, weak) NSMutableArray *ownerArray;

//获取image
- (UIImage *)imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
