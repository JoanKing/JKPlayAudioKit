//
//  JKAudioSessionTool.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/5.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKAudioSessionTool.h"

@implementation JKAudioSessionTool

/** 继续播放后台背景音乐 */ 
+ (void)resumeBackgroundSoundWithError:(NSError **)error {
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:error];
}

/** 暂停后台背景音乐 当前应用需要播放 */
+ (void)pauseBackgroundSoundWithError:(NSError **)error {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:error];
    [session setActive:YES error:error];
}

/** 设置音频类型 */
+ (void)setCategory:(AVAudioSessionCategory)category {
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: category
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
}

/** 设置不中止背景音乐、不支持后台播放的类型 */
+ (void)setAmbientCategory {
    // 使用这个category的应用会随着静音键和屏幕关闭而静音。
    // 不会中止其它应用播放声音，可以和其它自带应用如iPod，safari等同时播放声音。
    // 该Category无法在后台播放声音
    [self setCategory:AVAudioSessionCategoryAmbient];
}

/** 设置中止背景音乐、不支持后台播放的类型 */
+ (void)setSoloAmbientCategory {
    // 使用这个category的应用会中止其它应用播放声音。
    // 会随着静音键和屏幕关闭而静音。
    // 该Category无法在后台播放声音
    [self setCategory:AVAudioSessionCategorySoloAmbient];
}

/** 设置支持后台播放的类型 */
+ (void)setPlaybackCategory {
    // 使用这个category的应用会中止其它应用播放声音。
    // 会随着静音键和屏幕关闭而静音。
    // 该Category可以在后台播放声音。
    [self setCategory:AVAudioSessionCategoryPlayback];
}

@end
