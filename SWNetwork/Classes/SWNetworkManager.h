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

/**
 \~chinese
 是否有网络
 
 \~english
 Whether or not the network is currently reachable.
 */
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 \~chinese
 是否是移动蜂窝网络
 
 \~english
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 \~chinese
 是否是无线网网络
 
 \~english
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

/**
 \~chinese
 初始化方法，返回单例对象
 
 \~english
 Returns the shared network http session manager.
 */
+ (instancetype)shareManager;

/**
 \~chinese
 获取当前网络状态回调方法
 
 \~english
 a callback to be executed when the network availability of the `baseURL` host changes.
 
 @param networkStatus block A block object to be executed when the network availability of the `baseURL` host changes.. This block has no return value and takes a single argument which represents the various reachability states from the device to the `baseURL`.
 */
+ (void)networkStatusWithBlock:(void(^)(SWNetworkReachabilityStatus status))networkStatus;

/**
 \~chinese
 发送请求
 
 \~english
 Poke a request.
 */
- (__kindof NSURLSessionTask *)pokeRequest:(SWRequest *)request;

/**
 \~chinese
 取消请求
 
 \~english
 Cancel a request that was previously added.
 */
- (void)cancelRequest:(SWRequest *)request;

/**
 \~chinese
 取消所有请求
 
 \~english
 Cancel all requests that were previously added.
 */
- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
