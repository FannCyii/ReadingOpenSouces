//
//  NERequestConfig.m
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import "NERequestConfig.h"

@implementation NERequestConfig

+ (instancetype)requestConfig{
    return [[NERequestConfig alloc] init];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.showLoading = NO;
        self.requstMethod = NEReqGet;
        self.respondeAnalyseType = NERespAnalyseJSON;
    }
    return self;
}

@end
