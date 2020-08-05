//
//  JKPlayAudioModel.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/24.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKPlayAudioModel : NSObject

/**
 音频的标题
 */
@property (nonatomic, strong) NSString *itemTitle;

/**
 音频的图片
 */
@property (nonatomic, strong) NSString *coverImg;

/**
 音频的第几期
 */
@property (nonatomic, strong) NSString *itemNo;

/**
 音频的url
 */
@property (nonatomic, strong) NSString *contentUrl;

/**
 音频的 第几期的 ID
 */
@property (nonatomic, assign) NSInteger fmItemId;

@end

NS_ASSUME_NONNULL_END
