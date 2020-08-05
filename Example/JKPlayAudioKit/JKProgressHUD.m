//
//  JKProgressHUD.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/5.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKProgressHUD.h"
#define kDefaultMaskType SVProgressHUDMaskTypeNone
#define kCustomMinimumSize CGSizeMake(100, 100)

@implementation JKProgressHUD

#pragma mark - Public

+ (void)setSVProgressHUD {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setMinimumDismissTimeInterval:2];
}

+ (void)show
{
    [self showWithStatus:nil maskType:kDefaultMaskType];
}

+ (void)showWithStatus:(NSString *)status {
    [self showWithStatus:status maskType:kDefaultMaskType];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    [self showWithStatus:nil maskType:maskType];
}

+ (void)showWithStatus:(NSString *)status maskType:(SVProgressHUDMaskType)maskType
{
    if ([SVProgressHUD isVisible]) { [self dismiss]; }
    [self resetDefaultAppereace];
    
    [SVProgressHUD setDefaultMaskType:maskType];
    [SVProgressHUD setShouldTintImages:NO];
    [SVProgressHUD setMinimumDismissTimeInterval:120];
    [SVProgressHUD setMinimumSize:kCustomMinimumSize];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 1; i <= 20; i++) {
        NSString *imageName = [NSString stringWithFormat:@"loading20%.2d",i];
        UIImage *image = [UIImage imageNamed:imageName];
        [arrayM addObject:image];
    }
    [SVProgressHUD showImage:[UIImage animatedImageWithImages:arrayM duration:1.f] status:nil];
}

+ (void)showInView:(UIView *)view animationType:(SVProgressHUDAnimationType)animationType status:(NSString *)status {
    if ([SVProgressHUD isVisible]) { [self dismiss]; }
    [self resetDefaultAppereace];
    
    [SVProgressHUD setContainerView:view];
    [SVProgressHUD setDefaultAnimationType:animationType];
    if (status) { [SVProgressHUD setMinimumSize:kCustomMinimumSize]; }
    [SVProgressHUD showWithStatus:status];
}

+ (void)showProgress:(float)progress {
    [self showProgress:progress status:nil];
}

+ (void)showProgress:(float)progress status:(NSString *)status {
    [self showProgress:progress status:status maskType:kDefaultMaskType];
}

+ (void)showProgress:(float)progress status:(NSString *)status maskType:(SVProgressHUDMaskType)maskType {
    [self resetDefaultAppereace];
    [SVProgressHUD setDefaultMaskType:maskType];
    if (status) { [SVProgressHUD setMinimumSize:kCustomMinimumSize]; }
    [SVProgressHUD showProgress:progress status:status];
}

+ (void)showInfoWithStatus:(NSString *)status {
    if (!status || [status isEqualToString:@""]) { return; }
    
    if ([SVProgressHUD isVisible]) { [self dismiss]; }
    [self resetDefaultAppereace];
    
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD setCornerRadius:5];
    [SVProgressHUD showInfoWithStatus:status];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    if ([SVProgressHUD isVisible]) { [self dismiss]; }
    [self resetDefaultAppereace];
    
    if (status) { [SVProgressHUD setMinimumSize:kCustomMinimumSize]; }
    [SVProgressHUD showSuccessWithStatus:status];
}

+ (void)showErrorWithStatus:(NSString *)status {
    if ([SVProgressHUD isVisible]) { [self dismiss]; }
    [self resetDefaultAppereace];
    
    if (status) { [SVProgressHUD setMinimumSize:kCustomMinimumSize]; }
    [SVProgressHUD showErrorWithStatus:status];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}

#pragma mark - Private

// 修改过的属性改为默认值
+ (void)resetDefaultAppereace {
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    [SVProgressHUD setCornerRadius:14];
    [SVProgressHUD setImageViewSize:CGSizeMake(28, 28)];
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setShouldTintImages:YES];
    [SVProgressHUD setMinimumSize:CGSizeZero];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.48]];
    [SVProgressHUD setDefaultMaskType:kDefaultMaskType];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
}

@end
