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
/// The index of next request. Default is 0.
@property (nonatomic, assign) NSInteger nextRequestIndex;
/// All the batch requests.
@property (nonatomic, strong) NSMutableArray <SWBatchRequest *> *requests;
/// All the next callbacks.
@property (strong, nonatomic) NSMutableArray <SWNextBatchChainRequestBlock> *nextBlocks;
@end

@implementation SWBatchChainRequest

+ (instancetype)request {
    return [[self alloc] init];
}

- (void)dealloc {
    [self clearRequest];
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

- (SWBatchChainRequest *)next:(SWNextBatchChainRequestBlock)block {
    // The block can not be nil.
    NSParameterAssert(block != nil);
    SWBatchRequest *nextRequest = [SWBatchRequest request];
    if (0 == _requests.count) {
        // If have not added a batch request, callback immediately. The previous request here is nil.
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
        if ([_delegate respondsToSelector:@selector(batchChainRequestWillStart:)]) {
            [_delegate batchChainRequestWillStart:self];
        }
        [self startNextRequest];
        [[SWNetworkAgent shareAgent] addBatchChainRequest:self];
        
        if ([_delegate respondsToSelector:@selector(batchChainRequestDidStart:)]) {
            [_delegate batchChainRequestDidStart:self];
        }
    } else {
        if ([SWNetworkConfiguration sharedConfiguration].isLogEnable) {
            NSLog(@"Error! Chain request array is empty.");
        }
    }
}

- (void)stop {
    if ([_delegate respondsToSelector:@selector(batchChainRequestWillStop:)]) {
        [_delegate batchChainRequestWillStop:self];
    }
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

- (void)startNextRequest {
    SWBatchRequest *request = _requests[_nextRequestIndex];
    _nextRequestIndex++;
    request.delegate = self;
    [request clearCompletionBlock];
    [request start];
}

- (void)batchRequestSuccessed:(SWBatchRequest *)request {
    if (_nextRequestIndex < _requests.count) {
        SWNextBatchChainRequestBlock nextBlock = _nextBlocks[_nextRequestIndex];
        SWBatchRequest *nextRequest = _requests[_nextRequestIndex];
        nextBlock(request, nextRequest);
        [self startNextRequest];
    }
    else {
        // All requests have been excuted.
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
        [[SWNetworkAgent shareAgent] removeBatchChainRequest:self];
    }
}

- (void)batchRequestFailed:(SWBatchRequest *)request {
    _failedRequest = request;
    
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
    [[SWNetworkAgent shareAgent] removeBatchChainRequest:self];
}

- (void)clearRequest {
    NSInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < 0) {
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
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.completedBlock = nil;
}

- (NSArray<SWBatchRequest *> *)requests {
    return _requests;
}

@end
