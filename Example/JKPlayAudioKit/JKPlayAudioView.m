//
//  JKPlayAudioView.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/24.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKPlayAudioView.h"
#import "JKProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "JKPlayAudioKit.h"
#import "JKPlayAudioSlider.h"
#import "UIImageView+WebCache.h"
#import "UIView+JKViewLayout.h"
#import "JKReachabilityExtension.h"
#define kDefaultMaskType SVProgressHUDMaskTypeNone

#define JKRGBColor(r,g,b,p) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:p]

#define JK_IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
#define JK_IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height

#define KFont14_Medium  [UIFont systemFontOfSize:14 weight:UIFontWeightMedium]

@interface JKPlayAudioView ()
///转圈的菊花
@property (nonatomic, strong) UIActivityIndicatorView *activity;
///播放工具
@property (nonatomic, strong) JKPlayAudioKit *playAudio;
///播放的按钮
@property (nonatomic, strong) UIButton *playButton;
///是否在拖动
@property (nonatomic, assign) BOOL dragging;
///拖动后的百分比
@property (nonatomic, assign) CGFloat draggingProgress;
///总时间
@property (nonatomic, strong) NSString *totalTime;
///节目的封面
@property (nonatomic, strong) UIImageView *audioImageView;
///音频的题目
@property (nonatomic, strong) UILabel *audioTittle;
///音频的简介
@property (nonatomic, strong) UILabel *audioIntroduction;
///播放的进度
@property (nonatomic, strong) JKPlayAudioSlider *progressSlider;
///播放时间
@property (nonatomic, strong) UILabel *currentTimeLabel;
///总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
///当前播放的url
@property (nonatomic, strong) NSString *currentPlayUrl;
///音频的model
@property (nonatomic, strong) JKPlayAudioModel *model;
///是否同意播放 1：同意过，0：不同意
@property (nonatomic, assign) BOOL isAgreePlay;

@property (nonatomic, assign) JKPlayerState currentPlayerState;

@end
@implementation JKPlayAudioView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initUI];
    }
    return self;
}

/// 拖拽来解决右滑的冲突
- (void)panGesture {
    
}

- (void)initUI {
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    // 拖拽来解决右滑的冲突
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture)];
    [self addGestureRecognizer:pan];
    
    self.playAudio = [JKPlayAudioKit shareDownloaderManger];
    __weak typeof(self) weakSelf = self;
    self.playAudio.progressTimeBlock = ^(NSString * _Nonnull currentTime, CGFloat progress) {
        
        if (weakSelf.dragging) return;
        weakSelf.currentTimeLabel.text = currentTime;
        weakSelf.progressSlider.value = progress;
    };
    self.playAudio.totalTimeBlock = ^(NSString * _Nonnull totalTime) {
        
        weakSelf.totalTimeLabel.text = totalTime;
        weakSelf.totalTime = totalTime;
    };
    self.playAudio.enterPlayGround = ^{
        // 非手机网络直接播放
        if ([[weakSelf getCurrentNetconnType] isEqualToString:@"ReachableViaWWAN"]) {
            [weakSelf showInfoNetTip];
        }
    };
    [self.playAudio setVolume:0.5];
    
    self.audioImageView.frame = CGRectMake(10, 15, 35, 35);
    [self addSubview: self.audioImageView];
    
    //添加播放按钮
    self.playButton.jk_centerY = self.audioImageView.jk_centerY;
    [self addSubview:self.playButton];
    
    self.audioTittle.jk_left = CGRectGetMaxX(self.audioImageView.frame)+11;
    self.audioTittle.jk_top = CGRectGetMinY(self.audioImageView.frame);
    self.audioTittle.jk_width = CGRectGetMinX(self.playButton.frame)-10-11-CGRectGetMaxX(self.audioImageView.frame);
    [self addSubview:self.audioTittle];
    
    self.audioIntroduction.jk_left = CGRectGetMinX(self.audioTittle.frame);
    self.audioIntroduction.jk_top = CGRectGetMaxY(self.audioImageView.frame)-11;
    self.audioIntroduction.jk_width = self.audioTittle.jk_width;
    [self addSubview:self.audioIntroduction];
    
    self.progressSlider = [[JKPlayAudioSlider alloc]initWithFrame:CGRectMake(54, CGRectGetMaxY(self.audioImageView.frame)+8, JK_IPHONE_WIDTH-54-57, 20)];
    self.progressSlider.silderClickBlock = ^(CGFloat value) {
        
        if (weakSelf.totalTime.length == 0)return;
        weakSelf.dragging = NO;
        [weakSelf.playAudio seekWithTimeProgress:value finsh:^{}];
    };
    [self.progressSlider addTarget:self action:@selector(progressSliderSliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.progressSlider];
    
    // 播放时间
    self.currentTimeLabel.frame = CGRectMake(0,CGRectGetMidY(self.progressSlider.frame)-10, CGRectGetMinX(self.progressSlider.frame)-10, 20);
    [self addSubview:self.currentTimeLabel];
    
    // 总时间
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.progressSlider.frame)+10, CGRectGetMidY(self.progressSlider.frame)-10, self.jk_width-CGRectGetMaxX(self.progressSlider.frame)-10, 20);
    [self addSubview:self.totalTimeLabel];
    
    // 添加转圈
    [self addSubview:self.activity];
    self.activity.center = self.playButton.center;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateChange:) name:JKPlayerPlayStateChangeNotification object:nil];
}

#pragma mark 播放音频
/**
 播放音频
 
 @param sender 播放按钮对象
 */
- (void)play:(UIButton *)sender {
    
    //容错处理(音频链接不存在就返回)
    if (self.model.contentUrl.length == 0) {
        return;
    }
    
    sender.selected = !sender.isSelected;
    //点击继续播放
    [self playResumeOrPause];
    
    // 非手机网络直接播放
    if ([[self getCurrentNetconnType] isEqualToString:@"ReachableViaWWAN"] && !self.isAgreePlay) {
        self.isAgreePlay = YES;
        [self showInfoNetTip];
    }
}

/// 根据播放状态判断播放、继续或暂停
- (void)playResumeOrPause {
    if (self.playAudio.state == JKPlayerStatePause) {
        [self addPlayNumber];
        [self.playAudio resume];
    } else if (self.playAudio.state == JKPlayerStatePlaying
               || self.playAudio.state == JKPlayerStateLoading) {
        [self.playAudio pause];
    } else {
        [self playAudioSel];
    }
}

/// 按钮的点击的播放
- (void)netWorkPlay:(UIButton *)sender{
    
    sender.selected = !sender.isSelected;
    //直接去播放
    if (sender.selected) {
        if (self.playAudio.state == JKPlayerStatePause) {
            [self addPlayNumber];
            [self.playAudio resume];
        }else{
            [self playAudioSel];
        }
    }else{
        [self.playAudio pause];
    }
}

#pragma mark  播放音频
- (void)playAudioSel {
    
    [self addPlayNumber];
    self.currentPlayUrl = self.model.contentUrl;
    [self.playAudio playerWithUrl:[NSURL URLWithString:self.model.contentUrl] isCache:YES];
}

#pragma mark 增加播放量
- (void)addPlayNumber {
    
    if (self.fmAddPlayNumbertBlock) {
        self.fmAddPlayNumbertBlock(self.model.fmItemId);
    }
}

#pragma mark 设置音频的基本信息（时间除外）
/**
 设置音频的基本信息（时间除外）
 */
- (void)setAudioMessage:(JKPlayAudioModel *)model withIsPlay:(BOOL)isPlay {
    
    if ([self.currentPlayUrl isEqualToString:model.contentUrl]) {
        return;
    }
    // 不自动播放 显示UI
    if (!isPlay) {
        [self setAudioMessageUI:model];
        return;
    }
    
    // 非手机网络直接播放
    if ([[self getCurrentNetconnType] isEqualToString:@"ReachableViaWWAN"] && !self.isAgreePlay) {
        self.isAgreePlay = YES;
        [self showInfoNetTip];
    }
    
    self.playButton.selected = YES;
    [self setAudioMessageUI:model];
    //播放音频
    [self playAudioSel];
}

/// cell点击的播放
- (void)netWorkCellPlay:(JKPlayAudioModel *)model {
    [self setAudioMessageUI:model];
    //播放音频
    [self playAudioSel];
}

- (void)setAudioMessageUI:(JKPlayAudioModel *)model {
    
    self.model = model;
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
    self.progressSlider.value = 0;
    [self.audioImageView sd_setImageWithURL:[NSURL URLWithString:model.coverImg] placeholderImage:[UIImage imageNamed:@"fm_placeholder"]];
    self.audioTittle.text = model.itemTitle;
    self.audioIntroduction.text = model.itemNo;
    self.currentPlayUrl = model.contentUrl;
}

#pragma mark 进度条滑动的监听
/**
 进度条滑动的监听
 
 @param slider 进度条
 @param event 事件
 */
- (void)progressSliderSliderValueChanged:(UISlider *)slider forEvent:(UIEvent*)event {
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@",[self totalTimeFormat:self.playAudio.totalTime*slider.value]];
    
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
            //DLog(@"开始拖动");
            self.dragging = YES;
            break;
        case UITouchPhaseMoved:
            //DLog(@"正在拖动");
            break;
        case UITouchPhaseEnded:{
            //DLog(@"结束拖动");
            if (self.totalTime.length == 0){
                self.dragging = NO;
                return;
            }
            __weak typeof(self) weakSelf = self;
            [self.playAudio seekWithTimeProgress:slider.value finsh:^{
                weakSelf.dragging = NO;
            }];
        } break;
        default:
            break;
    }
}

#pragma mark 播放状态的监听
- (void)playStateChange: (NSNotification *)notice {
    NSDictionary *noticeDic = notice.userInfo;
    NSURL *url = noticeDic[@"playURL"];
    
    if (![[NSURL URLWithString:self.currentPlayUrl] isEqual:url]) {
        return;
    }
    
    JKPlayerState state = [noticeDic[@"playState"] integerValue];
    if (state == JKPlayerStatePlaying) {
        // 正在播放或者资源加载中
        self.playButton.selected = YES;
        [self showActivity:NO];
    } else if (state == JKPlayerStateLoading){
        [self showActivity:YES];
        //self.playButton.selected = YES;
    } else if (state == JKPlayerStatePause){
        // 播放暂停
        //DLog(@"播放暂停");
        self.playButton.selected = NO;
        [self showActivity:NO];
    } else if (state == JKPlayerStateStopped){
        // 播放完成
        NSLog(@"播放完成");
        self.playButton.selected = NO;
        [self showActivity:NO];
    } else {
        //self.playButton.selected = YES;
        [self showActivity:YES];
    }
}

#pragma mark 时间转换
- (NSString *)totalTimeFormat:(NSTimeInterval)time {
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)time/60,(int)time % 60];
}

- (UIButton *)playButton {
    
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-30-18,80, 30, 30)];
        [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.layer.cornerRadius = _playButton.jk_height * .5f;
        _playButton.clipsToBounds = YES;
        [_playButton setImage:[UIImage imageNamed:@"fm_audio_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"fm_audio_pause"] forState:UIControlStateSelected];
        _playButton.selected = NO;
    }
    return _playButton;
}

- (UIImageView *)audioImageView {
    if (!_audioImageView) {
        _audioImageView = [[UIImageView alloc] init];
        _audioImageView.layer.cornerRadius = 8;
        _audioImageView.clipsToBounds = YES;
    }
    return _audioImageView;
}

- (UILabel *)audioTittle {
    
    if (!_audioTittle) {
        _audioTittle = [[UILabel  alloc] initWithFrame:CGRectMake(0, 0, 100, 14)];
        _audioTittle.font = KFont14_Medium;
        _audioTittle.textColor = [UIColor whiteColor];
        // _audioTittle.backgroundColor = JKRandomColor;
        _audioTittle.textAlignment = NSTextAlignmentLeft;
    }
    return _audioTittle;
}

- (UILabel *)audioIntroduction {
    if (!_audioIntroduction) {
        _audioIntroduction = [[UILabel  alloc] initWithFrame:CGRectMake(0, 0, 100, 11)];
        _audioIntroduction.font = [UIFont systemFontOfSize:11.f];
        _audioIntroduction.textColor = JKRGBColor(153,153,153, 1);
        _audioIntroduction.textAlignment = NSTextAlignmentLeft;
        // _audioIntroduction.backgroundColor = JKRandomColor;
    }
    return _audioIntroduction;
}

- (UILabel  *)totalTimeLabel {
    
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 0, 20)];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.f];
        _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        _totalTimeLabel.textColor = JKRGBColor(153,153,153, 1);
        // _totalTimeLabel.backgroundColor = [UIColor yellowColor];
    }
    return _totalTimeLabel;
}

- (UILabel  *)currentTimeLabel {
    
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel  alloc]init];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.f];
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
        _currentTimeLabel.textColor = JKRGBColor(153,153,153, 1);
        // _currentTimeLabel.backgroundColor = [UIColor yellowColor];
    }
    return _currentTimeLabel;
}

/**
 移除监听
 */
-(void)removeObserver{
    
    [self.playAudio removeObserver];
}

-(UIActivityIndicatorView  *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        _activity.userInteractionEnabled = NO;
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}

- (void)showActivity:(BOOL)show {
    if (show) {
        [self.activity startAnimating];
    } else {
        [self.activity stopAnimating];
    }
    self.playButton.hidden = show;
}

///展示网络提示
- (void)showInfoNetTip {
    [JKProgressHUD showInfoWithStatus:@"当前为WiFi环境，请注意流量消耗"];
}

///获取当前的网络类型
- (NSString *)getCurrentNetconnType {
    return [JKReachabilityExtension shareJKReachabilityExtension].status;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

/**
 耳机🎧控制的远程事件
 
 @param event 远程事件
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    //DLog(@"event tyipe:::%ld   subtype:::%ld",(long)event.type,(long)event.subtype);    //type==2  subtype==单击暂停键：103，双击暂停键104
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:{
                if (self.playAudio.currentAppStatus) {
                    return;
                }
                //DLog(@"play---------%ld",(long)self.currentPlayerState);
                if (self.playAudio.state == JKPlayerStatePlaying || self.playAudio.state == JKPlayerStateLoading) {
                    self.currentPlayerState = self.playAudio.state;
                    [self.playAudio pause];
                }else if (self.playAudio.state == JKPlayerStatePause && (self.currentPlayerState == JKPlayerStatePlaying || self.currentPlayerState == JKPlayerStateLoading)){
                    [self.playAudio resume];
                }
            }break;
            case UIEventSubtypeRemoteControlPause:{
                //DLog(@"Pause---------");
            }break;
            case UIEventSubtypeRemoteControlStop:{
                //DLog(@"Stop---------");
            }break;
            case UIEventSubtypeRemoteControlTogglePlayPause:{
                //单击暂停键：103
                //DLog(@"单击暂停键：103");
            }break;
            case UIEventSubtypeRemoteControlNextTrack:{
                //DLog(@"双击暂停键：104");
            }break;
            case UIEventSubtypeRemoteControlPreviousTrack:{
                //DLog(@"三击暂停键：105");
            }break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:{
                //DLog(@"单击，再按下不放：108");
            }break;
            case UIEventSubtypeRemoteControlEndSeekingForward:{
                //DLog(@"单击，再按下不放，松开时：109");
            }break;
            default:
                break;
        }
    }
}


@end
