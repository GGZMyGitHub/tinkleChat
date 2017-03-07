//
//  GGZChatCell.m
//  tinkleChat
//
//  Created by lishu tech on 16/5/8.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZChatCell.h"

#import "UIImage+XMGResizing.h"

#import "NSDateUtilities.h"

#import "EMCDDeviceManager.h"

#import "UIButton+WebCache.h"

@interface GGZChatCell ()

//时间
@property (nonatomic,weak)UILabel *chatTime;

//消息
@property (nonatomic,weak)GGZButton *chatButton;

//头像
@property (nonatomic,weak)GGZButton *chatIcon;

@end

@implementation GGZChatCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //添加子空间
        
        //时间显示
        [self createTimeLable];
        
        
        //聊天消息
        [self createChatButton];
        
        //头像
        [self createIconButton];
       // self.contentView.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

- (void)createTimeLable {
    
   UILabel * timeLable =[[UILabel alloc]init];
    timeLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:timeLable];
    self.chatTime = timeLable;
}

- (void)createChatButton {
    GGZButton *chatBtn = [GGZButton createGGZButton];
    chatBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    chatBtn.tag = 100;
    //需要设置内容的内边距
    chatBtn.contentEdgeInsets = UIEdgeInsetsMake(15, 20, 25, 20);
    
    //发送文字多了换行
    chatBtn.titleLabel.numberOfLines = 0;
    
    [chatBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:chatBtn];
    self.chatButton =chatBtn;
}

//头像按钮的点击，播放语音
- (void)chatBtnClick:(GGZButton *)button {
   // NSLog(@"message = %@",self.message);
    
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        
        [self playVoice:body];
        
    }else if ([body isKindOfClass:[EMImageMessageBody class]]) {
        
     //   EMImageMessageBody *imageBody = body;
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatCellWithMessage:)]) {
           
            //显示大图片
            [self.delegate chatCellWithMessage:self.message];
        }
    }
    
    
}
//播放语音
- (void)playVoice:(EMVoiceMessageBody *)body {
    EMVoiceMessageBody *voiceBody = body;
    //获取本地路径
    NSString *path = voiceBody.localPath;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //判断path是否存在
    //如果不存在,在从服务器中取出来，如果存在，直接用本地路径
    if (![fileMgr fileExistsAtPath:path]) {
        //从远程服务器获取地址
        path =voiceBody.remotePath;
    }
    //  NSLog(@"path = %@",path);
    
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        if (!error) {
            NSLog(@"播放成功");
        }else {
            NSLog(@"--->%@",error);
        }
    }];

    
}

- (void)createIconButton {
    
    GGZButton *iconBtn = [GGZButton createGGZButton];
    [iconBtn setImage:[UIImage imageNamed:@"chatListCellHead"] forState:UIControlStateNormal];
    
    [self addSubview:iconBtn];
    self.chatIcon = iconBtn;

}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.chatTime.frame = CGRectMake(0, 0, kWeChatScreenWidth, 30);
    
}

- (void)setMessage:(EMMessage *)message {
    
    _message = message;
    
    
    //获取消息体
    id body = message.messageBodies[0];
//    
//    NSString *time = [self conversationTime:message.timestamp];
//    NSString *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTime"];
//    if (![time isEqualToString:lastTime]) {
//        self.chatTime.text = time;
//        [[NSUserDefaults standardUserDefaults] setObject:time forKey:@"lastTime"];
//        
//    }
    self.chatTime.text = [self conversationTime:message.timestamp];
    
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        
        //文本类型
        EMTextMessageBody *textBody = body;
        
        [self.chatButton setTitle:textBody.text forState:UIControlStateNormal];
        
        //去除图片显示在文字上
        [self.chatButton setImage:nil forState:UIControlStateNormal];
        
        //通过第三方工具类转化成时间NSDateUtilities.h
//        double time = message.timestamp;
//        if (message.timestamp > 140000000000) {
//            time = message.timestamp/1000;
//        }
//        NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
//        NSString *timeStr = [date dateTimeString2];
        

        
        //真实尺度
        CGSize size = [textBody.text boundingRectWithSize:CGSizeMake(kWeChatScreenWidth/2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil].size;
        
        CGSize realSize = CGSizeMake(size.width+40, size.height+40);
        
        self.chatButton.size = realSize;
        self.cellID = @"TextID";
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        EMVoiceMessageBody *voiceBody = body;
        
        //设置图片和时间
        [self.chatButton setImage:[UIImage imageNamed:@"chat_receiver_audio_playing_full"] forState:UIControlStateNormal];
        [self.chatButton setTitle:[NSString stringWithFormat:@"%ld'",voiceBody.duration] forState:UIControlStateNormal];
        
        self.chatButton.size = CGSizeMake(kWeChatAllSubviewHeight +40, kWeChatAllSubviewHeight+40);
        self.chatButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
        self.chatButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        self.cellID = @"VoiceID";
    }else if ([body isKindOfClass:[EMImageMessageBody class]]) {
        EMImageMessageBody *imgBody = body;
   //     imgBody.localPath;  本地大图片
  // imgBody.thumbnailLocalPath  本地的预览图
  //  imgBody.remotePath  服务端端大图
   // imgBody.thumbnailRemotePath  服务端端预览图
        self.chatButton.size =CGSizeMake(kWeChatAllSubviewHeight*2 +40, kWeChatAllSubviewHeight*2 +40);
     
        //获得本地预览图片的地址
        NSString *path = imgBody.thumbnailLocalPath;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        //使用SDWebImage下载图片
        //设置URL
        NSURL *url = nil;
        if ([fileMgr fileExistsAtPath:path]) {
            
            url = [NSURL fileURLWithPath:path];
        }else{
            url= [NSURL URLWithString:imgBody.thumbnailRemotePath];
        }
        
        [self.chatButton sd_setImageWithURL:url forState:UIControlStateNormal];
        self.cellID = @"ImageID";

    }

    NSString *chatter = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    [self.chatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([message.from isEqualToString:chatter]) {
        //自己发的消息
        [self setBtnImage:@"SenderTextNodeBkg"];
        //头像在右边
        self.chatIcon.frame = CGRectMake(kWeChatScreenWidth - kWeChatAllSubviewHeight - kWeChatPadding, 30+kWeChatPadding, kWeChatAllSubviewHeight, kWeChatAllSubviewHeight);
        
        //聊天消息在左边
        self.chatButton.left = kWeChatScreenWidth - self.chatButton.width - self.chatIcon.width - kWeChatPadding*2;
        
    }else {
        //别人发的消息
        //头像在左边
        self.chatIcon.frame = CGRectMake(kWeChatPadding, 30+kWeChatPadding, kWeChatAllSubviewHeight, kWeChatAllSubviewHeight);
        
        //聊天消息在右边
        
        self.chatButton.left =self.chatIcon.right + kWeChatPadding;
        
        [self setBtnImage:@"ReceiverTextNodeBkg"];
        
    }
    //Y轴
    self.chatButton.top =self.chatIcon.top;
}

//背景图片
- (void)setBtnImage:(NSString *)name{
    [self.chatButton setBackgroundImage:[UIImage resizingImageWithName:name] forState:UIControlStateNormal];
   NSString * hightName = [NSString stringWithFormat:@"%@HL",name];
    [self.chatButton setBackgroundImage:[UIImage resizingImageWithName:hightName] forState:UIControlStateHighlighted];
}

- (CGFloat)rowHeight {
    return self.chatButton.bottom +kWeChatPadding;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//聊天时间的设置
- (NSString *)conversationTime:(long long)time {
    //今天 16:32
    //昨天16:50
    //前天以前11：00
    
    //1、创建一个日历对象
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //2、获取当前时间
    NSDate *currentDate = [NSDate date];
    //3、获取当前时间的年月日
   NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;

    //4、获取发送时间
    NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:time/1000];
    
    //5、获取发送时间的年月日
   NSDateComponents *sendComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:sendDate];
    NSInteger sendYear = sendComponents.year;
    NSInteger sendMonth = sendComponents.month;
    NSInteger sendDay = sendComponents.day;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    //6、当前时间与发送时间的对比
    if (currentYear == sendYear && currentMonth==sendMonth && currentDay == sendDay) {
        fmt.dateFormat = @"今天 HH:mm";
    }else if (currentYear == sendYear && currentMonth==sendMonth && currentDay == sendDay+1){
        fmt.dateFormat = @"昨天 HH:mm";

    }else {
        fmt.dateFormat = @"昨天以前 HH:mm";
    }

    
    return [fmt stringFromDate:sendDate];
}

@end
