//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "NSDictionary+Safe.h"
#import <objc/runtime.h>
#import "NSObject+ImpChangeTool.h"
#import "BTDefineTool.h"

@implementation NSDictionary (Safe)

+(void)load {
    WeakObjectDef(self);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [weakself swizzlingMethod:@"initWithObjects:forKeys:cocunt:" systemClassString:@"__NSPlaceholderDictionary" toSafeMethodString:@"initWithObjects_safe:forKeys:count:" targetClassString:@"NSDictionary"];
    });
}

/*
 * 只能添加后缀 不然类簇不能识别
 */

-(instancetype)initWithObjects_safe:(id *)objects forKeys:(id<NSCopying> *)keys count:(NSUInteger)count {

    NSUInteger rightCount = 0;

    for (NSUInteger i = 0 ; i < count ; i ++) {
        if (!(keys[i] && objects[i])) {
            break;
        }else {
            rightCount ++;
        }
    }

    self  = [self initWithObjects_safe:objects forKeys:keys count:count];
    return self;

}

-(id)forwardingTargetForSelector:(SEL)aSelector {
    NSMutableArray * array = [@{} mutableCopy];
    if ([array respondsToSelector:aSelector]) {
        return array;
    }
    return [super forwardingTargetForSelector:aSelector];
}

-(void)warnWithKey:(id)key value:(id)obj sel:(SEL)sel
{
    return;
}

@end


@implementation NSMutableDictionary (Safe)

+(void)load {
    static dispatch_once_t onceToken;
    WeakObjectDef(self);
    dispatch_once(&onceToken, ^{
        [weakself swizzlingMethod:@"removeObjectForKey:" systemClassString:@"__NSDictionaryM" toSafeMethodString:@"hook_removeObjectForKey:" targetClassString:@"NSMutableDictionary"];
        [weakself swizzlingMethod:@"setObject:forKey:" systemClassString:@"__NSDictionaryM" toSafeMethodString:@"hook_setObject:forKey:" targetClassString:@"NSMutableDictionary"];
        [weakself swizzlingMethod:@"setValue:forKey:" systemClassString:@"__NSDictionaryM" toSafeMethodString:@"hook_setValue:forKey:" targetClassString:@"NSMutableDictionary"];
    });
}

-(void)hook_removeObjectForKey:(id)key {
    if (!key) {
        [self warnWithKey:key value:nil sel:_cmd];
        return;
    }
    [self hook_removeObjectForKey:key];
}

-(void)hook_setObject:(id)obj forKey:(id <NSCopying>)key {
    if (!obj) {
        return;
    }
    if (!key) {
        [self warnWithKey:key value:obj sel:_cmd];
        return;
    }
    [self hook_setObject:obj forKey:key];
}

-(void)hook_setValue:(id)obj forKey:(id <NSCopying>)key {
    if (!obj) {
        return;
    }
    if (!key) {
        [self warnWithKey:key value:obj sel:_cmd];
        return;
    }
    [self hook_setValue:obj forKey:key];
}

@end
