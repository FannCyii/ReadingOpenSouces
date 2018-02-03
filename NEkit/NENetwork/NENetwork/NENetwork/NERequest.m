//
//  NERequest.m
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import "NERequest.h"
#import "NEDataManger.h"
#import "NEAssert.h"

const NSString *RequestQueue = @"ne.request.queue";

@interface NERequest ()

@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSMutableURLRequest *request;

@end


@implementation NERequest

+ (void)load
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [NSURLSession sharedSession];
        NEAssertRank3;
    }
    return self;
}

+ (NERequest *)requestWithConfig:(NERequestConfig *)config completeBlock:(NERequestCompleteBlock)completeBlock cancelBlock:(NERequestCancleBlock)cancleBlock progrocess:(NEProgressBlock)progressBlock
{
    NERequest *req = [[NERequest alloc] init];
    req.config = config;
    req.compeleBlock = completeBlock;
    req.cancleBlock = cancleBlock;
    req.progressBlock = progressBlock;
    return req;
}

+ (NERequest *)requestWithConfig:(NERequestConfig *)config completeBlock:(NERequestCompleteBlock)completeBlock cancelBlock:(NERequestCancleBlock)cancleBlock
{
    return [NERequest requestWithConfig:config completeBlock:completeBlock cancelBlock:cancleBlock progrocess:nil];
}

+ (NERequest *)requestWithConfig:(NERequestConfig *)config
{
    return [NERequest requestWithConfig:config completeBlock:nil cancelBlock:nil progrocess:nil];
}

#pragma mark - Add request header 添加请求头
- (void)addRequestHeader
{
    if (self.config.requestHeader.count == 0) {
        return;
    }
    for (NSString *key in self.config.requestHeader.allKeys) {
        [self.request addValue:self.config.requestHeader[key] forHTTPHeaderField:key];
    }
}


#pragma mark - Request  开始请求

- (void)start
{
    [self addRequestHeader];
    [self requestWithType:self.config.requstMethod];
}

- (void)requestWithType:(ReqMethod)requestType
{
    switch (requestType) {
        case NEReqGet:
            [self requestOfGet];
            break;
        case NEReqPost:
            [self requestOfPost];
            break;
        default:
            break;
    }
}

#pragma mark Get
- (void)requestOfGet
{
    NSString *serverStr = self.config.server;
    NSString *businessStr = self.config.businessMethod;
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverStr,businessStr]];
    self.request = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTast = [self.session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = self;
        if (error) {
            NEAssertLog(error.localizedDescription);
            return ;
        }
        if (strongSelf.compeleBlock) {
            NSError *err = nil;
            NSString *result  =[NEDataManger stringFromData:data];
            if (err) {
                NEAssertLog(err.localizedDescription);
                return;
            }
            strongSelf.compeleBlock(result, nil);
        }
    }];
    
    [dataTast resume];
}

#pragma mark Post
- (void)requestOfPost
{
    
}


@end
