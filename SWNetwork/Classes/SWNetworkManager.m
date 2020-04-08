//
//  SWNetworkManager.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWNetworkManager.h"
#import "SWNetworkConfiguration.h"
#import "SWRequest.h"
#import "SWFileManager.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworking/AFURLResponseSerialization.h>
#else
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFURLResponseSerialization.h"
#endif

/// 未下载完成文件数据存放文件夹 ... /tmp/Incomplete
#define kSWNetworkIncompleteDownloadFolderName @"Incomplete"

#define LOCK() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define UNLOCK() dispatch_semaphore_signal(self->_lock)

static dispatch_queue_t request_completion_callback_queue() {
    static dispatch_queue_t sw_request_completion_callback_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sw_request_completion_callback_queue = dispatch_queue_create("com.swnetworking.request.completion.callback.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return sw_request_completion_callback_queue;
}

@interface SWNetworkManager()
/// 信号量锁
@property (strong, nonatomic, nonnull) dispatch_semaphore_t lock;
/// 网络请求全局配置
@property (nonatomic, strong) SWNetworkConfiguration *configuration;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
/// json 参数编码的序列化器
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
/// xml 参数编码的序列化器
@property (nonatomic, strong) AFXMLParserResponseSerializer *xmlParserResponseSerialzier;
/// 请求池，维护当前所有请求
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, SWRequest *> *requestspool;
@end

@implementation SWNetworkManager

+ (instancetype)shareManager {
    static SWNetworkManager *networkManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[self alloc] init];
    });
    return networkManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _configuration = [SWNetworkConfiguration sharedConfiguration];
        _manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:_configuration.baseURL] sessionConfiguration:_configuration.sessionConfiguration];
        _manager.securityPolicy = _configuration.securityPolicy;
        _manager.completionQueue = request_completion_callback_queue();
        _manager.responseSerializer.acceptableContentTypes = _configuration.acceptableContentTypes;
        
        _lock = dispatch_semaphore_create(1);
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = _configuration.isShowActivityIndicator;
    }
    return self;
}

- (NSURLSessionTask *)pokeRequest:(SWRequest *)request {
    // 请求不能为空
    NSParameterAssert(request != nil);
    
    __block NSURLSessionTask *sessionTask = nil;
    sessionTask = [self dataTaskWithRequest:request completionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleRequestResult:sessionTask responseObject:responseObject error:error];
    }];
    
    request.sessionTask = sessionTask;
    if (sessionTask) {
        // 如果请求任务不为空，则添加到请求池
        [self addRequestToPool:request];
        [sessionTask resume];
    }
    return sessionTask;
}

/// 处理请求结果方法
/// @param task 对应的请求任务
/// @param responseObject 请求返回数据
/// @param error 请求返回错误信息
- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    LOCK();
    // 根据任务id从请求池中获取对应请求
    SWRequest *request = self.requestspool[@(task.taskIdentifier)];
    UNLOCK();
    
    if (!request) {
        return;
    }
    
    // 解析错误信息
    NSError *serializationError = nil;
    
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        
        switch (request.responseSerializerType) {
            case SWResponseSerializerTypeHTTP:
                break;
            case SWResponseSerializerTypeJSON:
                request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                break;
            case SWResponseSerializerTypeXMLParser:
                request.responseObject = [self.xmlParserResponseSerialzier responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                break;
            default:
                break;
        }
    }
    
    if (error) {
        [self requestDidFailWithRequest:request error:error];
    }
    else if (serializationError) {
        [self requestDidFailWithRequest:request error:serializationError];
    }
    else {
        [self requestDidSucceedWithRequest:request];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 请求完成从请求池移除请求，并清空请求回调
        [self removeRequestFromPool:request];
        [request clearCompletionBlock];
    });
}

/// 处理请求成功结果方法
/// @param request 对应的请求
- (void)requestDidSucceedWithRequest:(SWRequest *)request {
    // 若临时缓存数据存在，下载成功后删除
    if ([request.responseObject isKindOfClass:[NSURL class]]) {
        [SWFileManager removeFileIfExistAtPath:[[self incompleteDownloadTempPath:request.downloadPath] path]];
    }
    
    // 请求成功预处理回调
    if (_configuration.completeProcessBlock) {
        _configuration.completeProcessBlock(request);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if ([request.delegate respondsToSelector:@selector(requestWillStop:)]) {
            [request.delegate requestWillStop:request];
        }
        if (request.delegate) {
            [request.delegate requestSuccessed:request];
        }
        if (request.successBlock) {
            request.successBlock(request);
        }
        if ([request.delegate respondsToSelector:@selector(requestDidStop:)]) {
            [request.delegate requestDidStop:request];
        }
        if (request.completedBlock) {
            request.completedBlock(request);
        }
    });
}


/**
 处理请求失败结果方法

 @param request 对应的请求
 @param error 请求错误信息，此时错误信息可能为网络异常信息以及请求结果解析错误信息
 */
- (void)requestDidFailWithRequest:(SWRequest *)request error:(NSError *)error {
    request.error = error;
    
    // 保存已经下载的数据
    NSData *incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    if (incompleteDownloadData) {
        NSURL *localUrl = [self incompleteDownloadTempPath:request.downloadPath];
        [incompleteDownloadData writeToURL:localUrl atomically:YES];
    }
    
    // 如果下载失败，加载数据并清除本地数据
    if ([request.responseObject isKindOfClass:[NSURL class]]) {
        // 网络下载请求则转换下载数据
        NSURL *url = request.responseObject;
        if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            request.responseData = [NSData dataWithContentsOfURL:url];
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        request.responseObject = nil;
    }
    
    // 请求失败预处理回调
    if (_configuration.failProcessBlock) {
        _configuration.failProcessBlock(request);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 请求失败代理回调
        if ([request.delegate respondsToSelector:@selector(requestWillStop:)]) {
            [request.delegate requestWillStop:request];
        }
        if ([request.delegate respondsToSelector:@selector(requestFailed:)]) {
            [request.delegate requestFailed:request];
        }
        if (request.failureBlock) {
            request.failureBlock(request);
        }
        if ([request.delegate respondsToSelector:@selector(requestDidStop:)]) {
            [request.delegate requestDidStop:request];
        }
        if (request.completedBlock) {
            request.completedBlock(request);
        }
    });
}

- (void)cancelRequest:(SWRequest *)request {
    NSParameterAssert(request != nil);
    
    if (request.downloadPath) {
        // 保存已下载的数据
        NSURLSessionDownloadTask *requestTask = (NSURLSessionDownloadTask *)request.sessionTask;
        [requestTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            NSURL *localUrl = [self incompleteDownloadTempPath:request.downloadPath];
            [resumeData writeToURL:localUrl atomically:YES];
        }];
    } else {
        [request.sessionTask cancel];
    }
    
    // 请求完成从请求池移除请求，并清空请求回调
    [self removeRequestFromPool:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    LOCK();
    NSArray *allKeys = [self.requestspool allKeys];
    UNLOCK();
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            LOCK();
            SWRequest *request = self.requestspool[key];
            UNLOCK();
            [self cancelRequest:request];
        }
    }
}

/**
 添加请求到请求池
 */
- (void)addRequestToPool:(SWRequest *)request {
    LOCK();
    self.requestspool[@(request.sessionTask.taskIdentifier)] = request;
    UNLOCK();
}

/**
 从请求池移除请求
 */
- (void)removeRequestFromPool:(SWRequest *)request {
    LOCK();
    [self.requestspool removeObjectForKey:@(request.sessionTask.taskIdentifier)];
    UNLOCK();
}

/// 发送网络请求统一方法
/// @param request 对应的请求
/// @param completionHandler 请求回调
- (NSURLSessionTask *)dataTaskWithRequest:(SWRequest *)request
                        completionHandler:(void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    id params = request.parameters;
    if ([params isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary <NSString *, id> *tempParams = [NSMutableDictionary dictionary];
        // 将全局配置中参数与单个请求参数合并
        if (_configuration.parameters) {
            [tempParams addEntriesFromDictionary:_configuration.parameters];
        }
        if (params) {
            [tempParams addEntriesFromDictionary:params];
        }
        params = tempParams;
    }
    
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    SWHTTPMethod method = request.httpMethod;
    NSString *URLString = [self urlForRequest:request];
    NSString *downloadPath = request.downloadPath;
    SWConstructingBlock constructingBlock = request.constructingBodyBlock;
    SWProgressBlock progressBlock = request.progressBlock;
    
    switch (method) {
        case SWHTTPMethodGET:
            if (downloadPath) {
                // 若下载路径不为空，则默认为下载请求
                return [self downloadTaskWithDownloadPath:downloadPath downloadProgress:progressBlock requestSerializer:requestSerializer URLString:URLString parameters:params completionHandler:completionHandler];
            }
            return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:URLString parameters:params completionHandler:completionHandler];
        case SWHTTPMethodPOST:
            return [self dataTaskWithHTTPMethod:@"POST" uploadProgress:progressBlock requestSerializer:requestSerializer URLString:URLString parameters:params constructingBodyWithBlock:constructingBlock completionHandler:completionHandler];
        case SWHTTPMethodHEAD:
            return [self dataTaskWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:URLString parameters:params completionHandler:completionHandler];
        case SWHTTPMethodPUT:
            return [self dataTaskWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:URLString parameters:params completionHandler:completionHandler];
        case SWHTTPMethodDELETE:
            return [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:URLString parameters:params completionHandler:completionHandler];
        case SWHTTPMethodPATCH:
            return [self dataTaskWithHTTPMethod:@"PATCH" requestSerializer:requestSerializer URLString:URLString parameters:params completionHandler:completionHandler];
    }
}

/**
 发送普通请求方法

 @param method 请求方法
 @param requestSerializer 参数编码的序列化器
 @param URLString 请求完整URL字符串
 @param parameters 请求参数
 @param completionHandler 请求回调
 @return 返回当前请求请求任务
 */
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                               completionHandler:(void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    return [self dataTaskWithHTTPMethod:method uploadProgress:nil requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil completionHandler:completionHandler];
}

/**
 发送普通请求方法

 @param method 请求方法
 @param uploadProgressBlock 上传进度回调
 @param requestSerializer 参数编码的序列化器
 @param URLString 请求完整URL字符串
 @param parameters 请求参数
 @param block 当POST请求方式为FormData形式，FormData配置回调参数
 @param completionHandler 请求回调
 @return 返回当前请求请求任务
 */
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                               completionHandler:(void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSMutableURLRequest *request = nil;
    NSError *serializationError = nil;
    
    if (block) {
        // POST请求请求方式为FormData
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    }

    if (serializationError) {
        if (completionHandler) {
            dispatch_async(request_completion_callback_queue(), ^{
                completionHandler(nil, serializationError);
            });
        }
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        completionHandler(responseObject, error);
    }];
    
    return dataTask;
}

/**
 下载网络请求方法

 @param downloadPath 下载本地存储路径
 @param downloadProgressBlock 下载进度回调
 @param requestSerializer 参数编码的序列化器
 @param URLString 请求完整URL字符串
 @param parameters 请求参数
 @param completionHandler 请求回调
 @return 返回当前请求请求任务
 */
- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                          downloadProgress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters
                                         completionHandler:(void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:&serializationError];
    
    if (serializationError) {
        if (completionHandler) {
            dispatch_async(request_completion_callback_queue(), ^{
                completionHandler(nil, serializationError);
            });
        }
        return nil;
    }
    
    NSString *downloadTargetPath;
    // 校验路径是否是文件夹
    BOOL isDirectory = [SWFileManager isDirectoryPath:downloadPath];
    
    if (isDirectory) {
        // 若下载路径为文件夹，则拼接下载链接文件名，设置为下载路径
        NSString *fileName = [request.URL lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    }
    else {
        downloadTargetPath = downloadPath;
    }
    
    // 先校验本地是否存在文件，若存在先移除再下载
    [SWFileManager removeFileIfExistAtPath:downloadTargetPath];

    BOOL isResumeDataExist = [[NSFileManager defaultManager] fileExistsAtPath:[[self incompleteDownloadTempPath:downloadPath] path]];
    NSData *data = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPath:downloadPath]];
    BOOL resumeDataIsValid = [SWFileManager validateResumeData:data];

    BOOL canBeResumed = isResumeDataExist && resumeDataIsValid;
    BOOL resumeSucceeded = NO;
    
    __block NSURLSessionDownloadTask *downloadTask = nil;
    // Try to resume with resumeData.
    // Even though we try to validate the resumeData, this may still fail and raise excecption.
    if (canBeResumed) {
        @try {
            downloadTask = [_manager downloadTaskWithResumeData:data progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
            } completionHandler:
                            ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                [self handleRequestResult:downloadTask responseObject:filePath error:error];
                            }];
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            if (_configuration.logEnable) {
                NSLog(@"Resume download failed, reason = %@", exception.reason);
            }
            resumeSucceeded = NO;
        }
    }
    if (!resumeSucceeded) {
       downloadTask = [_manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
        } completionHandler:
                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                            [self handleRequestResult:downloadTask responseObject:filePath error:error];
                        }];
    }
    return downloadTask;
}

+ (void)load {
    // 程序启动时开启网络状态实时监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)networkStatusWithBlock:(void (^)(SWNetworkReachabilityStatus status))block {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (block) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    block(SWNetworkReachabilityStatusUnknown);
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    block(SWNetworkReachabilityStatusNotReachable);
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    block(SWNetworkReachabilityStatusReachableViaWWAN);
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    block(SWNetworkReachabilityStatusReachableViaWiFi);
                    break;
                default:
                    block(SWNetworkReachabilityStatusUnknown);
                    break;
            }
        }
    }];
}

- (BOOL)isReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (BOOL)isReachableViaWWAN {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

- (AFHTTPRequestSerializer *)requestSerializerForRequest:(SWRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == SWRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == SWRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    // 若单个请求设置了超时时间，则以单个请求设置的超时时间为准
    requestSerializer.timeoutInterval = request.timeoutInterval > 0 ? request.timeoutInterval:_configuration.timeoutInterval;
    // 设置请求是否允许移动蜂窝网络请求，此处主要用于大流量请求操作配置
    requestSerializer.allowsCellularAccess = request.allowsCellularAccess;
    
    // 将全局配置请求头与单个请求请求头合并
    NSMutableDictionary <NSString *, NSString *> *headerField = [NSMutableDictionary dictionary];
    if (_configuration.headerField) {
        [headerField addEntriesFromDictionary:_configuration.headerField];
    }
    if (request.headerField) {
        [headerField addEntriesFromDictionary:request.headerField];
    }
    for (NSString *httpHeaderField in headerField.allKeys) {
        NSString *value = headerField[httpHeaderField];
        [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
    }
    return requestSerializer;
}

/// 请求URL字符串异常处理，防止出现请求URL缺失等异常
- (NSString *)urlForRequest:(SWRequest *)request {
    NSParameterAssert(request != nil);
    
    NSString *path = request.path;
    NSURL *tempURL = [NSURL URLWithString:path];
    // 如果请求Path为有效的URL
    if (tempURL && tempURL.host && tempURL.scheme) {
        return path;
    }
    NSString *baseURL;
    // 若单个请求设置了baseURL，则以单个请求为准
    if (request.baseURL && request.baseURL.length > 0) {
        baseURL = request.baseURL;
    } else {
        request.baseURL = _configuration.baseURL;
        baseURL = _configuration.baseURL;
    }
    NSURL *url = [NSURL URLWithString:baseURL];
    
    // 防止因”/“引起的请求不成功
    if (baseURL.length > 0 && ![baseURL hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    if (path.length > 0 && [path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    return [NSURL URLWithString:path relativeToURL:url].absoluteString;
}

/// 获取未下载完成文件存储文件夹
- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;

    if (!cacheFolder) {
        NSString *cacheDirectory = NSTemporaryDirectory();
        cacheFolder = [cacheDirectory stringByAppendingPathComponent:kSWNetworkIncompleteDownloadFolderName];
    }

    // ensure all cache directories are there
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        if (_configuration.logEnable) {
            NSLog(@"Failed to create cache directory at %@", cacheFolder);
        }
        cacheFolder = nil;
    }
    return cacheFolder;
}

/// 获取对应下载文件的临时存储本地URL
/// @param downloadPath 下载路径
- (NSURL *)incompleteDownloadTempPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [SWFileManager md5FromString:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

- (NSMutableDictionary<NSNumber *,SWRequest *> *)requestspool {
    if (!_requestspool) {
        _requestspool = [[NSMutableDictionary alloc] init];
    }
    return _requestspool;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlParserResponseSerialzier) {
        _xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
    }
    return _xmlParserResponseSerialzier;
}

@end
