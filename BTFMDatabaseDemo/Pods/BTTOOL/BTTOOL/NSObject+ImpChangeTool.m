//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "NSObject+ImpChangeTool.h"
#import <objc/runtime.h>

@implementation NSObject (ImpChangeTool)

+(void)swizzlingMethod:(NSString *)systemMethodString
     systemClassString:(NSString *)systemClassString
    toSafeMethodString:(NSString *)safeMethodString
     targetClassString:(NSString *)targetClassString {

    Method sysMethod = class_getInstanceMethod(NSClassFromString(systemClassString), NSSelectorFromString(systemMethodString));
    Method hookMethod = class_getInstanceMethod(NSClassFromString(targetClassString), NSSelectorFromString(safeMethodString));
    method_exchangeImplementations(hookMethod, sysMethod);
}

@end