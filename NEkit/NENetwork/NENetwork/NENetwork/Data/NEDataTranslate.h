//
//  NEDataTranslate.h
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEDataTranslate : NSObject

//NSData to NSString
+ (NSString *)stringFromData:(NSData *)data encoding:(NSStringEncoding)encoding;
+ (NSString *)stringWithUTF8FromData:(NSData *)data;

//NSData to id
+ (id)translateData:(NSData *)data option:(NSJSONReadingOptions)option;

/**
 返回响应对象，如果JSON文件不正确则报错

 @param data <#data description#>
 @return <#return value description#>
 */
+ (id)jsonFromData:(NSData *)data;

//NSData to NSDictionary
+ (NSDictionary *)dictonaryFromData:(NSData *)data option:(NSJSONReadingOptions)option;


@end
