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

/**
 \~chinese
 并发请求代理方法，所有的代理方法将在主线程执行
 
 \~english
 The SWBatchRequestDelegate protocol defines several optional methods you can use to receive network-related messages. All the delegate methods will be called on the main queue.
 */
@protocol SWBatchRequestDelegate <NSObject>

@optional

/**
 \~chinese
 请求即将开始代理方法
 
 \~english
 Notify that the batch request is about to start.
 
 @param request The corresponding request.
 */
- (void)batchRequestWillStart:(SWBatchRequest *)request;

/**
 \~chinese
 请求已经开始代理方法
 
 \~english
 Notify that the batch request has already started.
 
 @param request The corresponding request.
 */
- (void)batchRequestDidStart:(SWBatchRequest *)request;

/**
 \~chinese
 请求即将结束代理方法
 
 \~english
 Notify that the batch request is about to stop.
 
 @param request The corresponding request.
 */
- (void)batchRequestWillStop:(SWBatchRequest *)request;

/**
 \~chinese
 请求已经结束代理方法
 
 \~english
 Notify that the batch request has already stop.
 
 @param request The corresponding request.
 */
- (void)batchRequestDidStop:(SWBatchRequest *)request;

/**
 \~chinese
 请求成功代理方法
 
 \~english
 Notify that the batch request has finished successfully.

 @param request The corresponding request.
 */
- (void)batchRequestSuccessed:(SWBatchRequest *)request;

/**
 \~chinese
 请求失败代理方法
 
 \~english
 Notify that the batch request has failed.

 @param request The corresponding request.
 */
- (void)batchRequestFailed:(SWBatchRequest *)request;

@end

/**
 单请求并发请求，此请求中的单请求将会并发执行
 */
@interface SWBatchRequest : NSObject

/**
 \~chinese
 所有请求数组
 
 \~english
 All the requests.
 */
@property (nonatomic, strong) NSArray <SWRequest *> *requests;

/**
 \~chinese
 并发请求中第一个失败的请求，若请求全部成功，则此时为空
 
 \~english
 The first failed request.
 */
@property (nonatomic, strong, readonly, nullable) SWRequest *failedRequest;

/**
 \~chinese
 请求标识，区分不同网络请求
 
 \~english
 Tag can be used to identify request. Default value is 0.
 */
@property (nonatomic) NSInteger tag;

/**
 \~chinese
 请求代理
 
 \~english
 The delegate object of the batch request. Default is nil.
 */
@property (nonatomic, weak, nullable) id <SWBatchRequestDelegate> delegate;

/**
 \~chinese
 请求成功回调
 
 \~english
 The success callback. Note this will be called only if all the requests are finished. Default is nil.
 */
@property (nonatomic, copy, nullable) SWBatchRequestCompletionBlock successBlock;

/**
 \~chinese
 请求失败回调
 
 \~english
 The failure callback. Note this will be called if one of the requests fails. Default is nil.
 */
@property (nonatomic, copy, nullable) SWBatchRequestCompletionBlock failureBlock;

/**
 \~chinese
 请求完成回调
 
 \~english
 The completed callback. Note this will be called after the batch request succeeds or fails. Default is nil.
 */
@property (nonatomic, copy, nullable) SWBatchRequestCompletionBlock completedBlock;

/**
 \~chinese
 生成请求静态方法
 
 \~english
 Creates and returns an `SWBatchRequest` object.
 */
+ (instancetype)request;

/**
 \~chinese
 请求开始
 
 \~english
 Start batch request.
 */
- (void)start;

/**
 \~chinese
 请求终止
 
 \~english
 Stop batch request.
 */
- (void)stop;

/**
 \~chinese
 请求开始，并设置成功、失败、完成回调
 
 \~english
 Convenience method to start the batch request with block callbacks.
 */
- (void)startWithSuccess:(nullable SWBatchRequestCompletionBlock)success
                 failure:(nullable SWBatchRequestCompletionBlock)failure
               completed:(nullable SWBatchRequestCompletionBlock)completed;

/**
 \~chinese
 清空所有回调
 
 \~english
 Nil out both success and failure callback blocks.
 */
- (void)clearCompletionBlock;


@end

NS_ASSUME_NONNULL_END
