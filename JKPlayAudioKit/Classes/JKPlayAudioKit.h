//
//  JKPlayAudioKit.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/19.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "JKPlayAudioFile.h"
#import "UIView+JKViewLayout.h"
#import "JKPlayAudioModel.h"
#import "JKPlayAudioDownLoader.h"
#import "JKAudioRotatingView.h"

NS_ASSUME_NONNULL_BEGIN
//播放状态改变的通知
#define JKPlayerPlayStateChangeNotification @"PlayStateChangeNotification"
///当前时间和进度的回调
typedef void(^ProgressTimeBlock)(NSString *currentTime,CGFloat progress);
///总时间
typedef void(^TotalTimeBlock)(NSString *totalTime);
///进入前台的blcok
typedef void(^EnterPlayGround)(void);

/**
 播放器的状态
 因为UI界面需要加载状态显示, 所以需要提供加载状态
 */
typedef NS_ENUM(NSInteger, JKPlayerState) {
    // 未知(比如都没有开始播放音视频资源)
    JKPlayerStateUnknown  = 0,
    // 正在加载
    JKPlayerStateLoading  = 1,
    // 正在播放
    JKPlayerStatePlaying  = 2,
    // 停止
    JKPlayerStateStopped  = 3,
    // 暂停
    JKPlayerStatePause    = 4,
    // 失败(比如没有网络缓存失败, 地址找不到)
    JKPlayerStateFailed   = 5
};

@interface JKPlayAudioKit : NSObject

+ (instancetype)shareDownloaderManger;

#pragma mark 应用进入前台
- (void)appDidEnterPlayGround;

#pragma mark 进入后台
- (void)appEnteredBackground;

/**
 播放视频/上一首/下一首把对应的url传进来即可

 @param url 音视频的 url
 @param isCache 是否缓存：YES：缓存，NO：不缓存
 */
- (void)playerWithUrl:(NSURL *)url isCache:(BOOL)isCache;

/**
 暂停播放
 */
- (void)pause;

/**
 继续播放
 */
- (void)resume;

/**
 停止播放
 */
- (void)stop;

/**
 快进
 
 @param timeDiffer 快进的时间
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;

/**
 指定播放进度
 
 @param progress 进度值
 */
- (void)seekWithTimeProgress:(float)progress finsh:(void(^)(void))finsh;

/**
 移除监听
 */
- (void)removeObserver;

/**
 销毁单例
 */
+ (void)destroy;

#pragma mark api 数据提供 (通过属性外界获取的值是 拉模式，通过block,代理，通知是 推模式)

/**
 播放器
 */
@property(nonatomic,strong,nullable) AVPlayer *player;

/**
 是否静音 YES：静音 NO：不静音
 */
@property(nonatomic,assign) BOOL muted;

/**
 音量调整
 */
@property(nonatomic,assign) float volume;

/**
 倍速值：1.0、2.0、3.0
 */
@property(nonatomic,assign) float rate;

/**
 总时长
 */
@property(nonatomic,assign,readonly) NSTimeInterval totalTime;

/**
 ‭格式化后的 总时间 00:00
 */
@property(nonatomic,strong,readonly) NSString *totalTimeFormat;

/**
 当前播放的时长
 */
@property(nonatomic,assign,readonly) NSTimeInterval currentTime;

/**
 格式化后的当前 时间 00:00
 */
@property(nonatomic,strong,readonly) NSString *currentTimeFormat;

/**
 当前播放的url地址
 */
@property(nonatomic,strong,readonly) NSURL *url;

/**
 当前播放的进度
 */
@property(nonatomic,assign,readonly) float progress;

/**
 当前已经缓冲的进度
 */
@property(nonatomic,assign,readonly) float loadDataProgress;

/**
 播放的状态
 */
@property(nonatomic,assign,readonly) JKPlayerState state;

/**
 播放界面（layer）
 */
@property (strong, nonatomic)AVPlayerLayer *playerLayer;

/**
 进度的条和当前时间的返回的block
 */
@property (strong, nonatomic) ProgressTimeBlock progressTimeBlock;

/**
 返回总的时间block
 */
@property (strong, nonatomic) TotalTimeBlock totalTimeBlock;

/**
 进入前台的的
 */
@property (nonatomic, strong) EnterPlayGround enterPlayGround;

/**
 当前app在后台是 YES
 */
@property (nonatomic, assign) BOOL currentAppStatus;

@end

NS_ASSUME_NONNULL_END
