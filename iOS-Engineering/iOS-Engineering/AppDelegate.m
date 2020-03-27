//
//  AppDelegate.m
//  iOS-Engineering
//
//  Created by zjs on 2019/4/17.
//  Copyright © 2019 zjs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


////保存keywindow,保证弹窗消失还原keywindow到主界面
//- (void)getPreviouseWindow
//{
//    /*
//     这里使用[UIApplication sharedApplication].delegate而不使用[UIApplication sharedApplication].keyWindow，是因为
//     [UIApplication sharedApplication].keyWindow在makeKeyAndVisible之后才有效，viewWillAppear和之前的之前都是无效的，且易购工程
//     [UIApplication sharedApplication].window是最后launcher.window赋值的，有些弹框在didFinishLaunchingWithOptions完成前就要弹出，比如隐私
//     */
//    if([UIApplication sharedApplication].delegate.window){
//        self.previouseWindow = [UIApplication sharedApplication].delegate.window;
//    }else{
        // SN_APPCONTEXT_GET_APPLAUNCHER 为获取SNAppLauncher
        //SNAppLauncher 为系统didFinishLaunchingWithOptions 之前做的操作
//        SN_APPCONTEXT_GET_APPLAUNCHER(launcher);
//        self.previouseWindow = launcher.window;
//    }
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
