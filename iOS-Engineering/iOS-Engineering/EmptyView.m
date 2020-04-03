//
//  EmptyView.m
//  iOS-Engineering
//
//  Created by sn_zjs on 2020/4/2.
//  Copyright © 2020 sn_zjs. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [super pointInside:point withEvent:event];
}
@end
