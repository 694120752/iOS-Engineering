//
//  DelayImageDto.h
//  iOS-Engineering
//
//  Created by zjs on 2019/6/19.
//  Copyright © 2019 zjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DelayImageDto;
typedef void (^DelayImageDisplayBlock)(DelayImageDto *delayDto);

typedef NS_ENUM(NSInteger, DelayImageType) {
    DelayImageTypeImageNamed      = 0,  
    DelayImageTypeImagUrled       = 1
};

//给UIButton设置图片的填充模式
typedef NS_ENUM(NSInteger, DelayImageButtonImageMode) {
    DelayImageModeSetImage           = 0,   // setImage
    DelayImageModeSetBackgroundImage = 1    // setBackgroundImage
};

@interface DelayImageDto : NSObject
@property(nonatomic, assign) DelayImageType imgType;

//使用image的对象
@property(nonatomic, weak) id imgObject;

//获取image的name或者url
@property(nonatomic, strong) NSArray *imgNameArray;

//image存储dict
@property(nonatomic, strong) NSMutableDictionary *imgDict;

//自定义展示block，如果赋值，底层不会自动渲染
@property(nonatomic, copy) DelayImageDisplayBlock displalyBlock;

//imgObject的hash值，作为key使用
@property(nonatomic, copy) NSString *hashKey;

//所属array，用作判断状态
@property(nonatomic, weak) NSMutableArray *ownerArray;

//给UIButton设置图片的填充模式
@property(nonatomic, assign) DelayImageButtonImageMode buttonImageMode;

//给UIButton设置图片的状态
@property(nonatomic, assign) UIControlState buttonControlState;

//获取image
- (UIImage *)imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
