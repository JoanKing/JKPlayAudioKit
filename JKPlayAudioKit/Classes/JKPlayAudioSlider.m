//
//  JKPlayAudioSlider.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/7/23.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKPlayAudioSlider.h"

@implementation JKPlayAudioSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    // 1.minimumValue  : 当值可以改变时，滑块可以滑动到最小位置的值，默认为0.0
    self.minimumValue = 0.0;
    // 2.maximumValue : 当值可以改变时，滑块可以滑动到最大位置的值，默认为1.0
    self.maximumValue = 1.0;
    // 3.当前值
    self.value = 0;
    // 4.minimumTrackTintColor : 小于滑块当前值滑块条的颜色，默认为蓝色
    self.minimumTrackTintColor = [UIColor whiteColor];
    // 5.maximumTrackTintColor: 大于滑块当前值滑块条的颜色，默认为白色
    self.maximumTrackTintColor = [UIColor grayColor];
    // 6.thumbTintColor : 当前滑块的颜色，默认为白色
    self.thumbTintColor = [UIColor yellowColor];
    // 7.currentMaximumTrackImage : 滑块条最大值处设置的图片
    // 8.currentMinimumTrackImage : 滑块条最小值处设置的图片
    // 9.currentThumbImage: 当前滑块的图片
    UIImage *thumbNormalImage = [self originImage:[UIImage imageNamed:@"fm_small_slider"] scaleToSize:CGSizeMake(10, 10)];
    UIImage *thumbHighlightedImage = [self originImage:[UIImage imageNamed:@"fm_big_slider"] scaleToSize:CGSizeMake(14, 14)];
    // 通常状态下
    [self setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    // 滑动状态下
    [self setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];
    
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    //进度条点击事件去掉
    //[self addGestureRecognizer:tapGesture];
}

/*
 对原来的图片的大小进行处理
 @param image 要处理的图片
 @param size  处理过图片的大小
 */
- (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

//两边有空隙,修改方法
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    // w 和 h 是滑块可触摸范围的大小，跟通过图片改变的滑块大小应当一致。
    rect.origin.x = rect.origin.x - 5 ;
    rect.size.width = rect.size.width +10;
    // 这次如果不调用的父类的方法 Autolayout 倒是不会有问题，但是滑块根本就不动~
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 5 , 5);
}

/**
 UISlider的点击事件

 @param sender 对应的点击事件
 */
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:self];
    CGFloat value = (self.maximumValue - self.minimumValue) * (touchPoint.x / self.frame.size.width );
    //DLog(@"value=========%f touchPointX======%f",value,touchPoint.x);
    [self setValue:value animated:YES];
    
    if (self.silderClickBlock) {
        self.silderClickBlock(value);
    }
}

//改变UIslide高度
//- (CGRect)trackRectForBounds:(CGRect)bounds{
//    bounds.origin.x = bounds.origin.x;
//    bounds.origin.y = (bounds.size.height-20)/2;
//    bounds.size.height = 20;
//    bounds.size.width = bounds.size.width;
//    return bounds;
//}
//- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
//{
//      NSLog(@"bounds1:%@",NSStringFromCGRect(bounds));
//    return bounds;
//}
//- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
//{
//      NSLog(@"bounds2:%@",NSStringFromCGRect(bounds));
//    return bounds;
//}

@end
