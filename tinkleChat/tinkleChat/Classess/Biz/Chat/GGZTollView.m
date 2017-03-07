//
//  GGZTollView.m
//  tinkleChat
//
//  Created by lishu tech on 16/5/9.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZTollView.h"

@interface GGZTollView ()<UITextViewDelegate>

//语音按钮
@property (nonatomic,weak)GGZButton *my_voiceBtn;

//文本输入框
@property (nonatomic,weak)UITextView *my_inputView;

//录音按钮
@property (nonatomic,weak)GGZButton *my_sendvoiceBtn;

//更多按钮
@property (nonatomic,weak)GGZButton *my_moreBtn;

@end


@implementation GGZTollView


-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor redColor];
        //添加子空间
        
         //   1、语音按钮
        GGZButton *voiceBtn = [GGZButton createGGZButton];
        
        [voiceBtn setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [self addSubview:voiceBtn];
        
         //   2、文本输入框
        UITextView *inputView = [[UITextView alloc]init];
        inputView.backgroundColor = [UIColor whiteColor];
        inputView.returnKeyType =UIReturnKeyDone;
        inputView.delegate = self;
        [self addSubview:inputView];
        
         //   3、录音按钮
        GGZButton *sendVoiceBtn = [GGZButton createGGZButton];
        [sendVoiceBtn setTitle:@"按住录音" forState:UIControlStateNormal];
        [sendVoiceBtn setTitle:@"松开发送" forState:UIControlStateHighlighted];
        

        //开始录音,(按下去)
        [sendVoiceBtn addTarget:self action:@selector(startVoice:) forControlEvents:UIControlEventTouchDown];
        
        //抬起来
        [sendVoiceBtn addTarget:self action:@selector(stopVoice:) forControlEvents:UIControlEventTouchUpInside];
        
        //退出，（录音失败）
        [sendVoiceBtn addTarget:self action:@selector(cancelVoice:) forControlEvents:UIControlEventTouchUpOutside];
        
        [self addSubview:sendVoiceBtn];
        //将录音按钮隐藏
        sendVoiceBtn.hidden = YES;
        
         //   4、更多按钮
        GGZButton *moreBtn = [GGZButton createGGZButton];
        [moreBtn setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        
        moreBtn.block = ^(GGZButton *btn){
            if (_moreBtnBlock) {
                _moreBtnBlock(); 
            }
        };
        
        [self addSubview:moreBtn];
        
        
        //赋值
        self.my_voiceBtn = voiceBtn;
        self.my_inputView = inputView;
        self.my_moreBtn = moreBtn;
        self.my_sendvoiceBtn = sendVoiceBtn;
     
        //事件处理，点击语音按钮，inputView弹出来
        voiceBtn.block = ^(GGZButton *btn){
            inputView.hidden =sendVoiceBtn.hidden;
            sendVoiceBtn.hidden = !inputView.hidden;
            
        };
        
        
    }
    return self;
}

//按钮的点击事件
//开始录音
- (void)startVoice:(GGZButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:button:)]) {
        [self.delegate toolViewWithType:GGZTollViewVoiceTypeStart button:button];
    }
    
}
//停止录音
- (void)stopVoice:(GGZButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:button:)]) {
         [self.delegate toolViewWithType:GGZTollViewVoiceTypeStop button:button];
    }
}
//结束录音
- (void)cancelVoice:(GGZButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:button:)]) {
        [self.delegate toolViewWithType:GGZTollViewVoiceTypeCancel button:button];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.my_voiceBtn.frame = CGRectMake(kWeChatPadding, kWeChatPadding/2, self.height - kWeChatPadding, self.height - kWeChatPadding);
    
    self.my_inputView.frame = CGRectMake(self.my_voiceBtn.right +kWeChatPadding, self.my_voiceBtn.top, kWeChatScreenWidth- self.my_inputView.left*2-100, self.my_voiceBtn.height);
    
    self.my_sendvoiceBtn.frame= self.my_inputView.frame;
    
    self.my_moreBtn.frame = CGRectMake(self.my_inputView.right+kWeChatPadding, self.my_voiceBtn.top, self.my_voiceBtn.width,self.my_voiceBtn.height);
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
 
    if (textView.text.length ==0 ) {
        return;
    }
    if ([textView.text hasSuffix:@"\n"]) {
        if (_sendTextBlock) {
            self.sendTextBlock(textView,GGZTollViewEditTextTypeSend);
        }
        //放弃第一响应者
        [textView resignFirstResponder];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (_sendTextBlock) {
        self.sendTextBlock (textView,GGZTollViewEditTextTypeBegin);
    }
    return YES;
}

@end
