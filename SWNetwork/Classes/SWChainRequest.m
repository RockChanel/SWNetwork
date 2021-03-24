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
/// 下一个请求索引值，默认为0
@property (nonatomic, assign) NSInteger nextRequestIndex;
/// 所有请求数组
@property (nonatomic, strong) NSMutableArray <SWRequest *> *requests;
/// 所有请求执行完下一步回调
@property (strong, nonatomic) NSMutableArray <SWNextChainRequestBlock> *nextBlocks;
/// 空回调
@property (nonatomic, strong) SWNextChainRequestBlock emptyBlock;

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
        _emptyBlock = ^(SWRequest * _Nullable previousRequest) {
            
        };
    }
    return self;
}

- (void)nextRequest:(SWRequest *)request block:(SWNextChainRequestBlock)block {
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
        // 请求已开始
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
        // 当子请求数为0个，则默认直接请求成功
        [self handleRequestSuccess];
    }
}

- (void)stop {
    if ([_delegate respondsToSelector:@selector(chainRequestWillStop:)]) {
        [_delegate chainRequestWillStop:self];
    }
    _delegate = nil;
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
    request.delegate = self;
    [request clearCompletionBlock];
    _nextRequestIndex++;
    [request start];
}

/// 单个请求请求成功代理事件回调
- (void)requestSuccessed:(SWRequest *)request {

    NSInteger currentRequestIndex = _nextRequestIndex - 1;
    SWNextChainRequestBlock currentBlock = _nextBlocks[currentRequestIndex];
    currentBlock(request);
    
    if (_nextRequestIndex < _requests.count) {
        // 若索引值小于请求个数，则链式请求还未完成，继续下一个请求
        [self startNextRequest];
    }
    else {
        // 所有请求都已执行完成
        [self handleRequestSuccess];
        [[SWNetworkAgent shareAgent] removeChainRequest:self];
    }
}

/// 单个请求请求失败代理事件回调
- (void)requestFailed:(SWRequest *)request {
    _failedRequest = request;
    
    [self handleRequestFailed];
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
    [self clearCompletionBlock];
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.completedBlock = nil;
}

/// 处理请求成功结果
- (void)handleRequestSuccess {
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
}

/// 处理请求失败结果
- (void)handleRequestFailed {
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
}


- (NSArray<SWRequest *> *)requests {
    return _requests;
}

@end
