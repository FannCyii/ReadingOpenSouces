//
//  NERequest.h
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NERequestConfig.h"

@interface NERequest : NSObject

@property (nonatomic, strong)NERequestConfig *config;

@property (nonatomic, copy)NERequestCompleteBlock compeleBlock;
@property (nonatomic, copy)NERequestCancleBlock cancleBlock;
@property (nonatomic, copy)NEProgressBlock progressBlock;


+ (NERequest *)requestWithConfig:(NERequestConfig *)config;
+ (NERequest *)requestWithConfig:(NERequestConfig *)config completeBlock:(NERequestCompleteBlock)completeBlock cancelBlock:(NERequestCancleBlock)cancleBlock;
+ (NERequest *)requestWithConfig:(NERequestConfig *)config completeBlock:(NERequestCompleteBlock)completeBlock cancelBlock:(NERequestCancleBlock)cancleBlock progrocess:(NEProgressBlock)progressBlock;

- (void)start;

@end
