//
//  SWBatchChainRequest.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/8/6.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWBatchChainRequest.h"
#import "SWBatchRequest.h"
#import "SWNetworkAgent.h"
#import "SWNetworkConfiguration.h"

@interface SWBatchChainRequest() <SWBatchRequestDelegate>
/// 下一个请求索引，默认是0
@property (nonatomic, assign) NSInteger nextRequestIndex;
/// 所有请求数组
@property (nonatomic, strong) NSMutableArray <SWBatchRequest *> *requests;
/// 所有请求执行完下一步回调
@property (strong, nonatomic) NSMutableArray <SWNextBatchChainRequestBlock> *nextBlocks;
/// 空回调
@property (nonatomic, strong) SWNextBatchChainRequestBlock emptyBlock;

@end

@implementation SWBatchChainRequest

+ (instancetype)request {
    return [[self alloc] init];
}

- (void)dealloc {
    // 清空所有请求
    [self clearRequest];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _nextRequestIndex = 0;
        _requests = [NSMutableArray array];
        _nextBlocks = [NSMutableArray array];
        _emptyBlock = ^(SWBatchRequest * _Nonnull currentRequest) {
            
        };
    }
    return self;
}

- (void)nextRequest:(SWBatchRequest *)request block:(SWNextBatchChainRequestBlock)block {
    // 请求不能为空
    NSParameterAssert(request != nil);
    [_requests addObject:request];
    
    if (block != nil) {
        [_nextBlocks addObject:block];
    }
    else {
        [_nextBlocks addObject:_emptyBlock];
    }
}

- (void)start {
    if (_nextRequestIndex > 0) {
        // 请求已经开始
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request has already started.");
        }
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(batchChainRequestWillStart:)]) {
        [_delegate batchChainRequestWillStart:self];
    }
    
    if (_requests.count > 0) {
        [self startNextRequest];
        [[SWNetworkAgent shareAgent] addBatchChainRequest:self];
        
        if ([_delegate respondsToSelector:@selector(batchChainRequestDidStart:)]) {
            [_delegate batchChainRequestDidStart:self];
        }
    } else {
        // 还没有添加任何请求
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request array is empty.");
        }
        // 当子请求数为0个，则默认直接请求成功
        [self handleRequestSuccess];
    }
}

- (void)stop {
    if ([_delegate respondsToSelector:@selector(batchChainRequestWillStop:)]) {
        [_delegate batchChainRequestWillStop:self];
    }
    
    _delegate = nil;
    [self clearRequest];
    [[SWNetworkAgent shareAgent] removeBatchChainRequest:self];
    
    if ([_delegate respondsToSelector:@selector(batchChainRequestDidStop:)]) {
        [_delegate batchChainRequestDidStop:self];
    }
}

- (void)startWithSuccess:(SWBatchChainRequestCompletionBlock)success failure:(SWBatchChainRequestCompletionBlock)failure completed:(SWBatchChainRequestCompletionBlock)completed {
    [self setCompletionBlockWithSuccess:success failure:failure completed:completed];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(SWBatchChainRequestCompletionBlock)success failure:(SWBatchChainRequestCompletionBlock)failure completed:(SWBatchChainRequestCompletionBlock)completed {
    self.successBlock = success;
    self.failureBlock = failure;
    self.completedBlock = completed;
}

/// 开始下一个请求
- (void)startNextRequest {
    SWBatchRequest *request = _requests[_nextRequestIndex];
    request.delegate = self;
    [request clearCompletionBlock];
    _nextRequestIndex++;
    [request start];
}

/// 并发请求成功代理事件回调
- (void)batchRequestSuccessed:(SWBatchRequest *)request {
    // 返回前一个请求的结果
    NSInteger currentRequestIndex = _nextRequestIndex - 1;
    SWNextBatchChainRequestBlock currentBlock = _nextBlocks[currentRequestIndex];
    currentBlock(request);
    
    if (_nextRequestIndex < _requests.count) {
        [self startNextRequest];
    }
    else {
        // 全部请求都已完成，结束链式请求
        [self handleRequestSuccess];
        [[SWNetworkAgent shareAgent] removeBatchChainRequest:self];
    }
}

/// 并发请求失败代理事件回调
- (void)batchRequestFailed:(SWBatchRequest *)request {
    _failedRequest = request;
    
    [self handleRequestFailed];
    [[SWNetworkAgent shareAgent] removeBatchChainRequest:self];
}

- (void)clearRequest {
    NSInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < 0) {
        // 请求未开始
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request hasn't started yet.");
        }
        return;
    }
    if (currentRequestIndex < _requests.count) {
        SWBatchRequest *request = _requests[currentRequestIndex];
        [request stop];
    }
    [_requests removeAllObjects];
    [_nextBlocks removeAllObjects];
    [self clearCompletionBlock];
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.completedBlock = nil;
}

/// 处理请求成功结果
- (void)handleRequestSuccess {
    if ([_delegate respondsToSelector:@selector(batchChainRequestWillStop:)]) {
        [_delegate batchChainRequestWillStop:self];
    }
    if ([_delegate respondsToSelector:@selector(batchChainRequestSuccessed:)]) {
        [_delegate batchChainRequestSuccessed:self];
    }
    if (_successBlock) {
        _successBlock(self);
    }
    if ([_delegate respondsToSelector:@selector(batchChainRequestDidStop:)]) {
        [_delegate batchChainRequestDidStop:self];
    }
    if (_completedBlock) {
        _completedBlock(self);
    }
    [self clearCompletionBlock];
}

/// 处理请求失败结果
- (void)handleRequestFailed {
    if ([_delegate respondsToSelector:@selector(batchChainRequestWillStop:)]) {
        [_delegate batchChainRequestWillStop:self];
    }
    if ([_delegate respondsToSelector:@selector(batchChainRequestFailed:)]) {
        [_delegate batchChainRequestFailed:self];
    }
    if (_failureBlock) {
        _failureBlock(self);
    }
    if ([_delegate respondsToSelector:@selector(batchChainRequestDidStop:)]) {
        [_delegate batchChainRequestDidStop:self];
    }
    if (_completedBlock) {
        _completedBlock(self);
    }
    
    [self clearCompletionBlock];
}

- (NSArray<SWBatchRequest *> *)requests {
    return _requests;
}

@end
