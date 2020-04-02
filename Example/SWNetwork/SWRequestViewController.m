//
//  SWRequestViewController.m
//  SWNetwork_Example
//
//  Created by Pactera on 2020/4/2.
//  Copyright © 2020 selwyn. All rights reserved.
//

#import "SWRequestViewController.h"
#import <SWNetwork.h>
#import <MBProgressHUD.h>
#import "SWCustomRequest.h"

@interface SWRequestViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *datas;

@end

@implementation SWRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.datas = @[
        @{@"title": @"单个请求"},
        @{@"title": @"自定义单个请求"},
        @{@"title": @"并发请求"},
        @{@"title": @"链式请求"}
    ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.datas[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self request];
            break;
        case 1:
            [self customRequest];
        break;
        case 2:
            [self batchRequest];
        break;
        case 3:
            [self chainRequest];
        break;
        default:
            break;
    }
}

/// 单个请求
- (void)request {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[SWNetworkAgent request:^(SWRequest * _Nonnull request) {
        // 请求配置
        request.httpMethod = SWHTTPMethodGET;
        request.path = @"service/regeo";
        request.parameters = @{
                                @"longitude": @"119.04925573429551",
                                @"latitude": @"31.315590522490712"
                               };
        
    }] startWithSuccess:^(SWRequest * _Nonnull request) {
        NSLog(@"request === %@", request.responseObject);
    
    } failure:^(SWRequest * _Nonnull request) {
        NSLog(@"request === %@", request.error);
        
    } completed:^(SWRequest * _Nonnull request) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

/// 自定义单个请求
- (void)customRequest {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    SWCustomRequest *request = [SWCustomRequest request];
    
    [request startWithSuccess:^(SWRequest * _Nonnull request) {
        NSLog(@"custom request === %@", request.responseObject);
        
    } failure:^(SWRequest * _Nonnull request) {
        NSLog(@"custom request === %@", request.error);
        
    } completed:^(SWRequest * _Nonnull request) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


/// 并发请求
- (void)batchRequest {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[SWNetworkAgent batchRequest:^(SWBatchRequest * _Nonnull request) {
        
        // 多请求数组
        NSMutableArray *requests = [NSMutableArray array];
        
        SWRequest *tmpReq1 = [SWRequest request];
        tmpReq1.httpMethod = SWHTTPMethodGET;
        tmpReq1.path = @"service/regeo";
        tmpReq1.parameters = @{
            @"longitude": @"119.04925573429551",
            @"latitude": @"31.315590522490712"
        };
        tmpReq1.tag = 100;
        [requests addObject:tmpReq1];
        
        SWCustomRequest *tmpReq2 = [SWCustomRequest request];
        tmpReq2.tag = 200;
        [requests addObject:tmpReq2];
        
        request.requests = requests;
        
    }] startWithSuccess:^(SWBatchRequest * _Nonnull request) {
        
        // 根据tag值获取对应请求
//        for (SWRequest *req in request.requests) {
//            if (req.tag == 100) {
//                NSLog(@"tmpReq1 == %@", req.responseObject);
//            }
//            else {
//                NSLog(@"tmpReq2 == %@", req.responseObject);
//            }
//        }
        
        // 根据index获取对应请求
        NSLog(@"tmpReq1 == %@", request.requests[0].responseObject);
        NSLog(@"tmpReq2 == %@", request.requests[1].responseObject);
        
    } failure:^(SWBatchRequest * _Nonnull request) {
        
        NSLog(@"tmpReq1 == %@", request.requests[0].error);
        NSLog(@"tmpReq2 == %@", request.requests[1].error);
        
    } completed:^(SWBatchRequest * _Nonnull request) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

/// 链式请求
- (void)chainRequest {
    
    [[SWNetworkAgent chainRequest:^(SWChainRequest * _Nonnull request) {
        [[request next:^(SWRequest * _Nullable previousRequest, SWRequest * _Nonnull nextRequest) {
            nextRequest.httpMethod = SWHTTPMethodGET;
            nextRequest.path = @"service/regeo";
            nextRequest.parameters = @{
                @"longitude": @"119.04925573429551",
                @"latitude": @"31.315590522490712"
            };
            nextRequest.tag = 100;
        }] next:^(SWRequest * _Nullable previousRequest, SWRequest * _Nonnull nextRequest) {
            
           
        }];
    }] startWithSuccess:^(SWChainRequest * _Nonnull request) {
        
    } failure:^(SWChainRequest * _Nonnull request) {
        
    } completed:^(SWChainRequest * _Nonnull request) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
