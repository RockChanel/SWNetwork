//
//  SWNetworkAgent.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/8/5.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SWRequest, SWBatchRequest, SWChainRequest, SWBatchChainRequest;


/// 网络请求协助类，此处主要维护并发请求、链式请求、并发链式请求
/// 提供了单请求、并发请求、链式请求、并发链式请求block回调生成方法
@interface SWNetworkAgent : NSObject

/// 初始化方法
+ (instancetype)shareAgent;

/// 生成一个`SWRequest`对象
/// @param configBlock 配置请求回调
+ (SWRequest *)request:(void(^)(SWRequest *request))configBlock;

/// 生成一个`SWBatchRequest`对象
/// @param configBlock 配置请求回调
+ (SWBatchRequest *)batchRequest:(void(^)(SWBatchRequest *request))configBlock;

/// 生成一个`SWChainRequest`对象
/// @param configBlock 配置请求回调
+ (SWChainRequest *)chainRequest:(void(^)(SWChainRequest *request))configBlock;

/// 生成一个`SWBatchChainRequest`对象
/// @param configBlock 配置请求回调
+ (SWBatchChainRequest *)batchChainRequest:(void(^)(SWBatchChainRequest *request))configBlock;

/// 添加一个并发请求到维护数组
- (void)addBatchRequest:(SWBatchRequest *)request;

/// 从维护数组移除一个并发请求
- (void)removeBatchRequest:(SWBatchRequest *)request;

/// 添加一个链式请求到维护数组
- (void)addChainRequest:(SWChainRequest *)request;

/// 从维护数组移除一个链式请求
- (void)removeChainRequest:(SWChainRequest *)request;

/// 添加一个并发链式请求到维护数组
- (void)addBatchChainRequest:(SWBatchChainRequest *)request;

/// 从维护数组移除一个并发链式请求
- (void)removeBatchChainRequest:(SWBatchChainRequest *)request;

@end

NS_ASSUME_NONNULL_END
