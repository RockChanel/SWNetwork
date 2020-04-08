//
//  SWUpDownloadViewController.m
//  SWNetwork_Example
//
//  Created by Pactera on 2020/4/3.
//  Copyright © 2020 selwyn. All rights reserved.
//

#import "SWUpDownloadViewController.h"
#import <SWNetwork.h>
#import <MBProgressHUD.h>

@interface SWUpDownloadViewController () <UITableViewDelegate, UITableViewDataSource, SWBatchRequestDelegate>

@property (nonatomic, strong) NSArray *datas;

@end

@implementation SWUpDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.datas = @[
        @{@"title": @"单个上传请求"},
        @{@"title": @"单个下载请求"},
        @{@"title": @"并发上传请求"},
        @{@"title": @"并发下载请求"}
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
            [self upload];
            break;
        case 1:
            [self download];
            break;
        case 2:
            [self batchUpload];
            break;
        case 3:
            [self batchDownload];
            break;
        default:
            break;
    }
}

- (void)upload {
    
}

- (void)batchUpload {
    
}

/// 下载请求
- (void)download {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // 下载路径
    NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.jpg"];
       
    SWRequest *request = Request(SWHTTPMethodGET, @"https://tva3.sinaimg.cn/large/0072Vf1pgy1fodqpadh6zj31kw14nnpe.jpg", nil);
    request.downloadPath = downloadDir;
    request.progressBlock = ^(NSProgress * _Nonnull progress) {
        CGFloat stauts = 100.f * progress.completedUnitCount/progress.totalUnitCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新UI需回归主线程
            NSLog(@"download test progress ==== %@", [NSString stringWithFormat:@"%.2f", stauts/100.f]);
        });
    };
    [request startWithSuccess:^(SWRequest * _Nonnull request) {
        
        NSLog(@"download test path === %@", request.responseObject);
        
    } failure:^(SWRequest * _Nonnull request) {
        
    } completed:^(SWRequest * _Nonnull request) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

/// 并发下载
- (void)batchDownload {
    // 下载路径
    NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localPath1 = [downloadDir stringByAppendingPathComponent:@"batch_download_1.jpg"];
    NSString *localPath2 = [downloadDir stringByAppendingPathComponent:@"batch_download_2.jpg"];
    NSString *localPath3 = [downloadDir stringByAppendingPathComponent:@"batch_download_3.jpg"];
    
    NSMutableArray *requests = [NSMutableArray array];
    
    SWRequest *downloadReq1 = [SWRequest request];
    downloadReq1.downloadPath = localPath1;
    downloadReq1.path = @"https://tva3.sinaimg.cn/large/0072Vf1pgy1fodqpadh6zj31kw14nnpe.jpg";
    downloadReq1.progressBlock = ^(NSProgress * _Nonnull progress) {
        CGFloat stauts = 100.f * progress.completedUnitCount/progress.totalUnitCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新UI需回归主线程
            NSLog(@"download test1 progress ==== %@", [NSString stringWithFormat:@"%.2f", stauts/100.f]);
        });
    };
    [requests addObject:downloadReq1];
    
    SWRequest *downloadReq2 = [SWRequest request];
    downloadReq2.downloadPath = localPath2;
    downloadReq2.path = @"https://tva1.sinaimg.cn/large/005BYqpgly1frn9csmf3dj31hc0u0b29.jpg";
    downloadReq2.progressBlock = ^(NSProgress * _Nonnull progress) {
        CGFloat stauts = 100.f * progress.completedUnitCount/progress.totalUnitCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新UI需回归主线程
            NSLog(@"download test2 progress ==== %@", [NSString stringWithFormat:@"%.2f", stauts/100.f]);
        });
    };
    [requests addObject:downloadReq2];
    
    SWRequest *downloadReq3 = [SWRequest request];
    downloadReq3.downloadPath = localPath3;
    downloadReq3.path = @"https://tva2.sinaimg.cn/large/005BYqpgly1frn9d2e3iaj31hc0u01kx.jpg";
    downloadReq3.progressBlock = ^(NSProgress * _Nonnull progress) {
        CGFloat stauts = 100.f * progress.completedUnitCount/progress.totalUnitCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新UI需回归主线程
            NSLog(@"download test3 progress ==== %@", [NSString stringWithFormat:@"%.2f", stauts/100.f]);
        });
    };
    [requests addObject:downloadReq3];
    
    SWBatchRequest *batchRequest = [SWBatchRequest request];
    batchRequest.requests = requests;
    batchRequest.delegate = self;
    [batchRequest start];
}

- (void)batchRequestWillStart:(SWBatchRequest *)request {
    NSLog(@"batchRequestWillStart --- ");
}

- (void)batchRequestDidStart:(SWBatchRequest *)request {
    NSLog(@"batchRequestDidStart --- ");
}

- (void)batchRequestSuccessed:(SWBatchRequest *)request {
    NSLog(@"batchRequestSuccessed --- ");
    NSLog(@"batch download result === %@", request.requests[0].responseObject);
    NSLog(@"batch download result === %@", request.requests[1].responseObject);
    NSLog(@"batch download result === %@", request.requests[2].responseObject);
}

- (void)batchRequestFailed:(SWBatchRequest *)request {
    NSLog(@"batchRequestFailed --- ");
}

- (void)batchRequestWillStop:(SWBatchRequest *)request {
    NSLog(@"batchRequestWillStop --- ");
}

- (void)batchRequestDidStop:(SWBatchRequest *)request {
    NSLog(@"batchRequestDidStop --- ");
}

@end
