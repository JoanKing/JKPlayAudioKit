//
//  JKProgressHUD.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/5.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"
NS_ASSUME_NONNULL_BEGIN


@interface JKProgressHUD : NSObject

// 设置 SVProgressHUD
+ (void)setSVProgressHUD;

// 转圈
+ (void)show;
// 转圈 文字
+ (void)showWithStatus:(NSString *)status;
// 转圈 maskType
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;
// 转圈 文字 maskType
+ (void)showWithStatus:(NSString *)status maskType:(SVProgressHUDMaskType)maskType;
// 展示在容器中 动画类型 文字
+ (void)showInView:(UIView *)view animationType:(SVProgressHUDAnimationType)animationType status:(NSString *)status;
// 进度
+ (void)showProgress:(float)progress;
// 进度 文字
+ (void)showProgress:(float)progress status:(NSString *)status;
+ (void)showProgress:(float)progress status:(NSString *)status maskType:(SVProgressHUDMaskType)maskType;

// 文字
+ (void)showInfoWithStatus:(NSString *)status;

// 成功(图片) 文字
+ (void)showSuccessWithStatus:(NSString *)status;

// 错误(图片) 文字
+ (void)showErrorWithStatus:(NSString *)status;

// 消失
+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
