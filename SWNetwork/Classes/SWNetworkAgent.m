//
//  SWNetworkAgent.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/8/5.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWNetworkAgent.h"
#import "SWRequest.h"
#import "SWBatchRequest.h"
#import "SWChainRequest.h"
#import "SWBatchChainRequest.h"
#import "SWNetworkConfiguration.h"

#define LOCK() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define UNLOCK() dispatch_semaphore_signal(self->_lock)

@interface SWNetworkAgent()
/// 信号量锁
@property (strong, nonatomic, nonnull) dispatch_semaphore_t lock;
/// 并发请求维护数组
@property (nonatomic, strong) NSMutableArray <SWBatchRequest *> *batchRequests;
/// 链式请求维护数组
@property (strong, nonatomic) NSMutableArray <SWChainRequest *> *chainRequests;
/// 并发链式请求维护数组
@property (strong, nonatomic) NSMutableArray <SWBatchChainRequest *> *batchChainRequests;
@end

@implementation SWNetworkAgent

+ (instancetype)shareAgent {
    static SWNetworkAgent *agent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agent = [[self alloc] init];
    });
    return agent;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _batchRequests = [NSMutableArray array];
        _chainRequests = [NSMutableArray array];
        _batchChainRequests = [NSMutableArray array];
    }
    return self;
}

+ (SWRequest *)request:(void (^)(SWRequest * _Nonnull))configBlock {
    SWRequest *request = [SWRequest request];
    if (configBlock) {
        configBlock(request);
    }
    return request;
}

+ (SWBatchRequest *)batchRequest:(void (^)(SWBatchRequest * _Nonnull))configBlock {
    SWBatchRequest *request = [SWBatchRequest request];
    if (configBlock) {
        configBlock(request);
    }
    return request;
}

+ (SWChainRequest *)chainRequest:(void (^)(SWChainRequest * _Nonnull))configBlock {
    SWChainRequest *request = [SWChainRequest request];
    if (configBlock) {
        configBlock(request);
    }
    return request;
}

+ (SWBatchChainRequest *)batchChainRequest:(void (^)(SWBatchChainRequest * _Nonnull))configBlock {
    SWBatchChainRequest *request = [SWBatchChainRequest request];
    if (configBlock) {
        configBlock(request);
    }
    return request;
}

- (void)addBatchRequest:(SWBatchRequest *)request {
    LOCK();
    [_batchRequests addObject:request];
    UNLOCK();
}

- (void)removeBatchRequest:(SWBatchRequest *)request {
    LOCK();
    [_batchRequests removeObject:request];
    UNLOCK();
}

- (void)addChainRequest:(SWChainRequest *)request {
    LOCK();
    [_chainRequests addObject:request];
    UNLOCK();
}

- (void)removeChainRequest:(SWChainRequest *)request {
    LOCK();
    [_chainRequests removeObject:request];
    UNLOCK();
}

- (void)addBatchChainRequest:(SWBatchChainRequest *)request {
    LOCK();
    [_batchChainRequests addObject:request];
    UNLOCK();
}

- (void)removeBatchChainRequest:(SWBatchChainRequest *)request {
    LOCK();
    [_batchChainRequests removeObject:request];
    UNLOCK();
}


@end
