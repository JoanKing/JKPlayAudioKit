//
//  UIView+JKViewLayout.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/5.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JKViewLayout)

@property (nonatomic) CGFloat jk_x;
@property (nonatomic) CGFloat jk_y;
@property (nonatomic) CGFloat jk_width;
@property (nonatomic) CGFloat jk_height;
@property (nonatomic) CGFloat jk_centerX;
@property (nonatomic) CGFloat jk_centerY;
@property (nonatomic) CGPoint jk_origin;
@property (nonatomic) CGSize  jk_size;
@property (nonatomic) CGFloat jk_top;
@property (nonatomic) CGFloat jk_left;
@property (nonatomic) CGFloat jk_bottom;
@property (nonatomic) CGFloat jk_right;

/** 相对于屏幕的 X 值 */
@property(nonatomic,readonly) CGFloat jk_ScreenX;
/** 相对于屏幕的 Y 值 */
@property(nonatomic,readonly) CGFloat jk_ScreenY;
@property(nonatomic,readonly) CGFloat jk_ScreenViewX;
@property(nonatomic,readonly) CGFloat jk_ScreenViewY;
@property(nonatomic,readonly) CGRect  jk_ScreenFrame;

/** 设置 view的 边框颜色(选择器和Hex颜色)以及 边框的宽度 */
@property (assign,nonatomic) NSInteger borderWidth;
@property (strong,nonatomic) NSString  *borderHexRgb;
@property (strong,nonatomic) UIColor   *borderColor;



@end

NS_ASSUME_NONNULL_END
