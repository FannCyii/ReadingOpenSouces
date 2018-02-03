//
//  ViewController.m
//  Demo_AFN
//
//  Created by chengqifan on 2017/2/26.
//  Copyright © 2017年 yhd. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL * url = [NSURL URLWithString:@"https://baiud.com"];

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0f];

    //设置请求头
//    [request setValue:<#(nullable NSString *)#> forHTTPHeaderField:<#(nonnull NSString *)#>] //设置请求头
    
    //设置请求体
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:<#(nonnull id)#> options:<#(NSJSONWritingOptions)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>];
//    request.HTTPBody = jsonData

    
    // 异步请求  该方法 已被弃用
//    [NSURLConnection sendSynchronousRequest:request returningResponse:[[NSOperationQueue alloc] init] error:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        // 有的时候，服务器访问正常，但是会没有数据
//        // 以下的 if 是比较标准的错误处理代码
//        if (connectionError != nil || data == nil) {
//            //给用户的提示信息
//            NSLog(@"网络不给力");
//            return;
//        }
//    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
