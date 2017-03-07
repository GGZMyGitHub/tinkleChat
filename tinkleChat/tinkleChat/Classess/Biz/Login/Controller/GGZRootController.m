 //
//  GGZRootController.m
//  tinkleChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZRootController.h"


@interface GGZRootController ()

@end

@implementation GGZRootController

- (void)viewDidLoad {
    [super viewDidLoad];

    //GGZContentView，是UIScrollView，登陆界面，通过contentView向子视图传过去
    GGZContentView *contentView = [[GGZContentView alloc]init];
    contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64);
    contentView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:contentView];
    
    self.contentView = contentView;

    //在根视图里面创建AppDelegate对象，其他视图继承它都会有这个对象，再通过myAppDelegate传过去
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    self.myAppDelegate = app;
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












