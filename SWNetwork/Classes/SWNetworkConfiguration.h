//
//  SWNetworkConfiguration.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AFSecurityPolicy, SWRequest;

/**
 \~chinese
 请求完成预处理回调，该回调将在异步线程执行
 
 \~english
 A callback called on background thread after request succeed before request stops.
 */
typedef void (^SWRequestCompleteProcessBlock)(SWRequest *request);

/**
 \~chinese
 请求失败预处理回调，该回调将在异步线程执行
 
 \~english
 A callback called on background thread after request failed before request stops.
 */
typedef void (^SWRequestFailProcessBlock)(SWRequest *request);

/**
 网络请求全局配置类，在此对网络请求框架请求参数进行统一配置
 */
@interface SWNetworkConfiguration : NSObject

/**
 \~chinese
 全局请求baseURL配置
 
 \~english
 Request global base URL. Default is empty string.
 */
@property (nonatomic, copy, nullable) NSString *baseURL;

/**
 \~chinese
 全局请求头参数配置
 
 \~english
 HTTP request global header field. Default is nil.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *headerField;

/**
 \~chinese
 全局请求参数配置，请求参数将与每个单独请求参数合并
 
 \~english
 HTTP request global parameters. Default is nil.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *, id> *parameters;

/**
 \~chinese
 全局请求content typs配置
 
 \~english
 The acceptable MIME types for responses. When non-`nil`, responses with a `Content-Type` with MIME types that do not intersect with the set will result in an error during validation.
 */
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

/**
 \~chinese
 全局请求超时时间配置，默认超时时间为30秒
 
 \~english
 The global timeout interval, in seconds, for created requests. The default timeout interval is 30 seconds.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 \~chinese
 AFNetworking Https请求配置，配置Https请求证书
 
 \~english
 Security policy will be used by AFNetworking. Default is `defaultPolicy `. See also `AFSecurityPolicy`.
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 \~chinese
 AFHTTPSessionManager 初始化函数入参
 
 \~english
 SessionConfiguration will be used to initialize AFHTTPSessionManager. Default is nil.
 */
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

/**
 \~chinese
 是否在状态栏显示指示器转圈，默认显示
 
 \~english
 Whether to show activity indicator on status bar. Default is YES.
 */
@property (nonatomic, assign, getter=isShowActivityIndicator) BOOL showActivityIndicator;

/**
 \~chinese
 SWNetworking组件日志输出控制，默认不输出日志
 
 \~english
 Whether to log debug info. Default is NO;
 */
@property (nonatomic, assign, getter=isLogEnable) BOOL logEnable;

/**
 \~chinese
 请求完成预处理回调
 
 \~english
 The global complete callback block. Default is nil.
 */
@property (nonatomic, copy, nullable) SWRequestCompleteProcessBlock completeProcessBlock;

/**
 \~chinese
 请求失败预处理回调
 
 \~english
 The global failure callback block. Default is nil.
 */
@property (nonatomic, copy, nullable) SWRequestFailProcessBlock failProcessBlock;

/**
 \~chinese
 初始化函数，返回单例对象
 
 \~english
 Returns the shared network configuration.
 */
+ (SWNetworkConfiguration *)sharedConfiguration;

@end

NS_ASSUME_NONNULL_END
