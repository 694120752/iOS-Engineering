//
//  HitView.m
//  iOS-Engineering
//
//  Created by sn_zjs on 2020/4/1.
//  Copyright © 2020 sn_zjs. All rights reserved.
//

#import "HitView.h"

@implementation HitView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/**

 点击事件由window分发给子视图

 按照subViews的顺序分发 检测 先走 hitTest 然后hitTest内部调用pointInside
 接着有一个遍历检查的过程 如果发现有子视图 能响应则hitTest的返回值为子视图 否则 返回自身为第一响应者

 修改响应区域的原理就是重写 pointInside方法
 最好保证修改的view是最后一个添加到父视图上的

 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [super pointInside:point withEvent:event];
}

@end
