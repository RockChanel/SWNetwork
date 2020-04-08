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

/// 添加单个请求的回调
/// @param currentRequest 前一个刚结束的请求
typedef void (^SWNextChainRequestBlock)(SWRequest *currentRequest);

/// 并发请求代理方法，所有的代理方法将在主线程执行
@protocol SWChainRequestDelegate <NSObject>

@optional

/// 请求即将开始代理方法
/// @param request 对应请求
- (void)chainRequestWillStart:(SWChainRequest *)request;

/// 请求已经开始代理方法
/// @param request 对应请求
- (void)chainRequestDidStart:(SWChainRequest *)request;

/// 请求即将结束代理方法
/// @param request 对应请求
- (void)chainRequestWillStop:(SWChainRequest *)request;

/// 请求已经结束代理方法
/// @param request 对应请求
- (void)chainRequestDidStop:(SWChainRequest *)request;

/// 请求成功代理方法
/// @param request 对应请求
- (void)chainRequestSuccessed:(SWChainRequest *)request;

/// 请求失败代理方法
/// @param request 对应请求
- (void)chainRequestFailed:(SWChainRequest *)request;

@end

/// 单请求链式请求，此请求中的单请求会按顺序串行执行
@interface SWChainRequest : NSObject

/// 请求数组
@property (nonatomic, strong, readonly, nullable) NSArray <SWRequest *> *requests;

/// 链式请求中第一个失败的请求，若请求全部成功，则为空
@property (nonatomic, strong, readonly, nullable) SWRequest *failedRequest;

/// 请求代理
@property (nonatomic, weak, nullable) id <SWChainRequestDelegate> delegate;

/// 请求成功回调，仅在请求成功之后回调
@property (nonatomic, copy, nullable) SWChainRequestCompletionBlock successBlock;

/// 请求失败回调，仅在请求失败之后回调
@property (nonatomic, copy, nullable) SWChainRequestCompletionBlock failureBlock;

/// 请求完成回调，无论请求成功或失败，都会回调
@property (nonatomic, copy, nullable) SWChainRequestCompletionBlock completedBlock;

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
- (void)startWithSuccess:(nullable SWChainRequestCompletionBlock)success
                 failure:(nullable SWChainRequestCompletionBlock)failure
               completed:(nullable SWChainRequestCompletionBlock)completed;

/// 清空所有回调
- (void)clearCompletionBlock;

/// 添加下一个单个请求到链式请求
/// @param request 要添加的请求
/// @param block 添加下一个单个请求回调
- (void)nextRequest:(SWRequest *)request block:(nullable SWNextChainRequestBlock)block;

@end

NS_ASSUME_NONNULL_END
