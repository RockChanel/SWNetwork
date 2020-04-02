//
//  SWChainRequest.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/30.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SWRequest, SWBatchRequest, SWChainRequest;

typedef void (^SWChainRequestCompletionBlock)(SWChainRequest *request);

/**
 \~chinese
 添加请求的回调
 
 \~english
 Add request callback block.

 @param currentRequest The current request.
 */
typedef void (^SWNextChainRequestBlock)(SWRequest *currentRequest);

/**
 \~chinese
 并发请求代理方法，所有的代理方法将在主线程执行
 
 \~english
 The SWChainRequestDelegate protocol defines several optional methods you can use to receive network-related messages. All the delegate methods will be called on the main queue.
 */
@protocol SWChainRequestDelegate <NSObject>

@optional
/**
 \~chinese
 请求即将开始代理方法
 
 \~english
 Notify that the chain request is about to start.
 
 @param request The corresponding request.
 */
- (void)chainRequestWillStart:(SWChainRequest *)request;

/**
 \~chinese
 请求已经开始代理方法
 
 \~english
 Notify that the chain request has already started.
 
 @param request The corresponding request.
 */
- (void)chainRequestDidStart:(SWChainRequest *)request;

/**
 \~chinese
 请求即将结束代理方法
 
 \~english
 Notify that the chain request is about to stop.
 
 @param request The corresponding request.
 */
- (void)chainRequestWillStop:(SWChainRequest *)request;

/**
 \~chinese
 请求已经结束代理方法
 
 \~english
 Notify that the chain request has already stop.
 
 @param request The corresponding request.
 */
- (void)chainRequestDidStop:(SWChainRequest *)request;

/**
 \~chinese
 请求成功代理方法
 
 \~english
 Notify that the chain request has finished successfully.
 
 @param request The corresponding request.
 */
- (void)chainRequestSuccessed:(SWChainRequest *)request;

/**
 \~chinese
 请求失败代理方法
 
 \~english
 Notify that the chain request has failed.
 
 @param request The corresponding request.
 */
- (void)chainRequestFailed:(SWChainRequest *)request;

@end

/**
 单请求链式请求，此请求中的单请求会按顺序串行执行
 */
@interface SWChainRequest : NSObject

/**
 \~chinese
 所有请求数组
 
 \~english
 All the requests.
 */
@property (nonatomic, strong, readonly, nullable) NSArray <SWRequest *> *requests;

/**
 \~chinese
 链式请求中第一个失败的请求，若请求全部成功，则此时为空
 
 \~english
 The first failed request.
 */
@property (nonatomic, strong, readonly, nullable) SWRequest *failedRequest;

/**
 \~chinese
 请求代理
 
 \~english
 The delegate object of the request. Default is nil.
 */
@property (nonatomic, weak, nullable) id <SWChainRequestDelegate> delegate;

/**
 \~chinese
 请求成功回调
 
 \~english
 The success callback. Note this will be called only if all the requests are finished. Default is nil.
 */
@property (nonatomic, copy, nullable) SWChainRequestCompletionBlock successBlock;

/**
 \~chinese
 请求失败回调
 
 \~english
 The failure callback. Note this will be called if one of the requests fails. Default is nil.
 */
@property (nonatomic, copy, nullable) SWChainRequestCompletionBlock failureBlock;

/**
 \~chinese
 请求完成回调
 
 \~english
 The completed callback. Note this will be called after the request succeeds or fails. Default is nil.
 */
@property (nonatomic, copy, nullable) SWChainRequestCompletionBlock completedBlock;

/**
 \~chinese
 生成请求静态方法
 
 \~english
 Creates and returns an `SWChainRequest` object.
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
- (void)startWithSuccess:(nullable SWChainRequestCompletionBlock)success
                 failure:(nullable SWChainRequestCompletionBlock)failure
               completed:(nullable SWChainRequestCompletionBlock)completed;

/**
 \~chinese
 清空所有回调
 
 \~english
 Nil out both success and failure callback blocks.
 */
- (void)clearCompletionBlock;

/**
 \~chinese
 添加单个请求到链式请求
 
 \~english
 Add request to request chain.
 */
- (void)nextRequest:(SWRequest *)request block:(nullable SWNextChainRequestBlock)block;

@end

NS_ASSUME_NONNULL_END
