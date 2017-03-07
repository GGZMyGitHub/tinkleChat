//
//  GGZLoginController.m
//  tinkleChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZLoginController.h"

#import "WeChat.pch"

@interface GGZLoginController ()<EMChatManagerDelegate>

@property (nonatomic,strong)UITextField *userField;
@property (nonatomic,strong)UITextField *pswField;
@property (nonatomic,strong)UILabel *userLable;
@property (nonatomic,strong)UILabel *pswLable;

@end

@implementation GGZLoginController


-(void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


/*
    自动登陆：登陆成功之后，将用户名、密码存储到本地数据库中
    下次打开程序直接读取本地数据库的账号和密码，在AppDelegate中读取
    环信已经做好了，只需设置一个属性就可以了
    属性应该在登陆成功之后设置
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =@"登录";
    
    //布局登陆界面的UI控件
    [self createUI];

    //登陆
    [self createLogin];
    
    //注册
    [self createLogOut];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)createUI {

    _userLable = [[UILabel alloc]init];
    _userLable.frame =CGRectMake(20, 50, 60, 44);
    _userLable.text = @"用户名:";
    [self.contentView addSubview:_userLable];
    
    //使用Utilities框架里面的UIViewExt.h
   _userField = [[UITextField alloc]init];
    _userField.frame = CGRectMake(_userLable.right +10, _userLable.top, 200, 44);
    _userField.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:_userField];
    
    
    _pswLable = [[UILabel alloc]init];
    _pswLable.frame =CGRectMake(20, _userLable.bottom+20, 60, 44);
    _pswLable.text = @"密码:";
    [self.contentView addSubview:_pswLable];
    
    _pswField = [[UITextField alloc]init];
    _pswField.frame = CGRectMake(_pswLable.right +10, _pswLable.top, 200, 44);
    _pswField.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:_pswField];

}

//登陆
- (void)createLogin {
    GGZButton *loginbutton = [GGZButton createGGZButton];
    loginbutton.frame = CGRectMake(20, _pswField.bottom +800, 100, 44);
    [loginbutton setTitle:@"登陆" forState:UIControlStateNormal];

    [loginbutton setBackgroundColor:[UIColor redColor]];
    loginbutton.tag = 100;
    [self.contentView addSubview:loginbutton];
    
    //GGZButton中的block回调
    loginbutton.block = ^(GGZButton *button) {
        
        //判断用户名和密码注册时不为空
        if (_userField.text.length == 0) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"用户名不能为空"];if (_userField.text.length == 0) {
                return ;
            }
        }
        if (_pswField.text.length == 0) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"密码不能为空"];
            return ;
        }
        
        //异步登陆
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:_userField.text password:_pswField.text completion:^(NSDictionary *loginInfo, EMError *error) {
        //    NSLog(@"LoginInfo = %@",loginInfo);
            
            if (!error && loginInfo) {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"登陆成功"];
                
                [self.myAppDelegate loginSuccess];
                
                
                //设置自动登陆,回到Appdelegate中判断
                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                
            }
        } onQueue:nil];
    };

}

//注册
- (void)createLogOut {
    
    GGZButton *loginbutton = (GGZButton *)[self.view viewWithTag:100];
    
    GGZButton *registerbutton = [GGZButton createGGZButton];
    registerbutton.frame = CGRectMake(loginbutton.right+kWeChatPadding*16, _pswField.bottom +800, 100, 44);
    [registerbutton setTitle:@"注册" forState:UIControlStateNormal];

    [registerbutton setBackgroundColor:[UIColor redColor]];
    [self.contentView addSubview:registerbutton];
    
    //GGZButton中的block回调
    registerbutton.block = ^(GGZButton *button) {
        
        //判断用户名和密码注册时不为空
        if (_userField.text.length == 0) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"用户名不能为空"];
            if (_userField.text.length == 0) {
                return ;
            }
        }
        if (_pswField.text.length == 0) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"密码不能为空"];
            return ;
        }
        
        //异步注册
        [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_userField.text password:_pswField.text withCompletion:^(NSString *username, NSString *password, EMError *error) {
            if (!error) {
                NSLog(@"注册成功");
                 [[TKAlertCenter defaultCenter] postAlertWithMessage:@"注册成功"];
            }
        } onQueue:nil];
        
    };

}

//登录成功代理方法
- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
   
    // NSLog(@"userName = %@ password = %@",loginInfo[@"username"],loginInfo[@"password"]);
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
