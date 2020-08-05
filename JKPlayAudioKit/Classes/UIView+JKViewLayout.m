//
//  UIView+JKViewLayout.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/5.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "UIView+JKViewLayout.h"

@implementation UIView (JKViewLayout)

#pragma mark x
- (void)setJk_x:(CGFloat)jk_x {
    CGRect frame = self.frame;
    frame.origin.x = jk_x;
    self.frame = frame;
}

- (CGFloat)jk_x {
    return self.frame.origin.x;
}

#pragma mark y
- (void)setJk_y:(CGFloat)jk_y {
    CGRect frame = self.frame;
    frame.origin.y = jk_y;
    self.frame = frame;
}
- (CGFloat)jk_y {
    return self.frame.origin.y;
}

#pragma mark width
- (void)setJk_width:(CGFloat)jk_width {
    
    CGRect frame = self.frame;
    frame.size.width = jk_width;
    self.frame = frame;
}

- (CGFloat)jk_width {
    return self.frame.size.width;
}

#pragma mark height
- (void)setJk_height:(CGFloat)jk_height {
    CGRect frame = self.frame;
    frame.size.height = jk_height;
    self.frame = frame;
}

- (CGFloat)jk_height {
    return self.frame.size.height;
}

#pragma mark centerX

- (void)setJk_centerX:(CGFloat)jk_centerX {
    CGPoint center = self.center;
    center.x = jk_centerX;
    self.center = center;
}

- (CGFloat)jk_centerX {
    return self.center.x;
}

#pragma mark centerY
- (void)setJk_centerY:(CGFloat)jk_centerY {
    
    CGPoint center = self.center;
    center.y = jk_centerY;
    self.center = center;
}

- (CGFloat)jk_centerY {
    return self.center.y;
}


#pragma mark origin
- (CGPoint)jk_origin {
    return self.frame.origin;
}

- (void)setJk_origin:(CGPoint)jk_origin {
    CGRect frame = self.frame;
    frame.origin = jk_origin;
    self.frame = frame;
}

#pragma mark size
- (void)setJk_size:(CGSize)jk_size {
    CGRect frame = self.frame;
    frame.size = jk_size;
    self.frame = frame;
}

- (CGSize)jk_size {
    return self.frame.size;
}

#pragma mark 上
- (CGFloat)jk_top {
    return self.frame.origin.y;
}

- (void)setJk_top:(CGFloat)jk_top {
    CGRect frame = self.frame;
    frame.origin.y = jk_top;
    self.frame = frame;
}

#pragma mark 左
- (CGFloat)jk_left {
    return self.frame.origin.x;
}

- (void)setJk_left:(CGFloat)jk_left {
    CGRect frame = self.frame;
    frame.origin.x = jk_left;
    self.frame = frame;
}

#pragma mark 下
- (CGFloat)jk_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setJk_bottom:(CGFloat)jk_bottom {
    CGRect frame = self.frame;
    frame.origin.y = jk_bottom - frame.size.height;
    self.frame = frame;
}

#pragma mark 右
- (CGFloat)jk_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setJk_right:(CGFloat)jk_right {
    CGRect frame = self.frame;
    frame.origin.x = jk_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)jk_ScreenX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.jk_left;
    }
    return x;
}

- (CGFloat)jk_ScreenY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.jk_top;
    }
    return y;
}

- (CGFloat)jk_ScreenViewX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.jk_left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}

- (CGFloat)jk_ScreenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.jk_top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

- (CGRect)jk_ScreenFrame {
    return CGRectMake(self.jk_ScreenViewX, self.jk_ScreenViewY, self.jk_width, self.jk_height);
}

- (void)setBorderWidth:(NSInteger)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (NSInteger)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderHexRgb:(NSString *)borderHexRgb {
    NSScanner *scanner = [NSScanner scannerWithString:borderHexRgb];
    unsigned hexNum;
    //这里是将16进制转化为10进制
    if (![scanner scanHexInt:&hexNum])
        return;
    self.layer.borderColor = [self colorWithRGBHex:hexNum].CGColor;
}

- (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

- (NSString *)borderHexRgb {
    return @"0xffffff";
}


@end
