//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ImpChangeTool)

/**
 *  交换两个函数实现指针 ， 参数均为NSString 类型
 *
 * @param systemMethodString 系统方法名String
 * @param systemClassString 系统实现方法类名String
 * @param safeMethodString 自定义hook方法名String
 * @param targetClassString 目标实现类名String
 */

+(void)swizzlingMethod:(NSString*)systemMethodString
     systemClassString:(NSString*)systemClassString
    toSafeMethodString:(NSString*)safeMethodString
     targetClassString:(NSString*)targetClassString;

@end