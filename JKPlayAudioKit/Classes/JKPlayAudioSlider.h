//
//  JKPlayAudioSlider.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/23.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 进度条点击返回的block

 @param value 进度条的值
 */
typedef void(^SilderClickBlock)(CGFloat value);

@interface JKPlayAudioSlider : UISlider

/**
 进度条点击返回的block
 */
@property (nonatomic, copy) SilderClickBlock silderClickBlock;

@end

NS_ASSUME_NONNULL_END
