//
//  LearnCalayer.m
//  iOS-Engineering
//
//  Created by sn_zjs on 2019/12/27.
//  Copyright © 2019 sn_zjs. All rights reserved.
//

#import "LearnCalayer.h"
#import <UIKit/UIKit.h>

@interface LearnCalayer ()
@property (nonatomic, strong) UIView *view;
@end

@implementation LearnCalayer
- (void)testFunction{
    

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, 40, 100, 50)];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"111" forState:UIControlStateNormal];
    [self.view addSubview:btn];

//    CAShapeLayer *shap = [[CAShapeLayer alloc]init];
//    shap.frame = CGRectMake(0, 0, 100, 50);//btn.bounds;
    
    
////    shap.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
//    UIBezierPath *path = [UIBezierPath bezierPath];
//
//    [path moveToPoint:CGPointMake(10, 40)];
//    [path addLineToPoint:CGPointMake(80, 40)];
//    [path addLineToPoint:CGPointMake(0, 0)];
//    [path closePath];
//    [path fill];
//    shap.path = path.CGPath;
    
//    mask 其实是根据颜色值来判断形状的 透明的为需要裁减的 有颜色的为需要保留的 而layer的默认颜色为透明的
//    btn.layer.mask = shap;
    

    CALayer *masLay = [[CALayer alloc] init];
    masLay.frame = btn.bounds;
    // 这里如果设置了背景色 相当于全部填充了  path就无效了
//    masLay.backgroundColor = [UIColor redColor].CGColor;
//    masLay.masksToBounds = YES;
    CAShapeLayer *leftLayer = [[CAShapeLayer alloc] init];
    leftLayer.frame = CGRectMake(0, 0, 50, 50);
    // 它有背景色没关系
    leftLayer.fillColor = [UIColor redColor].CGColor;
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:leftLayer.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(25, 25)];
    leftLayer.path = leftPath.CGPath;
    [masLay addSublayer:leftLayer];

    CAShapeLayer *rightLayer = [[CAShapeLayer alloc] init];
    rightLayer.frame = CGRectMake(50, 0, 50, 50);
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRoundedRect:rightLayer.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    rightLayer.path = rightPath.CGPath;
    [masLay addSublayer:rightLayer];

    btn.layer.mask = masLay;
}
@end
