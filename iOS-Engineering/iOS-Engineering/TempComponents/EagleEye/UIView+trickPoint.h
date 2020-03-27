//
//  UIView+trickPoint.h
//  对已创建的view添加埋点蒙层
//
//  Created by zjs on 2019/12/26.
//  Copyright © 2019 zjs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (trickPoint)
/** 具体数值*/
@property (nonatomic, strong) NSString *trickPoint;
@end

NS_ASSUME_NONNULL_END
