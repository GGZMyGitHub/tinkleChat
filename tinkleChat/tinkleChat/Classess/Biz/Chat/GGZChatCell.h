//
//  GGZChatCell.h
//  tinkleChat
//
//  Created by lishu tech on 16/5/8.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GGZChatCellShowImageDelegate <NSObject>

//显示大图片
- (void)chatCellWithMessage:(EMMessage *)message;

@end

@interface GGZChatCell : UITableViewCell

//加载的消息
@property (nonatomic,strong)EMMessage* message;

//cell的宽高
@property (nonatomic,assign)CGFloat rowHeight;

@property (nonatomic,assign)id<GGZChatCellShowImageDelegate>delegate;

@property (nonatomic,copy)NSString *cellID;


@end











