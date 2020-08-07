//
//  JKPlayAudioKit.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/19.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKPlayAudioKit.h"
#import "JKAudioSessionTool.h"
#import "NSURL+JKPlayExtension.h"
#import "JKPlayerResourceLoaderDelegate.h"
@interface JKPlayAudioKit ()
{
    // 用户是否进行了手动暂停
    BOOL isUserPause;
}

/** 播放器监听 */
@property (nonatomic, strong) id timeObserver;
/** AVPlayerItem对象 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** 被打断之前的状态：是否在前台 */
@property (nonatomic, assign) BOOL handleInterruptioBeforeStatus;
/** 代理属性 */
@property(nonatomic,strong) JKPlayerResourceLoaderDelegate *resourceLoaderDelegate;

@end

@implementation JKPlayAudioKit

static id instance;
static dispatch_once_t onceToken;
static dispatch_once_t onceToken2;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken2, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copy {
    return instance;
}

- (id)mutableCopy {
    return instance;
}

+ (instancetype)shareDownloaderManger {
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

/**  播放视频 */
- (void)playerWithUrl:(NSURL *)url isCache:(BOOL)isCache {
    
    // 先判断要播放的 url 与之前播放的 url 是否相等
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    
    if ([url isEqual: currentURL] || [[url stremingURL] isEqual:currentURL]) {
        
        if (self.state == JKPlayerStatePlaying) {
            return;
        }
        if (self.state == JKPlayerStatePause) {
            [self resume];
            return;
        }
        if (self.state == JKPlayerStateLoading) {
            return;
        }
        
        [self resume];
        return;
    }
    
    // 在执行下面的2之前先进行一下判断，如果存在AVPlayerItem，先移除
    if (self.player.currentItem) {
        [self removeObserver];
    }
    
    // 如果需要缓存，就更改协议，如果不缓存那么系统对资源进行加载
    // 记录url
    _url = url;
    
    if (isCache) {
        url = [url stremingURL];
    }
    // 1.创建一个播放器对象
    /**
     AVPlayer *player = [AVPlayer playerWithURL:url];
     [player play];
     使用下面的方法播放远程的视频，如果加载资源比较慢，有可能会造成调用了play方法，视频会播放不了,
     在这个方法已经帮我们封装了三个步骤
     步骤一、资源的请求
     步骤二、资源的组织
     步骤三、给播放器，资源的播放
     */
    // 1、资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    // 关于网络音频的请求，是通过这个对象，调用代理的相关方法，进行加载的，拦截加载的请求，只需要重新修改它的的代理方法就可以
    self.resourceLoaderDelegate = [JKPlayerResourceLoaderDelegate new];
    [asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    
    // 2、资源的组织(当资源的组织者，告诉我们资源准备好了之后，我们再去播放)
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    /** 2.1监听状态去播放视频
     @property (nonatomic, readonly) AVPlayerItemStatus status;
     */
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    /** 2.2、playbackLikelyToKeepUp */
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    self.playerItem = playerItem;
    /** 2.3、监听播放结束 */
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    /** 2.4、播放被打断 */
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playInterrupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    /** 2.5、app进入后台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationWillResignActiveNotification object:nil];
    /** 2.6、app进入前台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    /** 2.6、app进入前台 (不受通知栏的影响) */
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    // //开始写代码，调整音频会话设置，确保即便应用进入后台或静音开关已开启，音频仍将继续播放
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [session setActive:YES error:nil];

    //播放中被打断
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:session];
    //拔掉耳机监听？？
    // 3、给播放器，资源的播放
    if (self.player.currentItem) {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    } else {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        if (@available(iOS 10.0, *)) {
            //缓冲过直接播放不需要等待
            self.player.automaticallyWaitsToMinimizeStalling  = NO;
        }
    }
    //播放中监听，更新播放进度
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        NSTimeInterval currentTime1 = CMTimeGetSeconds(time);
        //视频的总时间
        NSTimeInterval totalTime1 = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        if (weakSelf.progressTimeBlock) {
              weakSelf.progressTimeBlock([NSString stringWithFormat:@"%02d:%02d",(int)currentTime1/60,(int)currentTime1 % 60],currentTime1 / totalTime1);
        }
    }];
}

#pragma mark KVO 监听
//有关这个类里面的监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    // 刚开始的时候走这里，在播放的过成功中走下面playbackLikelyToKeepUp的监听方法
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            
            //资源准备好了，可以进行播放
            //DLog(@"资源准备好了，可以进行播放");
            if (self.totalTimeBlock) {
                self.totalTimeBlock(self.totalTimeFormat);
            }
            if (self.currentAppStatus) {
                return;
            }
            [self resume];
        } else {
            //DLog(@"状态未知");
            self.state = JKPlayerStateFailed;
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        
        BOOL pToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (pToKeepUp) {
            //这里是指有可缓冲好的资源去播放
            //DLog(@"资源已经准备好了,可以进行播放");
            // 用户手动暂停的优先级最高
            if (!isUserPause) {
                // 用户没有手动暂停才去播放的
                [self resume];
            }
        } else {
            //DLog(@"资源准备中，也就是在正在加载");
            self.state = JKPlayerStateLoading;
        }
    }
}

#pragma mark 播放结束
- (void)playEnd {
    //DLog(@"播放结束");
    [self.playerItem seekToTime:kCMTimeZero];
    self.state = JKPlayerStateStopped;
}

#pragma mark 播放被打断(暂时废弃)
- (void)playInterrupt {
    
    //DLog(@"播放被打断");
    /**
     原因：
     1.来电话
     2.资源加载跟不上
     */
    self.state = JKPlayerStateStopped;
}

#pragma mark 移除监听
- (void)removeObserver {
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        _playerItem = nil;
    }
    
    if (_timeObserver && _player) {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 暂停播放 */
- (void)pause {
    [self.player pause];
    // 手动暂停
    isUserPause = YES;
    // 先判断播放器存在
    if (self.player) {
        self.state = JKPlayerStatePause;
    }
}

/** 继续播放 */
- (void)resume {
    // 1.当前播放器存在，2.组织者里面的数据已经准备的可以播放了
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        [self.player play];
        // 没有手动暂停
        isUserPause = NO;
        // 改状态为正在播放
        self.state = JKPlayerStatePlaying;
    }
}

/** 停止播放 */
- (void)stop {
    [self.player pause];
    // 先判断播放器存在
    if (self.player) {
        self.state = JKPlayerStateStopped;
    }
    self.player = nil;
}

/**
 快进
 
 @param timeDiffer 快进的时间
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    
    // 1.当前音频资源的总时长
    // CMTime totalTime = self.player.currentItem.duration;
    // 资源总秒数: 影片时间 -> 秒
    // NSTimeInterval totalSecond = CMTimeGetSeconds(totalTime);
    NSTimeInterval totalSecond = [self totalTime];
    // 2.当前播放的总时长
    //CMTime playTime =  self.player.currentItem.currentTime;
    // NSTimeInterval playTimeSecond = CMTimeGetSeconds(playTime);
    NSTimeInterval playTimeSecond = [self currentTime];
    // 3.更新快进后的时间（ -15 或者 +15 ）
    playTimeSecond += timeDiffer;
    
    // 调用进度播放
    [self seekWithTimeProgress:playTimeSecond/totalSecond finsh:^{
        
    }];
}

/**
 指定播放进度
 
 @param progress 进度值
 */
- (void)seekWithTimeProgress:(float)progress finsh:(void(^)(void))finsh {
    
    if (progress < 0 || progress > 1) {
        return;
    }
    
    /**
     指定时间节点去播放
     时间：CMTime（影片时间）
     影片时间 -> 秒
     秒 -> 影片时间
     */
    // 1.当前音频资源的总时长(用下面的方法([self totalTime])替换掉)
    // CMTime totalTime = self.player.currentItem.duration;
    /**
     2.当前音频，已经播放的时长
     self.player.currentItem.currentTime
     */
    // 资源总秒数: 影片时间 -> 秒
    NSTimeInterval totalSecond = [self totalTime];
    NSTimeInterval playTimeSecond = totalSecond * progress;
    
    /**
     秒 -> 影片时间
     第一个参数：秒数
     第二个参数：每秒多少帧
     */
    CMTime currentTime = CMTimeMake(playTimeSecond, 1);
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        
        if (finished) {
            //NSLog(@"确定加载的秒数：%f",playTimeSecond);
            //NSLog(@"确定加载这个时间点的音频资源");
        }else{
            // 有可能在加载出来之前拖动多次
            //NSLog(@"取消加载这个时间点的音频资源");
        }
        if (finsh) {
            finsh();
        }
    }];
}

/**
 播放的倍速
 
 @param rate 倍速值：1.0、2.0、3.0
 */
- (void)setRate:(float)rate {
    
    [self.player setRate:rate];
}

- (float)rate {
    
    return self.player.rate;
}

/**
 是否静音
 
 @param muted YES：静音 NO：不静音
 */
- (void)setMuted:(BOOL)muted {
    
    self.player.muted = muted;
}

- (BOOL)muted {
    
    return self.player.muted;
}

/**
 音量调整
 
 @param volume 音量的大小
 */
- (void)setVolume:(float)volume {
    
    if (volume < 0 || volume > 1) {
        return;
    }
    
    if (volume > 0) {
        // 音量大于0,取消静音
        [self setMuted:NO];
    }
    self.player.volume = volume;
}

- (float)volume {
    
    return self.player.volume;
}

#pragma mark 播放器-事件&数据提供
// 当前音频资源的总时长
- (NSTimeInterval)totalTime {
    
    // 1.当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    /**
     2.当前音频，已经播放的时长
     self.player.currentItem.currentTime
     */
    // 资源总秒数: 影片时间 -> 秒
    NSTimeInterval totalSecond = CMTimeGetSeconds(totalTime);
    // 如果发现 totalSecond = NaN,返回一个0
    if (isnan(totalSecond)) {
        return 0;
    }
    
    return totalSecond;
}

- (NSString *)totalTimeFormat {
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)self.totalTime/60,(int)self.totalTime % 60];
}

// 当前播放的总时长
- (NSTimeInterval)currentTime {
    
    // 2.当前播放的总时长
    CMTime playTime =  self.player.currentItem.currentTime;
    NSTimeInterval playTimeSecond = CMTimeGetSeconds(playTime);
    
    // 如果发现 playTimeSecond = NaN,返回一个0
    if (isnan(playTimeSecond)) {
        return 0;
    }
    return playTimeSecond;
}

- (NSString *)currentTimeFormat {
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)self.currentTime/60,(int)self.currentTime % 60];
}

// 当前播放的进度
- (float)progress {
    
    // 容错处理
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime/self.totalTime;
}

// 缓存的时长
- (float)loadDataProgress {
    
    // 容错处理
    if (self.totalTime == 0) {
        return 0;
    }
    // 获取加载的时间区间
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    // 开始时间与缓存时间和
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    // 转化成秒
    NSTimeInterval loadTimeSecond = CMTimeGetSeconds(loadTime);
    // 缓存的时间除以总时间得到缓存的进度
    return loadTimeSecond/self.totalTime;
}

/**
 播放的状态
 */
- (void)setState:(JKPlayerState)state {
    
    _state = state;
    // 如果需要告诉外界相关的事件,可以选择 block、代理、通知，这些都是 推模式
    [[NSNotificationCenter defaultCenter] postNotificationName:JKPlayerPlayStateChangeNotification object:nil userInfo:@{@"playURL": self.url,@"playState": @(self.state)}];
    
    if (state == JKPlayerStateStopped
        || state == JKPlayerStatePause) {
        [JKAudioSessionTool resumeBackgroundSoundWithError:nil];
    } else {
        [JKAudioSessionTool pauseBackgroundSoundWithError:nil];
    }
}

- (void)setUrl:(NSURL * _Nonnull)url {
    
    _url = url;
    if (self.url) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JKPlayerPlayStateChangeNotification object:nil userInfo:@{@"downLoadURL": self.url,@"downLoadState": @(self.state)}];
    }
}

#pragma mark 进入后台，暂停音频
- (void)appEnteredBackground {
 
    self.currentAppStatus = YES;
    
    if (self.player && self.state == JKPlayerStatePlaying) {
        self.handleInterruptioBeforeStatus = YES;
        [self pause];
    }
}

#pragma mark 应用进入前台
- (void)appDidEnterPlayGround
{
    self.currentAppStatus = NO;
    
    if (self.state == JKPlayerStatePause && self.handleInterruptioBeforeStatus) {
        [self resume];
        self.handleInterruptioBeforeStatus = NO;
        if (self.enterPlayGround) {
            self.enterPlayGround();
        }
    }
}

/*
#pragma mark 播放中被打断
- (void)handleInterruption:(NSNotification *)notification {

    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        ///开始打断
        if (self.player && self.state == JKPlayerStatePlaying) {
            [self pause];
            self.handleInterruptioBeforeStatus = YES;
        }
    }else if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        ///结束打断
        if (self.player && self.state == JKPlayerStateStopped && self.handleInterruptioBeforeStatus) {
            [self resume];
            self.handleInterruptioBeforeStatus = NO;
        }
    }
}
 */

- (void)dealloc {
//    [self removeObserver];
}

/// 销毁单例
+ (void)destroy {
    instance = nil;
    onceToken = 0l;
    onceToken2 = 0l;
}


@end
