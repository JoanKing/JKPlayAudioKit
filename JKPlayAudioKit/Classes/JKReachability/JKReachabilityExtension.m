//
//  JKReachabilityExtension.m
//  JKReachability
//
//  Created by 王冲 on 2019/1/25.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "JKReachabilityExtension.h"
#import "Reachability.h"
@interface JKReachabilityExtension ()


@property(nonatomic,strong) Reachability *reachabilityManger;

@end
@implementation JKReachabilityExtension

jkSingleM(JKReachabilityExtension)

-(instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        // 注册通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chechStatus:) name:kReachabilityChangedNotification object:nil];
        
        // 开启通知监听网络
        [self.reachabilityManger startNotifier];
    }
    
    return self;
}

-(Reachability *)reachabilityManger{
    
    if (!_reachabilityManger) {
        /**
         如果指定主机名有2种
         1、找一个基本不会挂的服务器
         2、就用我们自己的测试服务器
         */
        _reachabilityManger = [Reachability reachabilityWithHostName:@"baidu.com"];
    }
    return _reachabilityManger;
}

-(void)chechStatus:(NSNotification *)info{
    
    //NSLog(@"%@",info);
    
    switch (self.reachabilityManger.currentReachabilityStatus) {
        case NotReachable:
            
            //NSLog(@"JK----没有网络");
            self.status = @"no_network";
            break;
        case ReachableViaWiFi:
            
            //NSLog(@"JK----WIFI");
            self.status = @"WIFI";
            break;
        case ReachableViaWWAN:

            //NSLog(@"JK----3G 4G");
            self.status = @"ReachableViaWWAN";
            break;
        default:
            break;
    }
}

-(void)dealloc{
    
    [self.reachabilityManger stopNotifier];
    //注销通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

@end
