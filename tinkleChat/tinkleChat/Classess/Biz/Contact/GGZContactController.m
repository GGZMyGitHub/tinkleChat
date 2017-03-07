//
//  GGZContactController.m
//  tinkleChat
//
//  Created by lishu tech on 16/5/9.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZContactController.h"

#import "GGZChatController.h"

#import "GGZGroupController.h"

@interface GGZContactController ()<EMChatManagerDelegate,UITableViewDelegate,UITableViewDataSource>

//好友列表
@property (nonatomic,strong)NSArray *buddies;

@property (nonatomic,weak)UITableView *myTableView;

@property (nonatomic,strong)UITableView *tableView;

@end

@implementation GGZContactController

-(void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理方法
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //创建添加好友按钮
    [self createRightAddFriendButton];
   
    //创建会话聊天的TableView
    [self createTableView];
    
    //获取本地好友历史列表
    [self getBuddyList];
    
}

- (void)createRightAddFriendButton {
    
    GGZButton *rightBtn = [GGZButton createGGZButton];
    rightBtn.frame = CGRectMake(kWeChatScreenWidth - 50, 0, 30, 30);
    [rightBtn setImage:[UIImage imageNamed:@"contacts_add_friend"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    rightBtn.block = ^(GGZButton *btn){
        
        //点击添加好友按钮，弹出提示框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加好友的请求信息" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            //好有名称
            textField.placeholder = @"请输入好友的名称";

        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            //请求信息
            textField.placeholder = @"请输入请求信息";
        }];
        
        //获取alert中的文本输入框
        UITextField *usernameField = [alert.textFields firstObject];
        UITextField *descriptionFiled = [alert.textFields lastObject];
        
        //再添加两个按钮用于选择同意或者拒绝
        UIAlertAction *comitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (usernameField.text.length ==0 ) {
                [[TKAlertCenter defaultCenter]postAlertWithMessage:@"请输入用户名"];
                return ;
            }
            //如果信息为空的话，那么就自定义一个
            NSString *message = (descriptionFiled.text.length ==0)?@"我想加你":descriptionFiled.text;
            //发送好友请求
            //   BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:usernameField.text message:message error:nil];
            //将好友添加到哪个分组中
            BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:usernameField.text message:message toGroups:@[@"xmg5"] error:nil];
            if (isSuccess) {
                NSLog(@"添加成功");
            }else {
                NSLog(@"添加失败");
            }
            
        }];
        //取消按钮
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        //添加两个按钮
        [alert addAction:comitAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    };

    
    
}

- (void)createTableView {
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWeChatScreenWidth, kWeChatScreenHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.buddies = [[NSArray alloc]init];
    
    //创建群组按钮
    GGZButton *groupBtn = [GGZButton createGGZButton];
    groupBtn.frame = CGRectMake(0, 0, kWeChatScreenWidth, kWeChatAllSubviewHeight);
    
    groupBtn.backgroundColor = [UIColor grayColor];
    [groupBtn setTitle:@"群组" forState:UIControlStateNormal];
    
    //群组点击事件
    groupBtn.block = ^(GGZButton *btn){
        GGZGroupController *groupCtr = [[GGZGroupController alloc]init];
        
        [self.navigationController pushViewController:groupCtr animated:YES];
        
    };
    
    
    
    _tableView.tableHeaderView = groupBtn;
    self.myTableView = _tableView;
    [self.contentView addSubview:_tableView];
    
    
    
}

- (void)getBuddyList {
    
    //获取本地好友历史列表
    [[EaseMob sharedInstance].chatManager buddyList];
    //当你App卸载，在装之后，会没有历史列表
    if (self.buddies.count ==0) {
        
        //从服务器上获取好友列表
        [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
            self.buddies = buddyList;
            [_tableView reloadData];
           
        } onQueue:nil];
    }

}

/*!
 @method   环信方法
 @brief 通讯录信息发生变化时的通知
 @discussion
 @param buddyList 好友信息列表
 @param changedBuddies 修改了的用户列表
 @param isAdd (YES为新添加好友, NO为删除好友)
 */
-(void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd {
    
   // NSLog(@"buddyList =%@ changeBuddies = %@",buddyList,changedBuddies);
    //添加或者删除好友
    NSString * str = isAdd ?@"添加的":@"删除的";
    NSLog(@"添加或者删除 = %@",str);
    self.buddies = buddyList;
    [self.myTableView reloadData];
}

//同意添加好友成功的回调
- (void)didAcceptBuddySucceed:(NSString *)username {
    NSLog(@"同意添加好友成功:%@",username);
}

//当前用户被别人删除时的回调
- (void)didRemovedByBuddy:(NSString *)username {
    NSLog(@"我被 %@删除",username);
}

#pragma mark tableView代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    EMBuddy *buddy = self.buddies[indexPath.row];
    cell.textLabel.text = buddy.username;
    return cell;
}

//cell向右划，有个delete，删除时调用这个方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    EMBuddy *buddy = self.buddies[indexPath.row];
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
       BOOL isSuccess = [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:nil];
        if (isSuccess) {
            [[TKAlertCenter defaultCenter]postAlertWithMessage:@"删除好友成功"];
        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GGZChatController *ChatCtr = [[GGZChatController alloc]initWithIsGroup:NO];
    
    [ChatCtr setHidesBottomBarWhenPushed:YES];
    
    ChatCtr.buddy = self.buddies[indexPath.row];
    
    [self.navigationController pushViewController:ChatCtr animated:YES];
    
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
