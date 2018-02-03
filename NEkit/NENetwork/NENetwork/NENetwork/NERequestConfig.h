//
//  NERequestConfig.h
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 网络请求类型
 */
typedef NS_ENUM(NSInteger, ReqMethod){
    NEReqGet       = 0,
    NEReqPost      = 1,
};

/**
 获取数据的解析方式
 */
typedef NS_ENUM(NSInteger, RespAnalyseType){
    NERespAnalyseJSON  = 0, //Json解析
    NERespAnalyseXML   = 1, //XML解析
    NERespAnalyseYAML  = 2, //Yaml解析
};



/*-----Block------*/
/**
 网络请求完成回调block
 */
typedef void (^NERequestCompleteBlock)(id completeDate, NSError *error);

/**
 网络请求取消回调block
 */
typedef void (^NERequestCancleBlock)(NSError *error);
typedef void (^NEProgressBlock)(void);//+需修改


@interface NERequestConfig : NSObject



//请求唯一标识
@property (nonatomic, readonly)NSString *requestIdentifier;
/**
 回调block
 */
@property (nonatomic, copy)NERequestCompleteBlock compeleBlock;
@property (nonatomic, copy)NERequestCancleBlock cancleBlock;
@property (nonatomic, copy)NEProgressBlock processBlock;

/**
 服务器地址 访问方法名
 */
@property (nonatomic, strong)NSString * server;
@property (nonatomic, strong)NSString * businessMethod;

@property (nonatomic, assign)ReqMethod requstMethod;
//请求参数
@property (nonatomic, strong)NSDictionary *params;

//请求头
@property (nonatomic, strong)NSDictionary *requestHeader;

//解析方式
@property (nonatomic, assign)RespAnalyseType respondeAnalyseType;

//解析目标对象 className
@property (nonatomic, strong)NSString *className;

//是否显示加载动画
@property (nonatomic, assign)BOOL showLoading;
//能否取消
@property (nonatomic, assign)BOOL canCancel;
//是否使用缓存
@property (nonatomic, assign)BOOL useCache;
//请求失败后重试次数
@property (nonatomic, assign)NSInteger retryTimes;




/**
 创建方法

 @return NERequestConfig实例
 */
+ (instancetype)requestConfig;


@end

