//
//  JKPlayAudioFile.h
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 文件名字的枚举
/*
 typedef enum new;
 new：枚举类型的变量值列表
 C 样式的枚举默认枚举类型变量值的格式为整型
 */
typedef enum {
    home,
    Documents,
    Library,
    Caches,
    tmp,
    
} FilePath;

@interface JKPlayAudioFile : NSObject

#pragma mark 枚举的取值
/** 枚举的取值来创建路径*/
+ (NSString *)customFilePathName:(FilePath)name customPath:(NSString *)path;

#pragma mark 1.获取各个主目录
/**  获取根目录Home*/
+ (NSString *)homeDirectory;
/**  获取 Documents*/
+ (NSString *)documents;
/**  获取 Cache*/
+ (NSString *)caches;
/**  获取 Library*/
+ (NSString *)library;
/**  获取 tmp*/
+ (NSString *)tmp;

#pragma mark  下载完成后的路径
/**
 下载完成后的路径
 
 @param url url地址
 @return 返回路径，在 /Library/Caches/JKDownloadCompleted/文件名 里面
 */
+ (NSString *)cacheDoneFilePath:(NSURL *)url;

#pragma mark 下载中的路径
/**
 下载中的路径
 
 @param url url地址
 @return 返回路径，在 /Library/Caches/JKDownLoading/文件名 里面
 */
+ (NSString *)cacheDoingFilePath:(NSURL *)url;

#pragma mark  判断已经下载中的文件是否存在
/**
 判断已经下载中的文件是否存在
 
 @param url 资源的 url
 @return 返回一个BOOL值
 */
+ (BOOL)cacheLoadingFileExists:(NSURL *)url;

#pragma mark  判断已经下载好的文件是否存在
/**
 判断已经下载好的文件是否存在
 
 @param url 资源的 url
 @return 返回一个BOOL值
 */
+ (BOOL)cacheCompletedFileExists:(NSURL *)url;

#pragma mark 本地已经缓存好的文件夹缓存文件的大小
/**
 缓存好的文件的大小
 
 @param url 资源的 url
 @return 返回一个资源文件的大小
 */
+ (long long)cacheCompletedFileSize:(NSURL *)url;

#pragma mark 临时缓存的文件的大小
/**
 临时缓存的文件的大小
 
 @param url 资源的 url
 @return 返回一个资源文件的大小
 */
+ (long long)cacheLoadingFileSize:(NSURL *)url;

#pragma mark 根据本地文件名称获取mimeType
/**
 根据本地文件名称获取mimeType
 
 @return 返回一个类型名字
 */
+ (NSString *)localContentType:(NSURL *)url;

#pragma mark 移动文件
/**
 移动文件
 
 @param fromPath 移动的文件路径
 @param toPath 移动到的路径
 */
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;

#pragma mark 删除路径
/**
 删除路径
 
 @param filePath 路径
 */
+ (void)removeFile:(NSString *)filePath ;

@end

NS_ASSUME_NONNULL_END
