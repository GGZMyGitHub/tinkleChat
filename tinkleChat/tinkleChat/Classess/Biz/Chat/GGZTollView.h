//
//  GGZTollView.h
//  tinkleChat
//
//  Created by lishu tech on 16/5/9.
//  Copyright © 2016年 GGZ. All rights reserved.
//


//枚举定义三个录音按钮
typedef enum {
    
    GGZTollViewVoiceTypeStart,
    GGZTollViewVoiceTypeStop,
    GGZTollViewVoiceTypeCancel
    
}GGZTollViewVoiceType;
typedef enum {
    
    GGZTollViewEditTextTypeSend,
    GGZTollViewEditTextTypeBegin
    
}GGZTollViewEditTextType;

#import <UIKit/UIKit.h>

//键盘的回调
typedef void(^GGZTollViewSendTextBlock)(UITextView *text,GGZTollViewEditTextType);

//录音的回调,block方式
typedef void(^GGZTollViewViewVoiceBlock)(GGZTollViewVoiceType,GGZButton *);

typedef void(^GGZTollViewMoreBtnBlock)();


//代理方式
@protocol GGZTollViewVoiceDelegate <NSObject>

- (void)toolViewWithType:(GGZTollViewVoiceType)type button:(GGZButton *)btn;

@end

@interface GGZTollView : UIView

//发送消息的回调
@property (nonatomic,copy)GGZTollViewSendTextBlock sendTextBlock;

@property (nonatomic,assign)id<GGZTollViewVoiceDelegate>delegate;

//点击更多按钮的回调
@property (nonatomic,copy)GGZTollViewMoreBtnBlock moreBtnBlock;

@end
