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

/**
 网络请求协助类，此处主要维护并发请求、链式请求、并发链式请求
 提供了单请求、并发请求、链式请求、并发链式请求block回调生成方法
 */
@interface SWNetworkAgent : NSObject

/**
 \~chinese
 初始化方法，返回单例对象
 
 \~english
 Returns the shared network agent.
 */
+ (instancetype)shareAgent;

/**
 \~chinese
 生成一个`SWRequest`对象
 
 \~english
 Creates and returns a request object.

 @param configBlock Set the properties of the request.
 */
+ (SWRequest *)request:(void(^)(SWRequest *request))configBlock;

/**
 \~chinese
 生成一个`SWBatchRequest`对象
 
 \~english
 Creates and returns a batch request object.
 
 @param configBlock Set the properties of the batch request.
 */
+ (SWBatchRequest *)batchRequest:(void(^)(SWBatchRequest *request))configBlock;

/**
 \~chinese
 生成一个`SWChainRequest`对象
 
 \~english
 Creates and returns a chain request object.
 
 @param configBlock Set the properties of the chain request.
 */
+ (SWChainRequest *)chainRequest:(void(^)(SWChainRequest *request))configBlock;

/**
 \~chinese
 生成一个`SWBatchChainRequest`对象
 
 \~english
 Creates and returns a batch chain request object.

 @param configBlock Set the properties of the batch chain request.
 */
+ (SWBatchChainRequest *)batchChainRequest:(void(^)(SWBatchChainRequest *request))configBlock;

/**
 \~chinese
 添加一个并发请求到维护数组
 
 \~english
 Add a batch request.
 */
- (void)addBatchRequest:(SWBatchRequest *)request;

/**
 \~chinese
 从维护数组移除一个并发请求
 
 \~english
 Remove a previously added batch request.
 */
- (void)removeBatchRequest:(SWBatchRequest *)request;

/**
 \~chinese
 添加一个链式请求到维护数组
 
 \~english
 Add a chain request.
 */
- (void)addChainRequest:(SWChainRequest *)request;

/**
 \~chinese
 从维护数组移除一个链式请求
 
 \~english
 Remove a previously added chain request.
 */
- (void)removeChainRequest:(SWChainRequest *)request;

/**
 \~chinese
 添加一个并发链式请求到维护数组
 
 \~english
 Add a batch chain request.
 */
- (void)addBatchChainRequest:(SWBatchChainRequest *)request;

/**
 \~chinese
 从维护数组移除一个并发链式请求
 
 \~english
 Remove a previously added batch chain request.
 */
- (void)removeBatchChainRequest:(SWBatchChainRequest *)request;

@end

NS_ASSUME_NONNULL_END
