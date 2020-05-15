//
//  SWFileManager.m
//  SWNetwork
//
//  Created by Pactera on 2020/4/7.
//

#import "SWFileManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SWFileManager

+ (NSString *)getDownloadTargetPathAtPath:(NSString *)downloadPath downloadURL:(NSURL *)downloadURL {
    // 校验路径是否是文件夹
    BOOL isDirectory = [SWFileManager isDirectoryPath:downloadPath];
    if (isDirectory) {
        // 若下载路径为文件夹，则拼接下载链接文件名，设置为下载路径
        NSString *fileName = [downloadURL lastPathComponent];
        return [NSString pathWithComponents:@[downloadPath, fileName]];
    }
    return downloadPath;
}

+ (BOOL)isDirectoryPath:(NSString *)path {
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    return isDirectory;
}

+ (void)removeFileIfExistAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

+ (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;

    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;

    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}

+ (NSString *)md5FromString:(NSString *)string {
    // 判断传入的字符串是否为空
    NSParameterAssert(string != nil && [string length] > 0);
    // 转成utf-8字符串
    const char *cString = [string UTF8String];
    // 设置一个接收数组
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // 对字符串进行加密
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    
    NSMutableString *md5String = [NSMutableString string];
    // 转成32字节的16进制
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [md5String appendFormat:@"%02x", result[i]];
    }
    return md5String;
}

@end
