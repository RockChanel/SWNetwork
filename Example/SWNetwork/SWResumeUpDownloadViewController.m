//
//  SWResumeUpDownloadViewController.m
//  SWNetwork_Example
//
//  Created by Pactera on 2020/4/8.
//  Copyright © 2020 selwyn. All rights reserved.
//

#import "SWResumeUpDownloadViewController.h"
#import <MBProgressHUD.h>
#import <SWNetwork.h>

@interface SWResumeUpDownloadViewController ()

@property (nonatomic, strong) SWRequest *downloadRequest;

@end

@implementation SWResumeUpDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.frame = CGRectMake(100, 100, 100, 50);
    [downloadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(100, 300, 100, 50);
    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
}

- (void)cancelAction {
    [self.downloadRequest stop];
}

- (void)downloadAction {
       // 下载路径
    NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    SWRequest *request = [SWRequest request];
    request.downloadPath = downloadDir;
    request.path = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
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
        
    }];
    self.downloadRequest = request;
}

@end
