//
//  GGZAnyView.m
//  tinkleChat
//
//  Created by apple on 16/5/10.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZAnyView.h"

#define GGZAnyViewSubViewHW (kWeChatScreenWidth -4*kWeChatPadding)/3

@interface GGZAnyView ()

//图片按钮
@property (nonatomic,weak)GGZButton *imgBtn;
//语音按钮
@property (nonatomic,weak)GGZButton *talkBtn;
//视频按钮
@property (nonatomic,weak)GGZButton *vedioBtn;

@end

@implementation GGZAnyView

- (instancetype)initImageBlock:(void(^)(void))imageBlock  talkBlock:(void(^)(void))talkBlock vedioBlock:(void(^)(void))vedioBlock {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor grayColor];
        
        GGZButton *imageBtn = [GGZButton createGGZButton];
        imageBtn.backgroundColor = [UIColor redColor];
        [imageBtn setTitle:@"图片" forState:UIControlStateNormal];
        [self addSubview:imageBtn];
        
        GGZButton *talkChatBtn = [GGZButton createGGZButton];
        talkChatBtn.backgroundColor = [UIColor greenColor];
        [talkChatBtn setTitle:@"语音" forState:UIControlStateNormal];

        [self addSubview:talkChatBtn];
        
        GGZButton *vedioChatBtn = [GGZButton createGGZButton];
        vedioChatBtn.backgroundColor = [UIColor blueColor];
        [vedioChatBtn setTitle:@"视频" forState:UIControlStateNormal];

        [self addSubview:vedioChatBtn];
        
        
        self.imgBtn = imageBtn;
        self.talkBtn = talkChatBtn;
        self.vedioBtn = vedioChatBtn;
        imageBtn.block = ^(GGZButton *btn){
            if (imageBlock) {
                imageBlock();
            }
        };
        talkChatBtn.block = ^(GGZButton *btn){
            if (talkBlock) {
                talkBlock();
            }
        };
        vedioChatBtn.block = ^(GGZButton *btn){
            if (vedioBlock) {
                vedioBlock();
            }
        };
    
    
    }
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imgBtn.frame = CGRectMake(kWeChatPadding, kWeChatPadding, GGZAnyViewSubViewHW, GGZAnyViewSubViewHW);
  //  NSLog(@"%f",self.imgBtn.frame.size.height);
    self.talkBtn.frame = CGRectMake(self.imgBtn.right + kWeChatPadding, self.imgBtn.top, GGZAnyViewSubViewHW, GGZAnyViewSubViewHW);
    self.vedioBtn.frame = CGRectMake(self.talkBtn.right +kWeChatPadding, self.talkBtn.top, GGZAnyViewSubViewHW, GGZAnyViewSubViewHW);
    

    
}













@end
