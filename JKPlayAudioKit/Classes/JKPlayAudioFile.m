//
//  JKPlayAudioFile.m
//  JKPlayAudio
//
//  Created by 王冲 on 2019/8/7.
//  Copyright © 2019 王冲. All rights reserved.
//

#import "JKPlayAudioFile.h"
// 本地缓存文件类型的获取
#import <MobileCoreServices/MobileCoreServices.h>
// 下载中的基础路径
#define JKPlayerCachesPathLoading [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/JKDownLoading"]
// 下载完成的基础路径
#define JKPlayerCachesPathCompleted [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/JKDownloadCompleted"]

/*
 - 1、Home目录(应用程序包)
 - 整个应用程序各文档所在的目录,包含了所有的资源文件和可执行文件
 - 2、Documents
 - 保存应用运行时生成的需要持久化的数据，iTunes同步设备时会备份该目录
 - 需要保存由"应用程序本身"产生的文件或者数据，例如: 游戏进度，涂鸦软件的绘图
 - 目录中的文件会被自动保存在 iCloud
 - 注意: 不要保存从网络上下载的文件，否则会无法上架!
 3、tmp
 - 保存应用运行时所需要的临时数据或文件，"后续不需要使用"，使用完毕后再将相应的文件从该目录删除。
 - 应用没有运行，系统也可能会清除该目录下的文件
 - iTunes不会同步备份该目录
 - 重新启动手机, tmp 目录会被清空
 - 系统磁盘空间不足时，系统也会自动清理
 4、Library/Cache：保存应用运行时生成的需要持久化的数据，iTunes同步设备时不备份该目录。一般存放体积大、不需要备份的非重要数据
 - 保存临时文件,"后续需要使用"，例如: 缓存的图片，离线数据（地图数据）
 - 系统不会清理 cache 目录中的文件
 - 就要求程序开发时, "必须提供 cache 目录的清理解决方案"
 5、Library/Preference：保存应用的所有偏好设置，IOS的Settings应用会在该目录中查找应用的设置信息。iTunes
 - 用户偏好，使用 NSUserDefault 直接读写！
 - 如果想要数据及时写入硬盘，还需要调用一个同步方法 synchronize()
 UserDefaults是一种存轻量级的数据
 //取值
 #define UserDefaultObject(A) [[NSUserDefaults standardUserDefaults]objectForKey:A]
 //存值(可变的值不可以存)
 #define UserDefaultSetValue(B,C) [[NSUserDefaults standardUserDefaults]setObject:B forKey:C]
 //存BOOL值
 #define UserDefaultBool(D,E)  [[NSUserDefaults standardUserDefaults]setBool:D forKey:E]
 #define  Synchronize          [[NSUserDefaults standardUserDefaults]synchronize]
 */

@implementation JKPlayAudioFile

///设置下载的路径
+ (void)load {
    
    [self jk_createFolder:JKPlayerCachesPathCompleted];
    [self jk_createFolder:JKPlayerCachesPathLoading];
}

+ (NSString *)customFilePathName:(FilePath)name customPath:(NSString *)path {
    switch (name) {
        case 0:
            return [NSString stringWithFormat:@"/%@",path];
            break;
        case 1:
            return [NSString stringWithFormat:@"/Documents/%@",path];
            break;
        case 2:
            return [NSString stringWithFormat:@"/Library/%@",path];
            break;
        case 3:
            return [NSString stringWithFormat:@"/Library/Caches/%@",path];
            break;
        case 4:
            return [NSString stringWithFormat:@"/tmp/%@",path];
            break;
        default:
            break;
    }
    return nil;
}

+ (NSString *)homeDirectory {
    
    NSString *filePath = NSHomeDirectory();
    return filePath;
}

+ (NSString *)documents {
    /** 方法一
     NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     */
    
    // 方法二
    NSString *documentsPath= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return documentsPath;
}

+ (NSString *)caches {
    /** 方法一
     NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     */
    // 方法二
    NSString *cachesPath= [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches"];
    return cachesPath;
}

+ (NSString *)library {
    /** 方法一
     NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     */
    //  方法二
    NSString *libraryPath= [NSHomeDirectory() stringByAppendingPathComponent:@"/Library"];
    return libraryPath;
}

+ (NSString *)tmp {
    /** 方法一
     NSString *tempPath = NSTemporaryDirectory();
     */
    //  方法二
    NSString *tempPath= [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp"];
    return tempPath;
}

/**类方法创建文件夹目录 folderNmae:文件夹的名字*/
+ (NSString *)jk_createFolder:(NSString *)folderName {
    
    // NSHomeDirectory()：应用程序目录， Caches、Library、Documents目录文件夹下创建文件夹(蓝色的)
    // @"Documents/JKPdf"
    NSString *filePath = [NSString stringWithFormat:@"%@",folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        
        // 不存在的路径才会创建
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filePath;
}

/**
 判断文件是否存在
 */
+ (BOOL)jk_judgeFileExists:(NSString *)filePath {
    
    // 长度等于0，直接返回不存在
    if (filePath.length == 0) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@",filePath];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (existed == YES) {
        
        return YES;
    }else{
        // 不存在
        return NO;
    }
    return nil;
}

/**
 下载完成后的路径
 
 @param url url地址
 @return 返回路径，在 /Library/Caches/JKDownloadCompleted/文件名 里面
 */
+ (NSString *)cacheDoneFilePath:(NSURL *)url {
    
    NSLog(@"url=%@",url.lastPathComponent);
    
    NSString *path = [self jk_createFolder:JKPlayerCachesPathCompleted];
    return [path stringByAppendingPathComponent:url.lastPathComponent];
}

/**
 下载中的路径
 
 @param url url地址
 @return 返回路径，在 /Library/Caches/JKDownLoading/文件名 里面
 */
+ (NSString *)cacheDoingFilePath:(NSURL *)url {
    
    NSString *path = [self jk_createFolder:JKPlayerCachesPathLoading];
    return [path stringByAppendingPathComponent:url.lastPathComponent];
}

/**
 判断下载中的文件是否存在
 
 @param url 资源的 url
 @return 返回一个BOOL值
 */
+ (BOOL)cacheLoadingFileExists:(NSURL *)url {
    
    return [self jk_judgeFileExists:[self cacheDoingFilePath:url]];
}

/**
 判断已经下载好的文件文件是否存在
 
 @param url 资源的 url
 @return 返回一个BOOL值
 */
+ (BOOL)cacheCompletedFileExists:(NSURL *)url {
    
    return [self jk_judgeFileExists:[self cacheDoneFilePath:url]];
}

/**
 本地已经缓存好的文件夹缓存文件的大小（下载好的文件大小）
 
 @param url 资源的 url
 @return 返回一个资源文件的大小
 */
+ (long long)cacheCompletedFileSize:(NSURL *)url {
    
    // 计算文件总大小
    // 1、先判断是否存在
    if (![self cacheCompletedFileExists:url]) {
        // 如果文件不存在直接返回 0 大小
        return 0;
    }
    // 2、获取文件路径
    NSString *path = [self cacheDoneFilePath:url];
    // 3、计算对应路径下文件的大小
    // 存在计算其大小
    NSDictionary *fileInfo = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil];
    
    return [fileInfo[NSFileSize] longLongValue];
}

/**
 临时缓存的文件的大小
 
 @param url 资源的 url
 @return 返回一个资源文件的大小
 */
+ (long long)cacheLoadingFileSize:(NSURL *)url {
    
    // 计算文件总大小
    // 1、先判断是否存在
    if (![self cacheLoadingFileExists:url]) {
        // 如果文件不存在直接返回 0 大小
        return 0;
    }
    // 2、获取文件路径
    NSString *path = [self cacheDoingFilePath:url];
    // 3、计算对应路径下文件的大小
    // 存在计算其大小
    NSDictionary *fileInfo = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil];
    
    return [fileInfo[NSFileSize] longLongValue];
    
}

/**
 根据本地文件名称获取mimeType
 
 @return 返回一个类型名字
 */

+ (NSString *)localContentType:(NSURL *)url {
    
    /**
     用到框架 #import <MobileCoreServices/MobileCoreServices.h>
     kUTTagClassFilenameExtension : 文件扩展名
     CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
     */
    
    NSString *path = [self cacheDoneFilePath:url];
    NSString *fileExtension = path.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    // 交给ARC管理
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    
    return contentType;
    
}

/**
 移动文件
 
 @param fromPath 移动的文件路径
 @param toPath 移动到的路径
 */
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath {
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
    
}

/**
 删除路径
 
 @param filePath 路径
 */
+ (void)removeFile:(NSString *)filePath {
    
    if ([self jk_judgeFileExists:filePath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
