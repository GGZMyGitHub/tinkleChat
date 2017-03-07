//
//  GGZMeController.m
//  tinkleChat
//
//  Created by lishu tech on 16/5/9.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZMeController.h"

#import "WeChat.pch"

@interface GGZMeController ()

@end

@implementation GGZMeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加退出登陆按钮
    [self createLogOutButton];
    
}

- (void)createLogOutButton {
    
    GGZButton *logoutbtn = [GGZButton createGGZButton];
    logoutbtn.frame = CGRectMake(20, 64, kWeChatScreenWidth - kWeChatPadding*2, kWeChatAllSubviewHeight);
    
    [logoutbtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [self.contentView addSubview:logoutbtn];
    
    logoutbtn.block = ^(GGZButton *btn){
        //主动退出传YES，被迫退出传NO
        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
            if (!error) {
                
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"退出登录成功"];
                [self.myAppDelegate logOutSuccess];
            }
        } onQueue:nil];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
