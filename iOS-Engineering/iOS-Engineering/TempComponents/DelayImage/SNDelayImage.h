//
//  SNDelayImage.h
//  iOS-Engineering
//
//  Created by sn_zjs on 2019/6/19.
//  Copyright © 2019 sn_zjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDelayImageDto.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNDelayImage : NSObject

+ (void)showWithDTO:(SNDelayImageDto *)dto;

//+ (void)imageNamed:(NSString *)name showInView:(UIImageView *)imgView;

@end

NS_ASSUME_NONNULL_END
