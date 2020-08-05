//
//  JKPlayerResourceLoaderDelegate.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKPlayerResourceLoaderDelegate.h"
// 文件管理
#import "JKPlayAudioFile.h"
// 下载器
#import "JKPlayAudioDownLoader.h"
//
#import "NSURL+JKPlayExtension.h"

@interface JKPlayerResourceLoaderDelegate ()<JKPlayAudioDownLoaderDelegate>

/**
 下载对象
 */
@property(nonatomic,strong) JKPlayAudioDownLoader *downLoader;

/**
 Resuest 的数组
 */
@property(nonatomic,strong) NSMutableArray *loadingResuestArray;

@end

@implementation JKPlayerResourceLoaderDelegate

- (NSMutableArray <AVAssetResourceLoadingRequest *> *)loadingResuestArray {
    
    if (!_loadingResuestArray) {
        
        _loadingResuestArray = [NSMutableArray array];
    }
    return _loadingResuestArray;
}

- (JKPlayAudioDownLoader *)downLoader {
    
    if (!_downLoader) {
        _downLoader = [[JKPlayAudioDownLoader alloc]init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

#pragma mark 播放器-拦截播放请求和本地假数据测试
/**
 当外界，需要播放一段音频资源的时候，会跑一个请求，给这个对象，这个对象到时候，只需要根据请求的信息，抛数据给外界
 
 @param resourceLoader nil
 @param loadingRequest nil
 @return nil
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    // JKLog(@"loadingRequest=%@",loadingRequest);
    
    // 1.判断本地有没有该音频资源的缓存文件，如果有直接根据本地的缓存，向外界相应数据(3个步骤，也就是下面的 handleLoadingRequestResource 方法)，return
    NSURL *url = [loadingRequest.request.URL httpURL];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    if ([JKPlayAudioFile cacheCompletedFileExists:url]) {
        // 本地有缓存
        [self handleLoadingRequestResource:loadingRequest withUrl:url];
        return YES;
    }
    
    // 没有缓存，下面就要进行下载，步骤如下
    // 2.判断当前有没有在下载，如果没有下载，进行下载，return
    // 没有下载
    
    // 添加 (记录) 所有的请求
    
    [self.loadingResuestArray addObject:loadingRequest];
    
    // JKLog(@"loadingRequest=%@",loadingRequest);
    
    if (self.downLoader.loadSize == 0) {
        
        [self.downLoader downLoaderWithUrl:url offset:requestOffset];
        return YES;
    }
    
    // 3.当前有下载，判断是否需要重新下载，如果是直接重新下载，return
    /**
     资源请求1、开始点 < 下载的开始点
     资源请求2、开始点 > 下载的开始点 + 下载的长度 ++ 88(往外扩展的长度，可以自己改)
     */
    
    // 开始下载数据(根据请求信息，url,requestOffset,requestLength)
    // 也有可能是 https
    if (requestOffset < self.downLoader.offset || requestOffset > (self.downLoader.offset+self.downLoader.loadSize+555)) {
        
        [self.downLoader downLoaderWithUrl:url offset:requestOffset];
        
        return YES;
    }
    
    // 4.处理所有的请求，并且在下载的过程中，不断的处理请求
    // 下载的资源和请求的资源，区间可以匹配，直接把本地的缓存数据返给外界，在不断的下载过程当中，返回数据给外界
    // 开始资源的请求 (在下载过程当中，也要不断的进行判断)
    [self handleAllLoadingRequest];
    
    return YES;
}

/**
 取消请求
 
 @param resourceLoader nil
 @param loadingRequest nil
 */
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    // JKLog(@"取消某个请求");
    [self.loadingResuestArray removeObject:loadingRequest];
}

#pragma mark 下载的代理方法
- (void)downLoading {
    
    [self handleAllLoadingRequest];
}

#pragma mark 处理所有的请求，并且在下载的过程中，不断的处理请求
- (void)handleAllLoadingRequest {
    
    NSLog(@"%@",[NSThread currentThread]);
    
    // JKLog(@"在这里不断的处理请求");
    NSMutableArray *deleteRequests = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingResuestArray) {
        
        //  JKLog(@"loadingRequest=%@",loadingRequest);
        
        // 1.填充相应的头部信息
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        
        // NSLog(@"mineType=%@",self.downLoader.mineType);
        
        // 1.2、内容类型
        loadingRequest.contentInformationRequest.contentType = self.downLoader.mineType;
        // 1.3、大的数据段可以分成更小的数据段(YES是支持的意思)
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2.相应的数据给外界（填充数据）
        NSData *data = [NSData dataWithContentsOfFile:[JKPlayAudioFile cacheDoingFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        if (data == nil) {
            
            // 当下载完后下载的文件夹就没有数据了，去下载好的文件夹拿数据
            data = [NSData dataWithContentsOfFile:[JKPlayAudioFile cacheDoneFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        long long responseoffset = requestOffset-self.downLoader.offset;
        // 取小的情况
        long long responseLength = MIN(self.downLoader.offset+self.downLoader.loadSize-requestOffset, requestLength);
        
        //JKLog(@"\nrequestOffset=%lld\ndownLoaderOffset=%lld\nresponseoffset=%lld\nresponseLength===%lld",requestOffset,self.downLoader.offset,responseoffset,responseLength);
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseoffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        // 3.完成本次请求 (必须所有的数据都给完了，才能调用完成请求方法）
        if (requestLength == responseLength) {
            
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
    }
    
    // 移除数组中完成的 Request
    [self.loadingResuestArray removeObjectsInArray:deleteRequests];
}

#pragma mark 处理本地已经加载好的资源
- (void)handleLoadingRequestResource:(AVAssetResourceLoadingRequest *)loadingRequest withUrl:(NSURL *)url {
    
    // JKLog(@"loadingRequest=%@",loadingRequest);
    
    // 根据请求信息，给外界返回数据
    
    // 1.填充相应的头部信息
    // 1.1、动态的获取本地缓存的大小
    // 计算对应路径下文件的大小
    long long totalSize = [JKPlayAudioFile cacheCompletedFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    // 1.2、内容类型
    loadingRequest.contentInformationRequest.contentType = [JKPlayAudioFile localContentType:url];
    // 1.3、大的数据段可以分成更小的数据段(YES是支持的意思)
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2.相应的数据给外界
    /**
     NSDataReadingMappedIfSafe：映射的意思，可以根据映射找到资源，进行加载；如果不加映射，会把资源一下子加载到内存，会造成内存峰值，大了会崩溃
     */
    // 路径
    NSData *data = [NSData dataWithContentsOfFile:[JKPlayAudioFile cacheDoneFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    // 开始请求的节点
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    // 请求的长度
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    // 上面这一节数据下载之后进行组合
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3.完成本次请求（一旦所有的数据都给完了，才能调用完成请求方法）
    [loadingRequest finishLoading];
    
}

@end
