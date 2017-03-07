//
//  AppDelegate.m
//  tinkleChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "AppDelegate.h"

#import "WeChat.pch"

@interface AppDelegate ()<EMChatManagerDelegate>

//登陆控制器
@property (nonatomic,strong) GGZRootNavigationController *loginNav;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    GGZLoginController *loginCtr = [[GGZLoginController alloc]init];
    
   self.loginNav = [[GGZRootNavigationController alloc]initWithRootViewController:loginCtr];
    self.window.rootViewController =self.loginNav;
   
    
    [self.window makeKeyAndVisible];
    
    
    //设置导航条
    //背景图片
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    //更改导航条上面字的颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    //环信初始化SDK,去掉日志
   
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"sure#sure" apnsCertName:@"SureChat" otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:NO]}];
    
    //调用环信的程序加载完毕的方法，才能添加代理
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //判断自动登录
    if ([[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
        
        //添加加载菊花
        [MBProgressHUD showMessag:@"正在登陆..." toView:self.window];
        
    }
    //添加自动登录代理方法
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    
    return YES;
}

#pragma mark EMChatManagerDelegate代理方法

- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    NSLog(@"即将自动登录");
    
}

- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    [MBProgressHUD hideHUDForView:self.window animated:YES];
    //调用登陆方法，切换控制器
    [self loginSuccess];
    
    NSLog(@"自动登录成功");
    
}

//登陆成功
- (void)loginSuccess {
    UITabBarController *tabbarCtr = [[UITabBarController alloc]init];
    
    GGZConversationController *conversationCtr = [[GGZConversationController alloc]init];
    GGZRootNavigationController *conversationNav = [[GGZRootNavigationController alloc]initWithRootViewController:conversationCtr];
    
    conversationCtr.tabBarItem.image = [UIImage imageNamed:@"tabbar_mainframe"];
    conversationCtr.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_mainframeHL"];
    conversationCtr.title = @"聊天";
    
    GGZContactController *contactCtr = [[GGZContactController alloc]init];
    GGZRootNavigationController *contactNav = [[GGZRootNavigationController alloc]initWithRootViewController:contactCtr];
    
    contactCtr.tabBarItem.image = [UIImage imageNamed:@"tabbar_contacts"];
    contactCtr.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_contactsHL"];
    contactCtr.title = @"通讯录";

    GGZMeController *meCtr = [[GGZMeController alloc]init];
    GGZRootNavigationController *meNav = [[GGZRootNavigationController alloc]initWithRootViewController:meCtr];
    
    meCtr.tabBarItem.image = [UIImage imageNamed:@"tabbar_discover"];
    meCtr.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_discoverHL"];
    meCtr.title = @"我";
    
    tabbarCtr.viewControllers = @[conversationNav,contactNav,meNav];
    self.window.rootViewController = tabbarCtr;
}

//退出登录成功
- (void)logOutSuccess {
    
    self.window.rootViewController =self.loginNav;
    //再退出登陆成功之后，就不能在设置自动登陆
    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
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
