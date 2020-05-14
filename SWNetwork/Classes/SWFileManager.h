//
//  SWFileManager.h
//  SWNetwork
//
//  Created by Pactera on 2020/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWFileManager : NSObject

/// 获取下载文件真实目标路径
/// @param downloadPath 下载路径
/// @param downloadURL 下载URL
+ (NSString *)getDownloadTargetPathAtPath:(NSString *)downloadPath downloadURL:(NSURL *)downloadURL;

/// 校验目标路径是否是文件夹
/// @param path 目标路径
+ (BOOL)isDirectoryPath:(NSString *)path;

/// 如果目标路径文件存在，则移除文件
/// @param path 目标路径
+ (void)removeFileIfExistAtPath:(NSString *)path;

/// 校验是否有可恢复数据
/// @param data 可恢复数据
+ (BOOL)validateResumeData:(NSData *)data;

/// md5 加密字符串
/// @param string 原字符串
+ (NSString *)md5FromString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
