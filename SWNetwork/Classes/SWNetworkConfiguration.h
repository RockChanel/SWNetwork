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

/// 请求完成预处理回调，该回调将在异步线程执行
typedef void (^SWRequestCompleteProcessBlock)(SWRequest *request);

/// 请求失败预处理回调，该回调将在异步线程执行
typedef void (^SWRequestFailProcessBlock)(SWRequest *request);

/// 网络请求全局配置类，在此对网络请求框架请求参数进行统一配置
@interface SWNetworkConfiguration : NSObject

/// 全局请求baseURL配置
@property (nonatomic, copy, nullable) NSString *baseURL;

/// 全局请求头参数配置，请求头参数将与每个单独请求头参数合并
@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *headerField;

/// 全局请求参数配置，请求参数将与每个单独请求参数合并
@property (nonatomic, strong, nullable) NSDictionary <NSString *, id> *parameters;

/// 全局请求content typs配置
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

/// 全局请求超时时间配置，默认超时时间为30s
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// AFNetworking Https请求配置，配置Https请求证书
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/// AFHTTPSessionManager 初始化函数入参配置
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

/// 是否在状态栏显示指示器转圈，默认显示
@property (nonatomic, assign, getter=isShowActivityIndicator) BOOL showActivityIndicator;

/// SWNetworking组件日志输出控制，默认不输出日志
@property (nonatomic, assign, getter=isLogEnable) BOOL logEnable;

/// 全局请求完成预处理回调
@property (nonatomic, copy, nullable) SWRequestCompleteProcessBlock completeProcessBlock;

/// 全局请求失败预处理回调
@property (nonatomic, copy, nullable) SWRequestFailProcessBlock failProcessBlock;

/// 初始化方法
+ (SWNetworkConfiguration *)sharedConfiguration;

@end

NS_ASSUME_NONNULL_END
