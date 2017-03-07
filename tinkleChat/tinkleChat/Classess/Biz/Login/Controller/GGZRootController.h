//
//  GGZRootController.h
//  tinkleChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GGZContentView.h"

#import "AppDelegate.h"

@interface GGZRootController : UIViewController

//登陆界面 控制器的View
@property (nonatomic,weak)GGZContentView *contentView;

@property (nonatomic,strong)AppDelegate *myAppDelegate;

@end
