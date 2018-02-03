//
//  NEAssert.m
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import "NEAssert.h"



static NEAssertRank assertRank = 0;

@implementation NEAssert
+ (void)assertNo:(NSString *)description
{
    [NEAssert assertWith:NO description:description];
}

+ (void)assertWith:(BOOL)condition description:(NSString *)description
{
#if DEBUG
    if (assertRank == NEAssertRankPrint) {
        [NEAssert nePrint:description];
    }else if (assertRank == NEAssertRankLog){
        [NEAssert neLog:description];
    }else if (assertRank == NEAssertRankError){
        NSAssert(condition, @"[NEAssert_Assert]:%@",description);
    }
#endif
}

    
/**
 设置断言级别

 @param rank 级别
 */
+ (void)setNeAssertRank:(NEAssertRank)rank
{
    assertRank = rank;
}
    
    
+ (void)nePrint:(NSString *)str
{
    NSLog(@"[NEAssert_Print]:%@",str);
}
    
+ (void)neLog:(NSString *)str
{
    //save log
    //....
    
    NSLog(@"[NEAssert_Log]:%@",str);
}
    
@end
