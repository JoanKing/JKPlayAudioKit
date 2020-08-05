//
//  JKPlayAudioDownLoader.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKPlayAudioDownLoader.h"
#import "JKPlayAudioFile.h"
@interface JKPlayAudioDownLoader ()<NSURLSessionDataDelegate>
{
    
}

// 全局的网络会话，管理所有的网络任务
@property(nonatomic,strong) NSURLSession *session;

/* 保存文件的输出流
 - (void)open; 写入之前，打开流
 - (void)close; 写入完毕之后，关闭流
 */
@property(nonatomic,strong)NSOutputStream *fileStream;

// 资源的 url 地址
@property(nonatomic,strong) NSURL *url;

@end
@implementation JKPlayAudioDownLoader

- (NSURLSession *)session {
    
    // NSURLSession 默认是在子线程开启任务的
    if (!_session) {
        
        /**
         全局网络环境的一个配置
         比如：身份验证，浏览器类型以及缓存，超时，这些都会被记录在
         */
        
        /**
         主要说一下这个函数参数的意义；
         参数
         
         1. 配置 config
         2. 代理 self
         3. 代理工作的队列 必须是NSOperationQueue队列
         
         [NSOperationQueue mainQueue] 代理在主线程上工作
         nil － 代理异步工作
         [[NSOperationQueue alloc] init] - 代理在异步工作
         
         注意：URLSession 请求本身的网络操作是异步的，无论指定什么队列，都是在异步执行的
         
         － 这里制定的队列是在此指定的代理的工作队列，表示发生网络事件后，希望在哪一个线程中工作！
         队列的选择类型依据与 NSURLConnection 异步的队列选择依据相同！
         
         －如果完成后需要做复杂(耗时)的处理，可以选择异步队列
         
         －如果完成后直接更新UI，可以选择主队列
         
         强调：session本身工作的线程，与代理工作的线程是不一样的
         
         */
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        // [NSOperationQueue mainQueue]
        //  [[NSOperationQueue alloc] init]
    }
    return _session;
}

#pragma mark 下载一段（区间）数据
- (void)downLoaderWithUrl:(NSURL *)url offset:(long long)offset {
    
    // 清理之前的缓存数据
    [self cancleAndCleanData];
    
    // 记录url地址
    self.url = url;
    
    // 保存下载的起始点
    self.offset = offset;
    
    // 下载一段（区间）数据
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    // session 分配的task, 默认情况, 挂起状态
    NSURLSessionDataTask *downloadTask = [self.session dataTaskWithRequest:request];
    // 调用之后去代理方法里面
    [downloadTask resume];
}

#pragma mark 清理之前的缓存数据
- (void)cancleAndCleanData {
    
    [self.session invalidateAndCancel];
    self.session = nil;
    
    // 清空本地已经存储的临时缓存
    [JKPlayAudioFile removeFile:[JKPlayAudioFile cacheDoingFilePath:self.url]];
    
    // 本地清除之后，清空临时缓存文件里面文件的大小
    self.loadSize = 0;
}

#pragma mark - 协议方法

// 第一次接受到相应的时候调用(响应头, 并没有具体的资源内容)
// 通过这个方法, 里面, 系统提供的回调代码块, 可以控制, 是继续请求, 还是取消本次请求
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    self.mineType = response.MIMEType;
    
    // 资源总大小的截取(先从Content-Length获取，这个不准确，再从Content-Range后面截取)
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    NSLog(@"总大小=%lld",self.totalSize);
    
    // 创建输出流
    self.fileStream = [[NSOutputStream alloc]initToFileAtPath:[JKPlayAudioFile cacheDoingFilePath:self.url] append:YES];
    [self.fileStream open];
    
    // 继续接受数据
    completionHandler(NSURLSessionResponseAllow);
    
}

// 当用户确定, 继续接受数据的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [self.fileStream write:data.bytes maxLength:data.length];
    
    // 大小叠加
    self.loadSize += data.length;
    
    NSLog(@"-----下载中-----");
    
    // 判断是否实现了代理方法
    if ([self.delegate respondsToSelector:@selector(downLoading)])
    {
        
        [self.delegate downLoading];
    }
}

// 请求完成的时候调用( != 请求成功/失败)
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"请求完成");
    
    if (error == nil) {
        NSLog(@"下载没问题");
        // 不一定是成功
        // 数据是肯定可以请求完毕
        // 判断, 本地缓存 == 文件总大小 {filename: filesize: md5:xxx}
        // 如果等于 => 验证, 是否文件完整(file md5 )
        
        /**
         下载-文件完整性验证机制：验证文件的合法性, 下载数据是否完整可用
         1. 服务器返回文件下载信息的同时, 会返回该文件内容的md5值
         2. 本地下载完成后, 可以, 在本地已下载的文件的MD5值和服务器返回的进行对比;
         3.为了简单, 有的, 服务器返回的下载文件MD5值, 直接就是命名称为对应的文件名称
         */
        
        // 在本地临时缓存的大小等于总大小时候，说明文件内容是完整的，把文件移动到下载好的文件夹
        if ([JKPlayAudioFile cacheLoadingFileSize:self.url] == self.totalSize) {
            
            // 移动文件: /Library/Caches/JKDownLoading -> /Library/Caches/JKDownloadCompleted
            // 文件已经下载完,移动路径（前提是上面的没问题）
            [JKPlayAudioFile moveFile:[JKPlayAudioFile cacheDoingFilePath:self.url] toPath:[JKPlayAudioFile cacheDoneFilePath:self.url]];
        }
    }else{
        
        NSLog(@"下载有问题：%zd 详情：%@",error.code,error.localizedDescription);
        if (error.code == -999) {
            
        }else{
            // 失败的原因
            // NSString *errorMessage = [NSString stringWithFormat:@"%@",error.localizedDescription];
        }
    }
    
    // 关闭流
    [self.fileStream close];
    
}

@end

