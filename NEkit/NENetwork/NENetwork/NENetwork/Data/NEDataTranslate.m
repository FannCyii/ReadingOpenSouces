//
//  NEDataTranslate.m
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import "NEDataTranslate.h"
#import "NEAssert.h"

@implementation NEDataTranslate

+ (NSString *)stringFromData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[NSString alloc] initWithData:data encoding:encoding];
}

+ (NSString *)stringWithUTF8FromData:(NSData *)data
{
    return [NEDataTranslate stringFromData:data encoding:NSUTF8StringEncoding];
}


/**
 解析NSData为对应对象，需要自行判断类型

 @param data <#data description#>
 @param option <#option description#>
 @return <#return value description#>
 */
+ (id)translateData:(NSData *)data option:(NSJSONReadingOptions)option{
    NSError *error = nil;
    id tData = [NSJSONSerialization JSONObjectWithData:data options:option error:&error];
    if (error) {
        NEAssertLog(error.localizedDescription);
        return nil;
    }
    return tData;
}

+ (id)jsonFromData:(NSData *)data
{
    return [NEDataTranslate translateData:data option:NSJSONReadingAllowFragments];
}

+ (NSDictionary *)dictonaryFromData:(NSData *)data option:(NSJSONReadingOptions)option
{
    id tData = [NEDataTranslate translateData:data option:NSJSONReadingAllowFragments];
    if (![tData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return (NSDictionary *)tData;
}


@end
