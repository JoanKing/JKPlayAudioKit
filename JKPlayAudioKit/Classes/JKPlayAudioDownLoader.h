//
//  JKPlayAudioDownLoader.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JKPlayAudioDownLoaderDelegate <NSObject>

- (void)downLoading;

@end

@interface JKPlayAudioDownLoader : NSObject

// 资源的总大小
@property(nonatomic,assign) long long totalSize;

// 类型
@property(nonatomic,strong) NSString *mineType;

// 已经下载的大小
@property(nonatomic,assign) long long loadSize;

// 下载的起始点
@property(nonatomic,assign) long long offset;

// 代理属性
@property(nonatomic,weak) id<JKPlayAudioDownLoaderDelegate>delegate;

#pragma mark 下载一段（区间）数据

/**
 下载一段（区间）数据
 
 @param url 请求资源的url
 @param offset 下载的节点，也就是从哪里开始下载
 */
- (void)downLoaderWithUrl:(NSURL *)url offset:(long long)offset;

@end

NS_ASSUME_NONNULL_END
