//
//  NEDataManger.m
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import "NEDataManger.h"
#import "NEDataTranslate.h"

@implementation NEDataManger


+ (NSString *)stringFromData:(NSData *)data
{
    return [NEDataTranslate stringWithUTF8FromData:data];
}

+ (NSArray *)arrayFromData:(NSData *)data
{
    id tData = [NEDataManger dataOfResponds:data];
    if ([tData isKindOfClass:[NSArray class]]) {
        return (NSArray *)data;
    }
    return nil;
}

+ (NSDictionary *)dictionaryFromData:(NSData *)data
{
    id tData = [NEDataManger dataOfResponds:data];
    if ([tData isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)data;
    }
    return nil;
}

+ (id)dataOfResponds:(NSData *)data
{
    id tData = [NEDataTranslate jsonFromData:data];
    return tData;
}


@end
