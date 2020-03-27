//
//  DelayImage.h
//  iOS-Engineering
//
//  Created by zjs on 2019/6/19.
//  Copyright © 2019 zjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DelayImageDto.h"

NS_ASSUME_NONNULL_BEGIN

@interface DelayImage : NSObject

+ (void)showWithDTO:(DelayImageDto *)dto;

+ (void)imageNamed:(NSString *)name showInView:(UIImageView *)imgView;

@end

NS_ASSUME_NONNULL_END
