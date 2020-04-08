//
//  SWBatchChainRequest.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/8/6.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SWBatchRequest, SWBatchChainRequest;

typedef void (^SWBatchChainRequestCompletionBlock)(SWBatchChainRequest *request);

/// 添加下一个并发请求回调
/// @param currentRequest 前一个刚结束的请求
typedef void (^SWNextBatchChainRequestBlock)(SWBatchRequest *currentRequest);


/// 并发请求代理方法，所有的代理方法将在主线程执行
@protocol SWBatchChainRequestDelegate <NSObject>
@optional

/// 请求即将开始代理方法
/// @param request 对应请求
- (void)batchChainRequestWillStart:(SWBatchChainRequest *)request;

/// 请求已经开始代理方法
/// @param request 对应请求
- (void)batchChainRequestDidStart:(SWBatchChainRequest *)request;

/// 请求即将结束代理方法
/// @param request 对应请求
- (void)batchChainRequestWillStop:(SWBatchChainRequest *)request;

/// 请求已经结束代理方法
/// @param request 对应请求
- (void)batchChainRequestDidStop:(SWBatchChainRequest *)request;

/// 请求成功代理方法
/// @param request 对应请求
- (void)batchChainRequestSuccessed:(SWBatchChainRequest *)request;

/// 请求失败代理方法
/// @param request  对应请求
- (void)batchChainRequestFailed:(SWBatchChainRequest *)request;

@end

/// 并发请求链式请求，此请求中的并发请求会按顺序串行执行，单个并发请求中的单请求依然并发执行
@interface SWBatchChainRequest : NSObject

/// 并发请求数组，包含所有并发请求
@property (nonatomic, strong, readonly, nullable) NSArray <SWBatchRequest *> *requests;

/// 链式请求中第一个失败的请求，若请求全部成功，则为空
@property (nonatomic, strong, readonly, nullable) SWBatchRequest *failedRequest;

/// 请求代理
@property (nonatomic, weak, nullable) id <SWBatchChainRequestDelegate> delegate;

/// 请求成功回调，仅在请求成功之后回调
@property (nonatomic, copy, nullable) SWBatchChainRequestCompletionBlock successBlock;

/// 请求失败回调，仅在请求失败之后回调
@property (nonatomic, copy, nullable) SWBatchChainRequestCompletionBlock failureBlock;

/// 请求完成回调，无论请求成功或失败，都会回调
@property (nonatomic, copy, nullable) SWBatchChainRequestCompletionBlock completedBlock;

/// 初始化方法
+ (instancetype)request;

/// 开始请求
- (void)start;

/// 结束请求
- (void)stop;

/// 请求开始快捷构造方法
/// @param success 成功回调
/// @param failure 失败回调
/// @param completed 完成回调
- (void)startWithSuccess:(nullable SWBatchChainRequestCompletionBlock)success
                 failure:(nullable SWBatchChainRequestCompletionBlock)failure
               completed:(nullable SWBatchChainRequestCompletionBlock)completed;

/// 清空所有回调
- (void)clearCompletionBlock;

/// 添加下一个并发请求到链式请求
/// @param request 要添加的请求
/// @param block 添加下一个并发请求回调
- (void)nextRequest:(SWBatchRequest *)request block:(SWNextBatchChainRequestBlock)block;

@end

NS_ASSUME_NONNULL_END
