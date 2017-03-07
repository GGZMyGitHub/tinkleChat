//
//  GGZAnyView.h
//  tinkleChat
//
//  Created by apple on 16/5/10.
//  Copyright © 2016年 GGZ. All rights reserved.
//

//点击➕弹出都选择发送图片、视频都选项都视图

#import <UIKit/UIKit.h>

@interface GGZAnyView : UIView


- (instancetype)initImageBlock:(void(^)(void))imageBlock  talkBlock:(void(^)(void))talkBlock vedioBlock:(void(^)(void))vedioBlock;

@end
