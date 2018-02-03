/*	NSObjCRuntime.h
	Copyright (c) 1994-2012, Apple Inc. All rights reserved.
*/

#ifndef _OBJC_NSOBJCRUNTIME_H_
#define _OBJC_NSOBJCRUNTIME_H_

#include <TargetConditionals.h>
#include <objc/objc.h>

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
typedef long NSInteger;
typedef unsigned long NSUInteger;
#else
typedef int NSInteger;
typedef unsigned int NSUInteger;
#endif

#define NSIntegerMax    LONG_MAX
#define NSIntegerMin    LONG_MIN
#define NSUIntegerMax   ULONG_MAX

#define NSINTEGER_DEFINED 1

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
//用于指定 “指定初始化函数” 的宏 ，该宏较为详细的用法：https://www.jianshu.com/p/8fca8ff11b7b，通过这个宏可以看出各个类的“指定初始化函数” 即默认初始化函数，如：UIViewController的初试函数不是init。子类有指定初始化函数时，那么init函数就不再是指定初始化函数，需手动重写init函数，并且init初始化时调用本类的指定初始化函数进行初始化
//关联swift的初始化函数相关知识，异曲同工
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

#endif
