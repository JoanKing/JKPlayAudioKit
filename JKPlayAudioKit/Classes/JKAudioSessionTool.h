//
//  JKAudioSessionTool.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/5.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface JKAudioSessionTool : NSObject

/**
 继续播放后台背景音乐
 */
+ (void)resumeBackgroundSoundWithError:(NSError **)error;
/**
 暂停后台背景音乐 当前应用需要播放
 */
+ (void)pauseBackgroundSoundWithError:(NSError **)error;
/**
 设置音频类型
 */
+ (void)setCategory:(AVAudioSessionCategory)category;
/**
 设置不中止背景音乐、不支持后台播放的类型
 */
+ (void)setAmbientCategory;
/**
 设置中止背景音乐、不支持后台播放的类型
 */
+ (void)setSoloAmbientCategory;
/**
 设置中止背景音乐、且支持后台播放的类型
 */
+ (void)setPlaybackCategory;


@end

NS_ASSUME_NONNULL_END
