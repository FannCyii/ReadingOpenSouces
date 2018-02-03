//
//  ViewController.m
//  Example
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import "ViewController.h"
#import <NENetwork/NENetwork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NERequestConfig *config = [NERequestConfig requestConfig];
    config.server = @"http://192.168.1.103:9777";
    config.businessMethod = @"testMethod";
    
    NERequest * req = [NERequest requestWithConfig:config completeBlock:^(id completeDate, NSError *error) {
        NSLog(@"%@",completeDate);
    } cancelBlock:nil];
    [req start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
