//
//  SWRequest.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SWHTTPMethod) {
    SWHTTPMethodGET,
    SWHTTPMethodPOST,
    SWHTTPMethodHEAD,
    SWHTTPMethodDELETE,
    SWHTTPMethodPUT,
    SWHTTPMethodPATCH,
};

typedef NS_ENUM(NSInteger, SWRequestSerializerType) {
    SWRequestSerializerTypeHTTP,
    SWRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, SWResponseSerializerType) {
    /// NSData
    SWResponseSerializerTypeHTTP,
    /// JSON
    SWResponseSerializerTypeJSON,
    /// NSXMLParser
    SWResponseSerializerTypeXMLParser,
};

@protocol AFMultipartFormData;

typedef void (^SWConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^SWProgressBlock)(NSProgress *progress);

@class SWRequest;

typedef void (^SWRequestCompletionBlock)(SWRequest *request);

/// 单个请求代理方法，所有的代理方法将在主线程执行
@protocol SWRequestDelegate <NSObject>
@optional

/// 请求即将开始代理方法
/// @param request 对应请求
- (void)requestWillStart:(SWRequest *)request;

/// 请求已经开始代理方法
/// @param request 对应请求
- (void)requestDidStart:(SWRequest *)request;

/// 请求即将结束代理方法
/// @param request 对应请求
- (void)requestWillStop:(SWRequest *)request;

/// 请求已经结束代理方法
/// @param request 对应请求
- (void)requestDidStop:(SWRequest *)request;

/// 请求成功代理方法
/// @param request 对应请求
- (void)requestSuccessed:(SWRequest *)request;

/// 请求失败代理方法
/// @param request 对应请求
- (void)requestFailed:(SWRequest *)request;

@end

/// 单个请求快捷构造方法
FOUNDATION_EXPORT SWRequest *Request(SWHTTPMethod method, NSString *path, id _Nullable parameters);

/// 单个网络请求
@interface SWRequest : NSObject

/// 请求方法
@property (nonatomic, assign) SWHTTPMethod httpMethod;

/// 请求baseURL，若不配置，则默认全局baseURL
@property (nonatomic, copy, nullable) NSString *baseURL;


/// 请求路径，此路径应该是除baseURL以外路径
/// 若请求路径为有效完整URL路径，则忽略baseURL
@property (nonatomic, copy) NSString *path;

/// 请求标识，区分不同网络请求
@property (nonatomic) NSInteger tag;

/// 请求头
@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *headerField;

/// 请求参数
@property (nonatomic, strong, nullable) id parameters;

/// 请求参数编码的序列化类型
@property (nonatomic, assign) SWRequestSerializerType requestSerializerType;

/// 参数编码的序列化类型
@property (nonatomic, assign) SWResponseSerializerType responseSerializerType;

/// 超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 下载路径，当设置了下载路径，则默认为下载请求
@property (nonatomic, copy, nullable) NSString *downloadPath;

/// 当前请求对应的请求任务
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

/// 请求错误信息
@property (nonatomic, strong, nullable) NSError *error;

/// 请求返回结果
@property (nonatomic, strong, nullable) id responseObject;

/// 请求返回的数据
@property (nonatomic, strong, nullable) NSData *responseData;

/// 请求代理
@property (nonatomic, weak, nullable) id <SWRequestDelegate> delegate;

/// FormData配置回调，POST请求设置
@property (nonatomic, copy, nullable) SWConstructingBlock constructingBodyBlock;

/// 进度回调，监听请求进度
@property (nonatomic, copy, nullable) SWProgressBlock progressBlock;

/// 请求成功回调，主线程执行
@property (nonatomic, copy, nullable) SWRequestCompletionBlock successBlock;

/// 请求失败回调，主线程执行
@property (nonatomic, copy, nullable) SWRequestCompletionBlock failureBlock;

/// 请求完成回调，主线程执行
@property (nonatomic, copy, nullable) SWRequestCompletionBlock completedBlock;

/// 是否允许当前请求使用移动蜂窝网络，主要用于大流量请求操作配置，默认为YES
@property (nonatomic, assign) BOOL allowsCellularAccess;

/// 初始化方法
+ (instancetype)request;

/// 请求开始
- (void)start;

/// 结束请求
- (void)stop;

/// 请求开始快捷构造方法
/// @param success 成功回调
/// @param failure 失败回调
/// @param completed 完成回调
- (void)startWithSuccess:(nullable SWRequestCompletionBlock)success
                 failure:(nullable SWRequestCompletionBlock)failure
               completed:(nullable SWRequestCompletionBlock)completed;

/// 清空所有回调
- (void)clearCompletionBlock;

@end

NS_ASSUME_NONNULL_END
