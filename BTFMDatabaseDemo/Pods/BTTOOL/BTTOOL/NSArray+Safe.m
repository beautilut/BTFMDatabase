//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "NSArray+Safe.h"
#import "NSObject+ImpChangeTool.h"
#import "BTDefineTool.h"

@implementation NSArray (Safe)

+(void)load {
    static dispatch_once_t onceToken;
    WeakObjectDef(self);
    dispatch_once(&onceToken, ^{
        [weakself swizzlingMethod:@"objectAtIndex:" systemClassString:@"__NSArray0" toSafeMethodString:@"hook_0_objectAtIndex:" targetClassString:@"NSArray"];
        [weakself swizzlingMethod:@"objectAtIndex:" systemClassString:@"__NSArrayI" toSafeMethodString:@"hook_I_objectAtIndex:" targetClassString:@"NSArray"];
        [weakself swizzlingMethod:@"objectAtIndex:" systemClassString:@"__NSArrayM" toSafeMethodString:@"hook_M_objectAtIndex:" targetClassString:@"NSArray"];
        [weakself swizzlingMethod:@"objectAtIndex:" systemClassString:@"__NSSingObjectArrayI" toSafeMethodString:@"hook_S_objectAtIndex:" targetClassString:@"NSArray"];
        [weakself swizzlingMethod:@"initWithObjects:count:" systemClassString:@"__NSPlaceHolderArray" toSafeMethodString:@"hook_initWithObjects:count:" targetClassString:@"NSArray"];
    });
}

-(id)hook_0_objectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self warningWithIndex:index];
        return nil;
    }
    return [self hook_0_objectAtIndex:index];
}

-(id)hook_I_objectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self warningWithIndex:index];
        return nil;
    }
    return [self hook_I_objectAtIndex:index];
}

-(id)hook_M_objectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self warningWithIndex:index];
        return nil;
    }
    return [self hook_M_objectAtIndex:index];
}

-(id)hook_S_objectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self warningWithIndex:index];
        return nil;
    }
    return [self hook_S_objectAtIndex:index];
}

-(instancetype)hook_initWithObjects:(id *)objects count:(NSUInteger)count {
    NSUInteger newCount = 0;
    for (NSUInteger i = 0 ; i < count ; i++) {
        if (!objects[i]) {
            break;
        }
        newCount ++;
    }
    [self hook_initWithObjects:objects count:count];
    return self;
}

-(id)forwardingTargetForSelector:(SEL)aSelector {
    NSMutableDictionary * dic = [@{} mutableCopy];
    if ([dic respondsToSelector:aSelector]) {
        return dic;
    }
    return [super forwardingTargetForSelector:aSelector];
}

-(void)warningWithIndex:(NSUInteger)index {
    return;
}
@end

@implementation NSMutableArray (Safe)

+(void)load {
    static dispatch_once_t onceToken;
    WeakObjectDef(self);
    dispatch_once(&onceToken, ^{
        [weakself swizzlingMethod:@"addObject:" systemClassString:@"__NSArrayM" toSafeMethodString:@"hook_addObject:" targetClassString:@"NSMutableArray"];
        [weakself swizzlingMethod:@"insertObject:atIndex:" systemClassString:@"__NSArrayM" toSafeMethodString:@"hook_insertObject:atIndex:" targetClassString:@"NSMutableArray"];
        [weakself swizzlingMethod:@"removeObjectAtIndex:" systemClassString:@"__NSArrayM" toSafeMethodString:@"hook_removeObjectAtIndex:" targetClassString:@"NSMutableArray"];
        [weakself swizzlingMethod:@"replaceObjectAtIndex:withObject:" systemClassString:@"__NSArrayM" toSafeMethodString:@"hook_replaceObjectAtIndex:withObject:" targetClassString:@"NSMutableArray"];
        [weakself swizzlingMethod:@"removeObjectsAtIndexes:" systemClassString:@"NSMutableArray" toSafeMethodString:@"hook_removeObjectsAtIndexes:" targetClassString:@"NSMutableArray"];
        [weakself swizzlingMethod:@"removeObjectsInRnage:" systemClassString:@"NSMutableArray" toSafeMethodString:@"hook_removeObjectsInRange:" targetClassString:@"NSMutableArray"];
    });
}

-(void)hook_addObject:(id)anObject {
    if(!anObject) {
        return;;
    }
    [self hook_addObject:anObject];
}

-(void)hook_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if(index > [self count]) {
        [self warningWithIndex:index];
        return;
    }
    if (!anObject) {
        return ;
    }
    [self hook_insertObject:anObject atIndex:index];
}

-(void)hook_removeObjectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self warningWithIndex:index];
        return;;
    }
    return [self hook_removeObjectAtIndex:index];
}

-(void)hook_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index >= [self count]) {
        [self warningWithIndex:index];
        return;
    }
    if (!anObject) {
        return;
    }
    [self hook_replaceObjectAtIndex:index withObject:anObject];
}

-(void)hook_removeObjectsAtIndexes:(NSIndexSet *)indexes {
    NSMutableIndexSet * mutableSet = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx < [self count]) {
            [mutableSet addIndex:idx];
        }
    }];
    [self hook_removeObjectsAtIndexes:indexes];
}

-(void)hook_removeObjectsInRange:(NSRange)range {

    //
    if (range.location + range.length - 1 < [self count]) {
        [self hook_removeObjectsInRange:range];
        return;
    }
    if (range.location >= [self count]) {
        return;
    }

    NSInteger tempInteger = range.location + range.length -1 ;
    while (tempInteger >= [self count]) {
        tempInteger -= 1;
    }
    NSRange tempRange = NSMakeRange(range.location, tempInteger + 1 - range.location);
    [self hook_removeObjectsInRange:tempRange];

}

@end
