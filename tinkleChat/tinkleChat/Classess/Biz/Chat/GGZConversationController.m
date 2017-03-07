//
//  GGZConversationController.m
//  tinkleChat
//
//  Created by lishu tech on 16/5/11.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZConversationController.h"

@interface GGZConversationController ()<EMChatManagerDelegate,UITableViewDelegate,UITableViewDataSource>

//数据源
@property (nonatomic,strong)NSMutableArray *conversations;

@property (nonatomic,weak)UITableView *m_tableView;

@end

@implementation GGZConversationController

-(void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
        [self loadConversation];
}

- (void)loadConversation {
    
    //把所有的移除掉在添加
    [self.conversations removeAllObjects];
     
  //  NSArray *tempArr = [[EaseMob sharedInstance].chatManager conversations];
    
    //从本地获取数据
    //获取当前的会话
  //  self.conversations = [NSMutableArray arrayWithArray:tempArr];
    
   
        //从服务端获取数据
        NSArray *loadArr = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
        
        self.conversations = [NSMutableArray arrayWithArray:loadArr];
        //应该是使用添加数组的方式
       // [self.conversations addObjectsFromArray:loadArr];
    
    [self.m_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建TableView
   UITableView *tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWeChatScreenWidth, kWeChatScreenHeight) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.contentView addSubview:tableView];
    self.m_tableView = tableView;

    //网络连接，如果没网，如果有网，环信有代理方法
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ConverstionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    EMConversation *conver = self.conversations[indexPath.row];
    
   EMMessage *message = conver.latestMessage;

    id msgBody = message.messageBodies[0];
    NSString *textStr = nil;
    if ([msgBody isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = msgBody;
        textStr = textBody.text;
    }else if ([msgBody isKindOfClass:[EMImageMessageBody class]]) {
        EMImageMessageBody *imgBody = msgBody;
      textStr = imgBody.displayName;
    }else if ([msgBody isKindOfClass:[EMVoiceMessageBody class]]) {
        EMVoiceMessageBody * voiceBody = msgBody;
        textStr = voiceBody.displayName;
    }
    
    //只显示名字和未读消息
    NSString *chatter = nil;
    if (conver.conversationType == eConversationTypeGroupChat) {
        EMGroup *group = [EMGroup groupWithId:conver.chatter];
        chatter = group.groupSubject;
    }else {
        chatter = conver.chatter;
    }
    NSString *str = [NSString stringWithFormat:@"%@-%ld",chatter,[conver unreadMessagesCount]];
    cell.textLabel.text = str;
    cell.detailTextLabel.text =textStr;
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EMConversation *conver = self.conversations[indexPath.row];
    GGZChatController *chatVC = [[GGZChatController alloc]initWithIsGroup:NO];
    [chatVC setHidesBottomBarWhenPushed:YES];
    //conversation.chatter如果是群，则传群的ID，如果是单聊，那就是用户名
    chatVC.buddy = [EMBuddy buddyWithUsername:conver.chatter];
    [self.navigationController pushViewController:chatVC animated:YES];
}

-(void)didUnreadMessagesCountChanged {
    [self.m_tableView reloadData];
    NSInteger count = 0;
    for (EMConversation *conversation in self.conversations) {
        count += [conversation unreadMessagesCount];
    }
    
    NSString *badgeStr = nil;
    if (count >0) {
        badgeStr = [NSString stringWithFormat:@"%ld",count];
    }
    
    self.navigationController.tabBarItem.badgeValue =badgeStr;
    
}


//即将自动连接
- (void)willAutoReconnect {
    NSLog(@"即将自动连接");
    self.title = @"即将自动连接...";
}

//网络连接完成，自动连接成功
- (void)didAutoReconnectFinishedWithError:(NSError *)error {
    
    NSLog(@"自动连接成功");
    self.title = @"聊天";
}

//监听网络状态的改变，只要网络发生变化，都会调用这个方法
- (void)didConnectionStateChanged:(EMConnectionState)connectionState {
    
    NSLog(@"类型为 =%ld",connectionState);
    switch (connectionState) {
        case eEMConnectionConnected:
            self.title = @"连接成功";
            break;
        case eEMConnectionDisconnected:
            self.title = @"未连接";
            break;
        default:
            break;
    }
    
}


#pragma mark EMChatManagerDelegate接收好友请求
//接收到好友的请求
- (void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message {
    // NSLog(@"username = %@ msg = %@",username,message);
    
    //同意添加好友或者拒绝添加好友
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友请求信息" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    //添加
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:nil];
        if (isSuccess) {
            NSLog(@"添加成功");
        }
    
    }];
    //拒绝
    UIAlertAction *rejecteAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     BOOL isSuccess = [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"我不想加" error:nil];
        if (isSuccess) {
            NSLog(@"拒绝成功");
        }
    }];
    [alert addAction:addAction];
    [alert addAction:rejecteAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
