//
//  SWCustomRequest.m
//  SWNetwork_Example
//
//  Created by Pactera on 2020/4/1.
//  Copyright © 2020 selwyn. All rights reserved.
//

#import "SWCustomRequest.h"

@implementation SWCustomRequest

/// 配置baseURL
- (NSString *)baseURL {
    return @"https://ditu.amap.com/";
}

- (NSString *)path {
    return @"service/regeo";
}

/// 请求参数
- (id)parameters {
    return @{
            @"longitude": @"120.04925573429551",
            @"latitude": @"31.315590522490712"
            };
}

/// 请求方式
- (SWHTTPMethod)httpMethod {
    return SWHTTPMethodGET;
}

@end
