//
//  GGZContentView.m
//  tinkleChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZContentView.h"

@implementation GGZContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.showsHorizontalScrollIndicator=NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

//往view中添加子控件
- (void)didAddSubview:(UIView *)subview {
    
    [self scrollViewToFit];
}

//从view中移除子控件
- (void)willRemoveSubview:(UIView *)subview  {
    [self scrollViewToFit];
}

- (void)scrollViewToFit {
    CGRect contentRect = CGRectZero;
    
    for (UIView *view in self.subviews) {
        //返回一个包括二者的rect
        
      contentRect = CGRectUnion(contentRect, view.frame);
    }
    CGFloat contentRectHeight = contentRect.size.height;
    //如果当前的高度大雨scrollView的高度，那么就加一个间距
    if (contentRectHeight >self.height) {
        contentRectHeight +=kWeChatPadding;
    }else {
        contentRectHeight = self.height;
    }
    self.contentSize = CGSizeMake(kWeChatScreenWidth, contentRectHeight);
    
    
}
@end
