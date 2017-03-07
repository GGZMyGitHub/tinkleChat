//
//  AppDelegate.m
//  tinkleChat
//
//  Created by apple on 16/9/28.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "AppDelegate.h"

#import "WeChat.pch"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    GGZLoginController *login = [[GGZLoginController alloc]init];
    
        GGZRootNavigationController *loginNav = [[GGZRootNavigationController alloc]initWithRootViewController:login];
    self.window.rootViewController =loginNav;
    
    [self.window makeKeyAndVisible];
    //环信初始化SDK,去掉日志
   
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"sure#sure" apnsCertName:@"SureChat" otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:NO]}];
    
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}
//登陆成功
- (void)loginSuccess {
    UITabBarController *tabbarCtr = [[UITabBarController alloc]init];
    
   // GGZLoginController
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}
// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application {
   [[EaseMob sharedInstance] applicationWillTerminate:application];
}

@end
