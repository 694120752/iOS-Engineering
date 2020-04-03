//
//  MyApplication.m
//  iOS-Engineering
//
//  Created by sn_zjs on 2020/4/1.
//  Copyright © 2020 sn_zjs. All rights reserved.
//

#import "MyApplication.h"

@implementation MyApplication
- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];

    // event中包含了通过hitTest找出来的第一响应者
}

@end
