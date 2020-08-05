//
//  NSURL+JKPlayExtension.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "NSURL+JKPlayExtension.h"

@implementation NSURL (JKPlayExtension)

- (NSURL *)stremingURL {
    
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    // 更换协议
    components.scheme = @"sreaming";
    return components.URL;
}

/**
 http 协议
 
 @return 返回一个  http 协议的视频链接
 */
- (NSURL *)httpURL {
    
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    // 更换协议
    components.scheme = @"http";
    return components.URL;
}

@end
