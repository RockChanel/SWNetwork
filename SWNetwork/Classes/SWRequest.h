//
//  SWRequest.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// HTTP Request method.
typedef NS_ENUM(NSInteger, SWHTTPMethod) {
    SWHTTPMethodGET,
    SWHTTPMethodPOST,
    SWHTTPMethodHEAD,
    SWHTTPMethodDELETE,
    SWHTTPMethodPUT,
    SWHTTPMethodPATCH,
};

/// Request serializer type.
typedef NS_ENUM(NSInteger, SWRequestSerializerType) {
    SWRequestSerializerTypeHTTP,
    SWRequestSerializerTypeJSON,
};

/// Response serializer type
typedef NS_ENUM(NSInteger, SWResponseSerializerType) {
    /// NSData type
    SWResponseSerializerTypeHTTP,
    /// JSON object type
    SWResponseSerializerTypeJSON,
    /// NSXMLParser type
    SWResponseSerializerTypeXMLParser,
};

@protocol AFMultipartFormData;

typedef void (^SWConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^SWProgressBlock)(NSProgress *progress);

@class SWRequest;

typedef void (^SWRequestCompletionBlock)(SWRequest *request);

/**
 \~chinese
 单个请求代理方法，所有的代理方法将在主线程执行
 
 \~english
 The SWRequestDelegate protocol defines several optional methods you can use to receive network-related messages. All the delegate methods will be called on the main queue.
 */
@protocol SWRequestDelegate <NSObject>
@optional
/**
 \~chinese
 请求即将开始代理方法
 
 \~english
 Notify that the request is about to start.

 @param request The corresponding request.
 */
- (void)requestWillStart:(SWRequest *)request;

/**
 \~chinese
 请求已经开始代理方法
 
 \~english
 Notify that the request has already started.
 
 @param request The corresponding request.
 */
- (void)requestDidStart:(SWRequest *)request;

/**
 \~chinese
 请求即将结束代理方法
 
 \~english
 Notify that the request is about to stop.
 
 @param request The corresponding request.
 */
- (void)requestWillStop:(SWRequest *)request;

/**
 \~chinese
 请求已经结束代理方法
 
 \~english
 Notify that the request has already stop.

 @param request The corresponding request.
 */
- (void)requestDidStop:(SWRequest *)request;

/**
 \~chinese
 请求成功代理方法
 
 \~english
 Notify that the request has finished successfully.

 @param request The corresponding request.
 */
- (void)requestSuccessed:(SWRequest *)request;

/**
 \~chinese
 请求失败代理方法
 
 \~english
 Notify that the request has failed.

 @param request The corresponding request.
 */
- (void)requestFailed:(SWRequest *)request;

@end

/**
 \~chinese
 单个请求快捷构造方法
 
 \~english
 Creates and returns an `SWRequest` object with httpMethod, path and parameters.
 */
FOUNDATION_EXPORT SWRequest *Request(SWHTTPMethod method, NSString *path, id _Nullable parameters);

/**
 单个网络请求
 */
@interface SWRequest : NSObject

/**
 \~chinese
 请求方法
 
 \~english
 HTTP request method.
 */
@property (nonatomic, assign) SWHTTPMethod httpMethod;

/**
 \~chinese
 请求baseURL
 
 \~english
 Request base URL. Default is empty string.
 */
@property (nonatomic, copy, nullable) NSString *baseURL;

/**
 \~chinese
 请求路径，此路径应该是除baseURL以外路径
 若请求路径为有效完整URL路径，则忽略baseURL
 
 \~english
 The URL path of request. This should only contain the path part of URL, e.g., /v1/user.
 
 @discussion This will be concated with `baseUrl` using [NSURL URLWithString:relativeToURL]. Because of this, it is recommended that the usage should stick to rules stated above. Otherwise the result URL may not be correctly formed. See also `URLString:relativeToURL` for more information. Additionaly, if `requestUrl` itself is a valid URL, it will be used as the result URL and `baseUrl` will be ignored.
 */
@property (nonatomic, copy) NSString *path;

/**
 \~chinese
 请求标识，区分不同网络请求
 
 \~english
 Tag can be used to identify request. Default value is 0.
 */
@property (nonatomic) NSInteger tag;

/**
 \~chinese
 请求头
 
 \~english
 HTTP request header field. Default is nil.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *headerField;

/**
 \~chinese
 请求参数
 
 \~english
 Additional request parameters. Default is nil.
 */
@property (nonatomic, strong, nullable) id parameters;

/**
 \~chinese
 request 参数编码的序列化类型
 
 \~english
 Request serializer type.
 */
@property (nonatomic, assign) SWRequestSerializerType requestSerializerType;

/**
 \~chinese
 response 参数编码的序列化类型
 
 \~english
 Response serializer type.
 */
@property (nonatomic, assign) SWResponseSerializerType responseSerializerType;

/**
 \~chinese
 超时时间
 
 \~english
 The timeout interval, in seconds, for created requests.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 \~chinese
 下载路径，当设置了下载路径，则默认为下载请求
 
 \~english
 This value is used to perform download request. Default is nil.
 */
@property (nonatomic, copy, nullable) NSString *downloadPath;

/**
 \~chinese
 当前请求的请求任务
 
 \~english
 The underlying NSURLSessionTask.
 
 @warning This value is actually nil and should not be accessed before the request starts.
 */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

/**
 \~chinese
 请求错误信息
 
 \~english
 This error can be either serialization error or network error. If nothing wrong happens
 this value will be nil.
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 \~chinese
 请求返回结果
 
 \~english
 The serialized response object. The actual type of this object is determined by
 `SWResponseSerializerType`. Note this value can be nil if request failed.
 */
@property (nonatomic, strong, nullable) id responseObject;

/**
 \~chinese
 请求返回的数据
 
 \~english
 The raw data representation of response. Note this value can be nil if request failed.
 */
@property (nonatomic, strong, nullable) NSData *responseData;

/**
 \~chinese
 请求代理
 
 \~english
 The delegate object of the request. Default is nil.
 */
@property (nonatomic, weak, nullable) id <SWRequestDelegate> delegate;

/**
 \~chinese
 FormData配置回调，POST请求请求体设置
 
 \~english
 This can be use to construct HTTP body when needed in POST request. Default is nil.
 */
@property (nonatomic, copy, nullable) SWConstructingBlock constructingBodyBlock;

/**
 \~chinese
 进度回调，可用于进度显示
 
 \~english
 Upload or download progress block. Default is nil.
 */
@property (nonatomic, copy, nullable) SWProgressBlock progressBlock;

/**
 \~chinese
 请求成功回调
 
 \~english
 The success callback. Default is nil. Note this block will be called on the main queue.
 */
@property (nonatomic, copy, nullable) SWRequestCompletionBlock successBlock;

/**
 \~chinese
 请求失败回调
 
 \~english
 The failure callback. Default is nil. Note this block will be called on the main queue.
 */
@property (nonatomic, copy, nullable) SWRequestCompletionBlock failureBlock;

/**
 \~chinese
 请求完成回调
 
 \~english
 The completed callback. Default is nil. Note this block will be called on the main queue.
 */
@property (nonatomic, copy, nullable) SWRequestCompletionBlock completedBlock;

/**
 \~chinese
 是否允许当前请求使用移动蜂窝网络
 
 \~english
 Whether the request is allowed to use the cellular radio (if present). Default is YES.
 */
@property (nonatomic, assign) BOOL allowsCellularAccess;

/**
 \~chinese
 生成请求静态方法
 
 \~english
 Creates and returns an `SWRequest` object.
 */
+ (instancetype)request;

/**
 \~chinese
 请求开始
 
 \~english
 Start request.
 */
- (void)start;

/**
 \~chinese
 请求终止
 
 \~english
 Stop request.
 */
- (void)stop;

/**
 \~chinese
 请求开始，并设置成功、失败、完成回调
 
 \~english
 Convenience method to start the request with block callbacks.
 */
- (void)startWithSuccess:(nullable SWRequestCompletionBlock)success
                 failure:(nullable SWRequestCompletionBlock)failure
               completed:(nullable SWRequestCompletionBlock)completed;

/**
 \~chinese
 清空所有回调
 
 \~english
 Nil out callback blocks.
 */
- (void)clearCompletionBlock;

@end

NS_ASSUME_NONNULL_END
