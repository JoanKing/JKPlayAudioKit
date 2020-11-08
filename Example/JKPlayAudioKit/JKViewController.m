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
    
    int a;
}
///最下面的播放器
@property (nonatomic, strong) JKPlayAudioView *JKPlayAudioView;

@end

@implementation JKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    a = 0;
    
    NSArray *array = [[NSArray alloc]init];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"MusicList" ofType:@"plist"];
    array = [NSMutableArray arrayWithContentsOfFile:file];
    // https://hzccwl.com/test/ce9a4d016d5d448c855117f7a20ad91d.wav
    // 
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
- (IBAction)nextMusicClick:(UIButton *)sender {
    
     a = a + 1;
    
     NSLog(@"a = %d", a);
     
     [self.JKPlayAudioView setAudioMessage:tempArray[a] withIsPlay:YES];
}


@end

