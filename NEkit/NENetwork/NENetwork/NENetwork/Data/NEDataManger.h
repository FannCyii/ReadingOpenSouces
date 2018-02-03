//
//  NEDataManger.h
//  NENetwork
//
//  Created by kivan on 07/08/2017.
//  Copyright © 2017 kivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEDataManger : NSObject

+ (NSString *)stringFromData:(NSData *)data;

+ (NSArray *)arrayFromData:(NSData *)data;

+ (NSDictionary *)dictionaryFromData:(NSData *)data;

@end
