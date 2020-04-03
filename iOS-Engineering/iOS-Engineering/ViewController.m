//
//  ViewController.m
//  iOS-Engineering
//
//  Created by zjs on 2019/4/17.
//  Copyright © 2019 zjs. All rights reserved.
//

#import "ViewController.h"
#import "StaticFramework.framework/StaticObjc.h"
//#import "DynamicObject.h"
#import "HitView.h"
#import "EmptyView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.view.userInteractionEnabled = NO;

    HitView *topView = [[HitView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    topView.backgroundColor = [UIColor grayColor];
    EmptyView *empty = [[EmptyView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [topView addSubview:empty];
    empty.backgroundColor = [UIColor darkGrayColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [topView addGestureRecognizer:tap];
    [empty addGestureRecognizer:tap];
    [self.view addSubview:topView];
}

- (void)tapAction:(UITapGestureRecognizer *)ges {
    NSLog(@"111");
}

@end
