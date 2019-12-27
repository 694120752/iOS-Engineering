//
//  UIView+trickPoint.m
//  zzz
//
//  Created by sn_zjs on 2019/12/26.
//  Copyright © 2019 sn_zjs. All rights reserved.
//

#import "UIView+trickPoint.h"
#import <objc/runtime.h>

static char kSomeKindKey;
// 是否已经添加了蒙层
static char isCoverd;

@implementation UIView (trickPoint)
- (void)setTrickPoint:(NSString *)trickPoint {
    objc_setAssociatedObject(self, &kSomeKindKey, trickPoint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (trickPoint) {
        [self checkIsNeedCove];
    }
}

- (NSString *)trickPoint {
    return objc_getAssociatedObject(self, &kSomeKindKey);
}

- (void)checkIsNeedCove {
    BOOL result = objc_getAssociatedObject(self, &isCoverd);
    if (!result) {
        // 创建
        [self creatNumberLayer];
        // 创建关联
        objc_setAssociatedObject(self, &isCoverd, @(YES), OBJC_ASSOCIATION_ASSIGN);
    }
    
    // 更新蒙层的数据
    [self someKindOfDataMeth];
}

- (void)creatNumberLayer {
    
    CALayer* borderLayer = [[CALayer alloc]init];
    [self.layer addSublayer:borderLayer];
    borderLayer.borderWidth = 2;
    borderLayer.borderColor = [UIColor blackColor].CGColor;
    borderLayer.frame = self.bounds;
    
}

- (void)someKindOfDataMeth{
    // viewWithTag 可获得想要更新的View
    // changeValue
}

@end
