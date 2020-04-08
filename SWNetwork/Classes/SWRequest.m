//
//  SWRequest.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWRequest.h"
#import "SWNetworkManager.h"

inline SWRequest *Request(SWHTTPMethod method, NSString *path, id parameters) {
    SWRequest *req = [SWRequest request];
    req.httpMethod = method;
    req.path = path;
    req.parameters = parameters;
    return req;
}

@implementation SWRequest

+ (instancetype)request {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseURL = @"";
        _allowsCellularAccess = YES;
    }
    return self;
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.completedBlock = nil;
}

- (void)start {
    if ([_delegate respondsToSelector:@selector(requestWillStart:)]) {
        [_delegate requestWillStart:self];
    }
    
    // 发送请求
    [[SWNetworkManager shareManager] pokeRequest:self];
    
    if ([_delegate respondsToSelector:@selector(requestDidStart:)]) {
        [_delegate requestDidStart:self];
    }
}

- (void)stop {
    if ([_delegate respondsToSelector:@selector(requestWillStop:)]) {
        [_delegate requestWillStop:self];
    }
    
    self.delegate = nil;
    // 取消请求
    [[SWNetworkManager shareManager] cancelRequest:self];
    
    if ([_delegate respondsToSelector:@selector(requestDidStop:)]) {
        [_delegate requestDidStop:self];
    }
}

- (void)startWithSuccess:(SWRequestCompletionBlock)success failure:(SWRequestCompletionBlock)failure completed:(SWRequestCompletionBlock)completed {
    [self setCompletionBlockWithSuccess:success failure:failure completed:completed];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(SWRequestCompletionBlock)success failure:(SWRequestCompletionBlock)failure completed:(SWRequestCompletionBlock)completed {
    self.successBlock = success;
    self.failureBlock = failure;
    self.completedBlock = completed;
}

@end
