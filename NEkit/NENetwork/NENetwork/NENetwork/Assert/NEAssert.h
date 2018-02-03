//
//  NEAssert.h
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*断言级别*/
typedef NS_ENUM(NSInteger, NEAssertRank) {
    NEAssertRankPrint   = 0,    //默认 ，只是打印
    NEAssertRankLog     = 1,    //打印和记录日志
    NEAssertRankError   = 2,    //断言
};


@interface NEAssert : NSObject
+ (void)assertNo:(NSString *)description;
    
/*
 设置断言级别
 */
+ (void)setNeAssertRank:(NEAssertRank)rank;

+ (void)nePrint:(NSString *)str;
+ (void)neLog:(NSString *)str;
@end

#define NEPrint(_str) [NEAssert nePrint:_str]
#define NELog(_str) [NEAssert neLog:_str]

#define NEAssertLog(_description) [NEAssert assertNo:_description]

#define NEAssertRank1 [NEAssert setNeAssertRank:NEAssertRankPrint]
#define NEAssertRank2 [NEAssert setNeAssertRank:NEAssertRankLog]
#define NEAssertRank3 [NEAssert setNeAssertRank:NEAssertRankError]
