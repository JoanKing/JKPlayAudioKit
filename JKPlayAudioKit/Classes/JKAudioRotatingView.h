//
//  JKAudioRotatingView.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/20.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKAudioRotatingView : UIView

@property (nonatomic, strong) UIImageView *imageView;

/**
 设置视图的frame

 @param frame 视图的frame
 */
- (void)setRotatingViewLayoutWithFrame:(CGRect)frame;

/**
 添加动画
 */
- (void)addAnimation;

/**
 停止
 */
- (void)pauseLayer;

/**
 恢复
 */
- (void)resumeLayer;

/**
 移除动画
 */
- (void)removeAnimation;


@end

NS_ASSUME_NONNULL_END
