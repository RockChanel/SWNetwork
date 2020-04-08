//
//  SWBatchRequest.h
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/30.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SWRequest, SWBatchRequest;

typedef void (^SWBatchRequestCompletionBlock)(SWBatchRequest *request);

/// 并发请求代理方法，所有的代理方法将在主线程执行
@protocol SWBatchRequestDelegate <NSObject>

@optional

/// 请求即将开始代理方法
/// @param request 对应请求
- (void)batchRequestWillStart:(SWBatchRequest *)request;

/// 请求已经开始代理方法
/// @param request 对应请求
- (void)batchRequestDidStart:(SWBatchRequest *)request;

/// 请求即将结束代理方法
/// @param request 对应请求
- (void)batchRequestWillStop:(SWBatchRequest *)request;

/// 请求已经结束代理方法
/// @param request  对应请求
- (void)batchRequestDidStop:(SWBatchRequest *)request;

/// 请求成功代理方法
/// @param request 对应请求
- (void)batchRequestSuccessed:(SWBatchRequest *)request;

/// 请求失败代理方法
/// @param request 对应请求
- (void)batchRequestFailed:(SWBatchRequest *)request;

@end

/// 单请求并发请求，请求中的单请求将会并发执行
@interface SWBatchRequest : NSObject

/// 请求数组
@property (nonatomic, strong) NSArray <SWRequest *> *requests;

/// 并发请求中第一个失败的请求，若请求全部成功，则为空
@property (nonatomic, strong, readonly, nullable) SWRequest *failedRequest;

/// 请求标识值，区分并发请求中的单个网络请求
@property (nonatomic) NSInteger tag;

/// 请求代理
@property (nonatomic, weak, nullable) id <SWBatchRequestDelegate> delegate;

/// 请求成功回调，仅在请求成功之后回调
@property (nonatomic, copy, nullable) SWBatchRequestCompletionBlock successBlock;

/// 请求失败回调，仅在请求失败之后回调
@property (nonatomic, copy, nullable) SWBatchRequestCompletionBlock failureBlock;

/// 请求完成回调，无论请求成功或失败，都会回调
@property (nonatomic, copy, nullable) SWBatchRequestCompletionBlock completedBlock;

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
- (void)startWithSuccess:(nullable SWBatchRequestCompletionBlock)success
                 failure:(nullable SWBatchRequestCompletionBlock)failure
               completed:(nullable SWBatchRequestCompletionBlock)completed;

/// 清空所有回调
- (void)clearCompletionBlock;


@end

NS_ASSUME_NONNULL_END
