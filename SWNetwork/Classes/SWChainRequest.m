//
//  SWChainRequest.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/30.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWChainRequest.h"
#import "SWRequest.h"
#import "SWBatchRequest.h"
#import "SWNetworkAgent.h"
#import "SWNetworkConfiguration.h"

@interface SWChainRequest() <SWRequestDelegate>
/// 下一个请求索引值，从0开始
@property (nonatomic, assign) NSInteger nextRequestIndex;
/// 所有请求数组
@property (nonatomic, strong) NSMutableArray <SWRequest *> *requests;
/// 所有请求执行完下一步回调
@property (strong, nonatomic) NSMutableArray <SWNextChainRequestBlock> *nextBlocks;
@end

@implementation SWChainRequest

+ (instancetype)request {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _nextRequestIndex = 0;
        _requests = [NSMutableArray array];
        _nextBlocks = [NSMutableArray array];
    }
    return self;
}

- (SWChainRequest *)next:(SWNextChainRequestBlock)block {
    // The block can not be nil.
    NSParameterAssert(block != nil);
    SWRequest *nextRequest = [SWRequest request];
    if (0 == _requests.count) {
        // If have not added a request, callback immediately. The previous request here is nil.
        // 如果第一次添加请求，则立即先执行回调
        block(nil, nextRequest);
    }
    [_requests addObject:nextRequest];
    [_nextBlocks addObject:block];
    return self;
}

- (void)start {
    if (_nextRequestIndex > 0) {
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request has already started.");
        }
        return;
    }
    if (_requests.count > 0) {
        if ([_delegate respondsToSelector:@selector(chainRequestWillStart:)]) {
            [_delegate chainRequestWillStart:self];
        }
        [self startNextRequest];
        [[SWNetworkAgent shareAgent] addChainRequest:self];
        
        if ([_delegate respondsToSelector:@selector(chainRequestDidStart:)]) {
            [_delegate chainRequestDidStart:self];
        }
    } else {
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request array is empty.");
        }
    }
}

- (void)stop {
    if ([_delegate respondsToSelector:@selector(chainRequestWillStop:)]) {
        [_delegate chainRequestWillStop:self];
    }
    [self clearRequest];
    [[SWNetworkAgent shareAgent] removeChainRequest:self];
    
    if ([_delegate respondsToSelector:@selector(chainRequestDidStop:)]) {
        [_delegate chainRequestDidStop:self];
    }
}

- (void)startWithSuccess:(SWChainRequestCompletionBlock)success failure:(SWChainRequestCompletionBlock)failure completed:(SWChainRequestCompletionBlock)completed {
    [self setCompletionBlockWithSuccess:success failure:failure completed:completed];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(SWChainRequestCompletionBlock)success failure:(SWChainRequestCompletionBlock)failure completed:(SWChainRequestCompletionBlock)completed {
    self.successBlock = success;
    self.failureBlock = failure;
    self.completedBlock = completed;
}

- (void)startNextRequest {
    SWRequest *request = _requests[_nextRequestIndex];
    _nextRequestIndex++;
    request.delegate = self;
    [request clearCompletionBlock];
    [request start];
}

/**
 单个请求请求成功代理事件回调
 
 @param request 对应的请求
 */
- (void)requestSuccessed:(SWRequest *)request {
    if (_nextRequestIndex < _requests.count) {
        // 若索引值小于请求个数，则链式请求还未完成
        SWNextChainRequestBlock nextBlock = _nextBlocks[_nextRequestIndex];
        SWRequest *nextRequest = _requests[_nextRequestIndex];
        nextBlock(request, nextRequest);
        // 继续下一个请求
        [self startNextRequest];
    }
    else {
        // All requests have been excuted.
        // 所有请求都已执行完成
        if ([_delegate respondsToSelector:@selector(chainRequestWillStop:)]) {
            [_delegate chainRequestWillStop:self];
        }
        if ([_delegate respondsToSelector:@selector(chainRequestSuccessed:)]) {
            [_delegate chainRequestSuccessed:self];
        }
        if (_successBlock) {
            _successBlock(self);
        }
        if ([_delegate respondsToSelector:@selector(chainRequestDidStop:)]) {
            [_delegate chainRequestDidStop:self];
        }
        if (_completedBlock) {
            _completedBlock(self);
        }
        
        [self clearCompletionBlock];
        [[SWNetworkAgent shareAgent] removeChainRequest:self];
    }
}

/**
 单个请求请求失败代理事件回调
 
 @param request 对应的请求
 */
- (void)requestFailed:(SWRequest *)request {
    _failedRequest = request;
    
    if ([_delegate respondsToSelector:@selector(chainRequestWillStop:)]) {
        [_delegate chainRequestWillStop:self];
    }
    if ([_delegate respondsToSelector:@selector(chainRequestFailed:)]) {
        [_delegate chainRequestFailed:self];
    }
    if (_failureBlock) {
        _failureBlock(self);
    }
    
    if ([_delegate respondsToSelector:@selector(chainRequestDidStop:)]) {
        [_delegate chainRequestDidStop:self];
    }
    if (_completedBlock) {
        _completedBlock(self);
    }
    [self clearCompletionBlock];
    [[SWNetworkAgent shareAgent] removeChainRequest:self];
}

/**
 终止请求
 */
- (void)clearRequest {
    NSInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < 0) {
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request hasn't started yet.");
        }
        return;
    }
    // 取消之前的请求
    if (currentRequestIndex < _requests.count) {
        SWRequest *request = _requests[currentRequestIndex];
        [request stop];
    }
    [_requests removeAllObjects];
    [_nextBlocks removeAllObjects];
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.completedBlock = nil;
}

- (NSArray<SWRequest *> *)requests {
    return _requests;
}

@end
