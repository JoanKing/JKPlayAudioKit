//
//  NSURL+JKPlayExtension.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (JKPlayExtension)

/**
 更换协议
 
 @return 返回一个  sreaming 协议的视频链接
 */
- (NSURL *)stremingURL;

/**
 http 协议
 
 @return 返回一个  http 协议的视频链接
 */
- (NSURL *)httpURL;


@end

NS_ASSUME_NONNULL_END
