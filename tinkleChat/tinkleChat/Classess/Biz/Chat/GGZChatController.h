//
//  GGZChatController.h
//  tinkleChat
//
//  Created by lishu tech on 16/5/10.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZRootController.h"

@interface GGZChatController : GGZRootController

//获取好友名称，放到self.title上面
@property (nonatomic,strong)EMBuddy *buddy;

@property (nonatomic,strong)EMGroup *group;

- (instancetype)initWithIsGroup:(BOOL)isGroup;

@end
