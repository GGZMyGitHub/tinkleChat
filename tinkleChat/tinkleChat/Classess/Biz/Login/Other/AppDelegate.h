//
//  AppDelegate.h
//  tinkleChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//登陆成功
- (void)loginSuccess;

//退出登录成功
- (void)logOutSuccess;

@end

