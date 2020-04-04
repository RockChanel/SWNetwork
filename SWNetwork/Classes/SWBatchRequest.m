//
//  SWBatchRequest.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/30.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWBatchRequest.h"
#import "SWRequest.h"
#import "SWNetworkAgent.h"
#import "SWNetworkConfiguration.h"

#define LOCK() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define UNLOCK() dispatch_semaphore_signal(self->_lock)

@interface SWBatchRequest() <SWRequestDelegate>
@property (strong, nonatomic, nonnull) dispatch_semaphore_t lock;
/// 记录已完成的请求个数
@property (nonatomic, assign) NSInteger completedCount;
@end

@implementation SWBatchRequest

+ (instancetype)request {
    return [[self alloc] init];
}

- (void)dealloc {
    [self clearRequest];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _completedCount = 0;
    }
    return self;
}

- (void)start {
    if ([_delegate respondsToSelector:@selector(batchRequestWillStart:)]) {
        [_delegate batchRequestWillStart:self];
    }
    if (_completedCount > 0) {
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Batch request has already started.");
        }
        return;
    }
    _failedRequest = nil;
    
    if (_requests.count > 0) {
        [[SWNetworkAgent shareAgent] addBatchRequest:self];
        // 发送所有请求
        for (SWRequest *req in _requests) {
            req.delegate = self;
            [req clearCompletionBlock];
            [req start];
        }
        
        if ([_delegate respondsToSelector:@selector(batchRequestDidStart:)]) {
            [_delegate batchRequestDidStart:self];
        }
    }
    else {
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Batch request array is empty.");
            [self clearCompletionBlock];
        }
    }
}

- (void)stop {
    if ([_delegate respondsToSelector:@selector(batchRequestWillStop:)]) {
        [_delegate batchRequestWillStop:self];
    }
    _delegate = nil;
    [self clearRequest];
    [[SWNetworkAgent shareAgent] removeBatchRequest:self];
    
    if ([_delegate respondsToSelector:@selector(batchRequestDidStop:)]) {
        [_delegate batchRequestDidStop:self];
    }
}

/**
 终止当前并发请求中所有请求
 */
- (void)clearRequest {
    for (SWRequest *req in _requests) {
        [req stop];
    }
    [self clearCompletionBlock];
}

- (void)startWithSuccess:(SWBatchRequestCompletionBlock)success failure:(SWBatchRequestCompletionBlock)failure completed:(SWBatchRequestCompletionBlock)completed {
    [self setCompletionBlockWithSuccess:success failure:failure completed:completed];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(SWBatchRequestCompletionBlock)success failure:(SWBatchRequestCompletionBlock)failure completed:(SWBatchRequestCompletionBlock)completed {
    self.successBlock = success;
    self.failureBlock = failure;
    self.completedBlock = completed;
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.completedBlock = nil;
}

/**
 单个请求请求成功代理事件回调

 @param request 对应的请求
 */
- (void)requestSuccessed:(SWRequest *)request {
    LOCK();
    _completedCount++;
    UNLOCK();
    
    // 所有请求都已成功完成
    if (_completedCount == _requests.count) {
        if ([_delegate respondsToSelector:@selector(batchRequestWillStop:)]) {
            [_delegate batchRequestWillStop:self];
        }
        if ([_delegate respondsToSelector:@selector(batchRequestSuccessed:)]) {
            [_delegate batchRequestSuccessed:self];
        }
        if (_successBlock) {
            _successBlock(self);
        }
        if ([_delegate respondsToSelector:@selector(batchRequestDidStop:)]) {
            [_delegate batchRequestDidStop:self];
        }
        if (_completedBlock) {
            _completedBlock(self);
        }
        
        [self clearCompletionBlock];
        [[SWNetworkAgent shareAgent] removeBatchRequest:self];
    }
}

/**
 单个请求请求失败代理事件回调

 @param request 对应的请求
 */
- (void)requestFailed:(SWRequest *)request {
    _failedRequest = request;
    
    if ([_delegate respondsToSelector:@selector(batchRequestWillStop:)]) {
        [_delegate batchRequestWillStop:self];
    }
    for (SWRequest *req in _requests) {
        [req stop];
    }

    if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
        [_delegate batchRequestFailed:self];
    }
    if (_failureBlock) {
        _failureBlock(self);
    }
    if ([_delegate respondsToSelector:@selector(batchRequestDidStop:)]) {
        [_delegate batchRequestDidStop:self];
    }
    if (_completedBlock) {
        _completedBlock(self);
    }
    
    [self clearCompletionBlock];
    [[SWNetworkAgent shareAgent] removeBatchRequest:self];
}


@end
