//
//  GGZChatController.m
//  tinkleChat
//
//  Created by lishu tech on 16/5/10.
//  Copyright © 2016年 GGZ. All rights reserved.
//

#import "GGZChatController.h"

#import "GGZTollView.h"

#import "GGZChatCell.h"

#import "EMCDDeviceManager.h"

#import "GGZAnyView.h"

#import "MWPhotoBrowser.h"

#import "GGZCallController.h"

@interface GGZChatController ()<UITableViewDelegate,UITableViewDataSource,IEMChatProgressDelegate,EMChatManagerDelegate,GGZTollViewVoiceDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,GGZChatCellShowImageDelegate,MWPhotoBrowserDelegate,EMCallManagerDelegate>

//数据源中的数组，数据源
@property (nonatomic,strong)NSMutableArray *messageData;

@property (nonatomic,strong)UITableView *chatTableView;

@property (nonatomic,strong)GGZTollView *toolView;

//更多功能
@property (nonatomic,weak)GGZAnyView *chatAnyView;

//更多功能需要拿到的TextView
@property (nonatomic,weak)UITextView *anyNeedtextView;

//保存图片等message
@property (nonatomic,strong)EMMessage *photoMessage;

//实时通话的Session
@property (nonatomic,strong)EMCallSession *callSession;

@property (nonatomic,assign)BOOL isGroup;


@end

@implementation GGZChatController

- (void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

- (instancetype)initWithIsGroup:(BOOL)isGroup {
    if (self = [super init]) {
        self.isGroup = isGroup;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.contentView.top = 0;
    self.chatAnyView.top = kWeChatScreenHeight;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.buddy.username;
  //  NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
  //  NSLog(@"--->%@",path);
    //创建聊天界面的TableView
    [self createTableView];
    
    
    //创建自定义的文本输入框和发送语音按钮的布局
    [self createUI];
    //添加通知
    [self createNotic];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //创建更多功能➕
    [self createMoreFunction];
    
}

- (void)createTableView {
    
    _chatTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWeChatScreenWidth, kWeChatScreenHeight -64 -44) style:UITableViewStylePlain];
    
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _chatTableView.delegate =self;
    _chatTableView.dataSource = self;
    [self.contentView addSubview:_chatTableView];

   // _chatTableView.delegate =self;
  //  _chatTableView.dataSource = self;
   // [self.contentView addSubview:_chatTableView];

}

- (void)createMoreFunction {
    GGZAnyView *anyView = [[GGZAnyView alloc]initImageBlock:^{
        NSLog(@"你点击了图片");
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate =self;
        [self presentViewController:picker animated:YES completion:nil];
        
    } talkBlock:^{
        NSLog(@"你点击了语音");
        //实时通话的类callManager
        EMCallSession *callSin = [[EaseMob sharedInstance].callManager asyncMakeVoiceCall:self.buddy.username timeout:20 error:nil];
        self.callSession = callSin;
    } vedioBlock:^{
        NSLog(@"你点击了视频");
        [[EaseMob sharedInstance].callManager asyncMakeVideoCall:self.buddy.username timeout:20 error:nil];
        
    }];
    anyView.frame =CGRectMake(0, kWeChatScreenHeight, kWeChatScreenWidth, 271);    [[UIApplication sharedApplication].keyWindow addSubview:anyView];
    self.chatAnyView = anyView;
    //1、先在滚动视图的时候隐藏
    //2、在输入文字的时候同时点击更多功能
    //3、在文本框同时显示的时候隐藏更多功能
    //4、当开始编辑的时候应该隐藏掉更多功能
    
    //moreBtn的点击
    __weak typeof (self) weakSelf = self;
    self.toolView.moreBtnBlock = ^(){
        if (weakSelf.anyNeedtextView) {
            [weakSelf.anyNeedtextView resignFirstResponder];
        }
        weakSelf.contentView.top = -271;

        anyView.top = kWeChatScreenHeight - 271;
    };
    
    
    //添加实时通话代理
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];

}

#pragma mark -实时通话的代理方法 EMCallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error {
    NSLog(@"callSession = %@ reason = %ld stauts = %ld",callSession,reason,callSession.status);
    

    if (callSession.status == eCallSessionStatusConnected) {
        GGZCallController *callCtr = [[GGZCallController alloc]init];
        callCtr.currentSession = callSession;
        
        [self presentViewController:callCtr animated:YES completion:nil];

    }
    
}




- (void)createUI {

    GGZTollView *toolView = [[GGZTollView alloc]init];
    toolView.frame = CGRectMake(0 , _chatTableView.bottom, _chatTableView.width, 44);
    
    //自己定义的代理GGZTollViewVoiceDelegate
    toolView.delegate = self;
    //发送消息
    toolView.sendTextBlock = ^(UITextView *textView,GGZTollViewEditTextType type){
        if (type == GGZTollViewEditTextTypeSend) {
            [self sendTextMsg:textView];
        }else {
            if (self.chatAnyView.top <kWeChatScreenHeight) {
                self.chatAnyView.top =kWeChatScreenHeight;
            }
            self.anyNeedtextView = textView;
        }
        
    };
    
    [self.contentView addSubview:toolView];
    
    //获取本地聊天消息,单聊
    NSString *chatter =self.buddy.username;
    //获取当前对象的会话
   EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter: chatter conversationType:eConversationTypeChat];
    
    //加载当前会话的所有聊天记录
   NSArray *conversationArr = [conversation loadAllMessages];
    
    for (EMMessage *msg in conversationArr) {
        [conversation markMessageWithId:msg.messageId asRead:YES];
    }

    
    //初始化数据源
    self.messageData = [NSMutableArray arrayWithArray:conversationArr];
    [self scrollBottom];
    
    self.toolView = toolView;
}

- (void)createNotic {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //隐藏
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //取出图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //发送图片
    [self sendImage:image];
    
}

- (void)sendImage:(UIImage *)image {
    
    EMChatImage *chatImg = [[EMChatImage alloc]initWithUIImage:image displayName:@"[IMAGE]"];
    
    //创建消息体
    //第一个参数是原图片
    //第二个参数是预览图片，如果传nil，环信默认帮我们生成预览图片
    EMImageMessageBody *body = [[EMImageMessageBody alloc]initWithImage:chatImg thumbnailImage:nil] ;
    
    NSString *reciver = self.isGroup ? self.group.groupId : self.buddy.username;
    
    
    //创建EMMessage对象
    EMMessage *msg = [[EMMessage alloc]initWithReceiver:reciver bodies:@[body]];

    msg.messageType = self.isGroup ? eMessageTypeGroupChat : eMessageTypeChat;
    
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msg progress:self prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"图片即将发送");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"图片已经发送");
            
            //添加到数据源中
            [self.messageData addObject:message];
            //刷新表格
            [self.chatTableView reloadData];
            //滚动到底部
            [self scrollBottom];
        }
       
    } onQueue:nil];
    
}

#pragma mark -发送消息的进度
- (void)setProgress:(float)progress forMessage:(EMMessage *)message forMessageBody:(id<IEMMessageBody>)messageBody {
    NSLog(@"progress ==%f",progress);
}

#pragma mark -EMChatManagerDelegate代理方法
//接受消息的回调
- (void)didReceiveMessage:(EMMessage *)message {
    [self.messageData addObject:message];
    [self.chatTableView reloadData];
    //滚动到最后一行
    [self scrollBottom];
}

//发送一条消息
- (void)scrollBottom {
    if (self.messageData.count == 0) {
        return;
    }
    //滚动到最后一行
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageData.count - 1 inSection:0];
    [_chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}
//发送文字消息

-(void)sendTextMsg :(UITextView *)textView {
    //发送消息
    //   NSLog(@"你点击了完成按钮");
    
    //5、内容对象
    EMChatText *text = [[EMChatText alloc]initWithText:[textView.text substringToIndex:textView.text.length - 1]];
    
    //4、消息体
    //        EMTextMessageBody    文本消息体
    //        EMImageMessageBody   图片消息体
    //        EMVideoMessageBody   视频消息体
    //        EMVoiceMessageBody   语音消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc]initWithChatObject:text];
    //3、接收者
    NSString *reciver = self.isGroup ? self.group.groupId : self.buddy.username;
    
    
    //2、EMMessage对象
    EMMessage *msg = [[EMMessage alloc]initWithReceiver:reciver bodies:@[textBody]];
    
    msg.messageType = self.isGroup ? eMessageTypeGroupChat : eMessageTypeChat;
    
    
    //1、异步发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msg progress:self prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"消息即将完成");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"消息发送完成");
        
        //添加数据
        [self.messageData addObject:message];
        //刷新表格
        [_chatTableView reloadData];
        
        //发送消息
        [self scrollBottom];
        //清空数据
        textView.text = nil;
    } onQueue:nil];
}

#pragma mark 显示大图片
- (void)chatCellWithMessage:(EMMessage *)message {
    self.photoMessage = message;
  //  NSLog(@"messagedelegate = %@",message);
    MWPhotoBrowser *broweser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    [self.navigationController pushViewController:broweser animated:YES];
    
}

#pragma mark - MWPhotoBrowserDelegate 图片浏览器的代理方法
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
  EMImageMessageBody *body = self.photoMessage.messageBodies[0];
    
    NSString *path = body.localPath;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:path]) {
        //设置图片浏览器的图片对象（本地获取的）
     return [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:path]];
        
    }else {
        //设置图片浏览器中的图片对象（使用网络请求）
        path = body.remotePath;
        return [MWPhoto photoWithURL:[NSURL URLWithString:path]];
    }

}

//键盘回调的方法
- (void)keyboardWillChangeFrameNotification: (NSNotification *)notic {
    
   CGRect keyboardFrame = [notic.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //
    if (keyboardFrame.origin.y < kWeChatScreenHeight) {
        self.contentView.top = -keyboardFrame.size.height;
    }else {
        self.contentView.top = 0;
    }
    
}

//取消键盘第一响应者，将键盘放下去
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //取消所有的第一响应者
    [self.contentView endEditing:YES];
    [UIView animateWithDuration:1.0 animations:^{
        self.chatAnyView.top = kWeChatScreenHeight;
        if (self.contentView.top <0) {
            self.contentView.top = 0;
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _chatTableView.separatorStyle = UITableViewCellSelectionStyleNone;

    
    // 判断cell类型，文字、语音、图片等，是哪个类型创建哪个类型，以后再发文字或者图片就可以重用了
    static NSString *cellIDText = @"TextID";
    static NSString *cellIDVoice = @"VoiceID";
    static NSString *cellIDImage = @"ImageID";
    GGZChatCell *cell = [[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if (cell.cellID == cellIDText) {
        cell=[tableView dequeueReusableCellWithIdentifier:cellIDText];
    }else if (cell.cellID == cellIDVoice) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIDVoice];
    }else if (cell.cellID ==cellIDImage) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIDImage];
    }
    if (cell == nil) {
        if (cell.cellID == cellIDText) {
            cell=[[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDText];
        }
        if (cell.cellID == cellIDVoice) {
            cell=[[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDVoice];
        }
        if (cell.cellID == cellIDImage) {
            cell=[[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDImage];
        }
  
    }
    cell.message = self.messageData[indexPath.row];

    //设置显示大图片的代理
    cell.delegate =self;
    
    //去掉cell上面点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIDText = @"TextID";
    static NSString *cellIDVoice = @"VoiceID";
    static NSString *cellIDImage = @"ImageID";
    GGZChatCell *cell = [[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (cell.cellID == cellIDText) {
        cell=[tableView dequeueReusableCellWithIdentifier:cellIDText];
    }else if (cell.cellID == cellIDVoice) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIDVoice];
    }else if (cell.cellID ==cellIDImage) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIDImage];
    }
    if (cell == nil) {
        if (cell.cellID == cellIDText) {
            cell=[[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDText];
        }
        if (cell.cellID == cellIDVoice) {
            cell=[[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDVoice];
        }
        if (cell.cellID == cellIDImage) {
            cell=[[GGZChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDImage];
        }
        
    }

    cell.message = self.messageData[indexPath.row];
    
    return cell.rowHeight;

}

#pragma mark -GGZTollViewVoiceDelegate代理方法

- (void)toolViewWithType:(GGZTollViewVoiceType)type button:(GGZButton *)btn {
    switch (type) {
            case GGZTollViewVoiceTypeStart:
            {
            //    NSLog(@"开始录音");
                int fileNameNum = arc4random() % 1000;
             NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
                
                [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:[NSString stringWithFormat:@"%d%d",fileNameNum,(int)time]completion:^(NSError *error) {
                    if (!error) {
                        NSLog(@"录音成功");
                    }
                }];

            }
            break;
            case GGZTollViewVoiceTypeStop:
            {
                NSLog(@"停止录音");
                [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
                    NSLog(@"recordPath = %@ duration = %ld",recordPath,(long)aDuration);
                
                    [self sendVoiceWithFilePath:recordPath duration:aDuration];
                    
                    
                }];
            }
            break;
            case GGZTollViewVoiceTypeCancel:
            {
                NSLog(@"退出录音");

            }
            break;
            
        default:
            break;
    }
}

//发送语音消息
- (void)sendVoiceWithFilePath:(NSString *)path duration :(NSInteger)aDuration {
    
    EMChatVoice *voice = [[EMChatVoice alloc]initWithFile:path displayName:@"[AUDIO]"];
    
    //需要设置语音时间
    voice.duration = aDuration;
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc]initWithChatObject:voice];
    NSString *reciver = self.isGroup ? self.group.groupId : self.buddy.username;
    
    EMMessage *message =[[EMMessage alloc]initWithReceiver:reciver bodies:@[voiceBody]];
    message.messageType = self.isGroup ? eMessageTypeGroupChat : eMessageTypeChat;

    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:self prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"即将发送");
        
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"发送完成");
        
        //添加数据
        
        [self.messageData addObject:message];
        
        // 刷新表格
        [self.chatTableView reloadData];
        
        //滚动到最后一行
        [self scrollBottom];
        
    } onQueue:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
