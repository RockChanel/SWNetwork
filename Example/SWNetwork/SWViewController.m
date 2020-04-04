//
//  SWViewController.m
//  SWNetwork
//
//  Created by selwyn on 03/27/2020.
//  Copyright (c) 2020 selwyn. All rights reserved.
//

#import "SWViewController.h"
#import "SWRequestViewController.h"
#import "SWUpDownloadViewController.h"

@interface SWViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *datas;

@end

@implementation SWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"SWNetwork";
    
    self.datas = @[
        @{@"title": @"通用请求"},
        @{@"title": @"上传下载"},
        @{@"title": @"断点续传、断点下载"}
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
        {
            SWRequestViewController *requestVC = [[SWRequestViewController alloc] init];
            [self.navigationController pushViewController:requestVC animated:YES];
        }
            break;
        case 1:
        {
            SWUpDownloadViewController *updownloadVC = [[SWUpDownloadViewController alloc] init];
            [self.navigationController pushViewController:updownloadVC animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
