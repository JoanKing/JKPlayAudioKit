//
//  JKPlayAudioView.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/24.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKPlayAudioModel.h"
//#import "CYDisabledPanGestureView.h"
NS_ASSUME_NONNULL_BEGIN

/**
 FM播放量增加的 block

 @param fmItemId FM的ID
 */
typedef void(^FMAddPlayNumbertBlock)(NSInteger fmItemId);

@interface JKPlayAudioView : UIView

/**
 FM增加播放量
 */
@property (nonatomic, strong) FMAddPlayNumbertBlock fmAddPlayNumbertBlock;

/**
 设置音频的基本信息/切换音频（时间除外）

 @param model 音频的model
 @param isPlay 是否播放
 */
- (void)setAudioMessage:(JKPlayAudioModel *)model withIsPlay:(BOOL)isPlay;

@end

NS_ASSUME_NONNULL_END
