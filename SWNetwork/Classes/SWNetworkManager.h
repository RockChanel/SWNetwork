//
//  SWNetworkManager.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SWNetworkReachabilityStatus) {
    /// 未知网络
    SWNetworkReachabilityStatusUnknown          = -1,
    /// 无网络
    SWNetworkReachabilityStatusNotReachable     = 0,
    /// 移动蜂窝网络
    SWNetworkReachabilityStatusReachableViaWWAN = 1,
    /// 无线网网络
    SWNetworkReachabilityStatusReachableViaWiFi = 2,
};

@class SWRequest;

/**
 网络请求管理类，此类主要做网络请求维护、请求流程管理操作，并提供网络状态实时监听回调
 */
@interface SWNetworkManager : NSObject

/// 获取当前状态是否有网络
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/// 当前网络是否是移动蜂窝网络
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/// 当前网络是否是无线网网络
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

/// 初始化方法
+ (instancetype)shareManager;

/// 获取当前网络状态回调方法
/// @param networkStatus 网络状态回调
+ (void)networkStatusWithBlock:(void(^)(SWNetworkReachabilityStatus status))networkStatus;

/// 发送请求
- (__kindof NSURLSessionTask *)pokeRequest:(SWRequest *)request;

/// 取消请求
- (void)cancelRequest:(SWRequest *)request;

/// 取消所有请求
- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
