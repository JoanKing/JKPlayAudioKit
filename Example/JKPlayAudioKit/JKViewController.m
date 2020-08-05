//
//  JKViewController.m
//  JKPlayAudioKit
//
//  Created by JoanKing on 08/05/2020.
//  Copyright (c) 2020 JoanKing. All rights reserved.
//

#import "JKViewController.h"
#import "JKPlayAudioView.h"
#import "MJExtension.h"
#import "JKPlayAudioModel.h"
#import "UIView+JKViewLayout.h"
#define iPhoneTabbarExtraHeight ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0)

@interface JKViewController ()
{
    NSArray *tempArray;
}
///最下面的播放器
@property (nonatomic, strong) JKPlayAudioView *JKPlayAudioView;

@end

@implementation JKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSArray *array = [[NSArray alloc]init];
    NSString *file = [[NSBundle mainBundle]pathForResource:@"MusicList" ofType:@"plist"];
    array = [NSMutableArray arrayWithContentsOfFile:file];
    
    tempArray = [JKPlayAudioModel mj_objectArrayWithKeyValuesArray:array];
   
    [self.JKPlayAudioView setAudioMessage:tempArray[0] withIsPlay:NO];
    [self.view addSubview:self.JKPlayAudioView];
    
}

- (JKPlayAudioView *)JKPlayAudioView {
    if (!_JKPlayAudioView) {
        _JKPlayAudioView = [[JKPlayAudioView alloc]initWithFrame:CGRectMake(0,  [UIScreen mainScreen].bounds.size.height-85-iPhoneTabbarExtraHeight, [UIScreen mainScreen].bounds.size.width, 85)];
        _JKPlayAudioView.backgroundColor = [UIColor blackColor];
    }
    return _JKPlayAudioView;
}


@end

