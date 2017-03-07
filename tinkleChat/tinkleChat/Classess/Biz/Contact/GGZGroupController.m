//
//  GGZGroupController.m
//  tinkleChat
//
//  Created by apple on 16/5/15.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZGroupController.h"
#import "GGZChatController.h"

@interface GGZGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *groupArr;

@end

@implementation GGZGroupController

-(void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GGZButton *rightBtn = [GGZButton createGGZButton];
    rightBtn.frame = CGRectMake(kWeChatScreenWidth - 50, 0, 60, 30);

    [rightBtn setTitle:@"创建群" forState: UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    
    //显示数据
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWeChatScreenWidth, kWeChatScreenHeight) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.contentView addSubview:tableView];
    
    //获取 群列表
    NSArray *arr =[[EaseMob sharedInstance].chatManager groupList];
    self.groupArr =[NSMutableArray arrayWithArray:arr];
    
    if (self.groupArr.count ==0) {
        //从服务器端获取数据
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
            [self.groupArr addObjectsFromArray:groups];
            [tableView reloadData];
            NSLog(@"--__%@",self.groupArr);
            
        } onQueue:nil];
    }

    rightBtn.block = ^(GGZButton *btn){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建群" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入群名称";
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"自我介绍";
        }];
        UITextField *groupNameFiled = [alert.textFields firstObject];
        UITextField *detailFiled = [alert.textFields lastObject];
        
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            EMGroupStyleSetting *groupSetting = [[EMGroupStyleSetting alloc]init];
            groupSetting.groupStyle =eGroupStyle_PublicJoinNeedApproval;
            groupSetting.groupMaxUsersCount=400;
            
            [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:groupNameFiled.text description:detailFiled.text invitees:@[@"ggz",@"ios123"] initialWelcomeMessage:@"欢迎光临" styleSetting:groupSetting completion:^(EMGroup *group, EMError *error) {
                if (!error) {
                    NSLog(@"创建群组成功");
                    [self.groupArr addObject:group];
                       [tableView reloadData];
                }
            } onQueue:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES  completion:nil];
        
    };


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    EMGroup *group = self.groupArr[indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@",group.groupSubject];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GGZChatController *chatCtr =[[GGZChatController alloc]initWithIsGroup:YES];
    
    [chatCtr setHidesBottomBarWhenPushed:YES];
    chatCtr.group = self.groupArr[indexPath.row];
    [self.navigationController pushViewController:chatCtr animated:YES];


}

@end

















