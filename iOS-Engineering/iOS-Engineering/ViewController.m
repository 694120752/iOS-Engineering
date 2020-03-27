//
//  ViewController.m
//  iOS-Engineering
//
//  Created by zjs on 2019/4/17.
//  Copyright © 2019 zjs. All rights reserved.
//

#import "ViewController.h"
#import "StaticFramework.framework/StaticObjc.h"
#import <DynamicLib/DynamicObject.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[StaticObjc new] staticLog];
    [[DynamicObject new] dyLog];
}


@end
