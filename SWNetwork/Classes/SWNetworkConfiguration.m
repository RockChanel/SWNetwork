//
//  SWNetworkConfiguration.m
//  GWMediatorExample
//
//  Created by Pactera on 2019/7/29.
//  Copyright © 2019 Pactera. All rights reserved.
//

#import "SWNetworkConfiguration.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation SWNetworkConfiguration

+ (SWNetworkConfiguration *)sharedConfiguration {
    static SWNetworkConfiguration *networkConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkConfiguration = [[self alloc] init];
    });
    return networkConfiguration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseURL = @"";
        _timeoutInterval = 30;
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _logEnable = NO;
        _showActivityIndicator = YES;
    }
    return self;
}

@end
