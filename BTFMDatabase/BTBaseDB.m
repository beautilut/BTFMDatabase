//
// Created by Beautilut on 2017/6/7.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "BTBaseDB.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <MJExtension/MJExtension.h>
#import "MJExtension.h"
#import "BTDBManager.h"

static char BTDBBase_Key_RowID;

@implementation BTBaseDB {

}

+(void)propertyContainer:(id)container objectWithClassDecider:(BOOL(^)(Class tmpClass , BOOL * stop))classDecider
{
    Class tmpClass = [self class];

    while (tmpClass) {
        if (classDecider) {
            BOOL stop = NO;

            while (tmpClass && !classDecider(tmpClass  , &stop)) {
                tmpClass = class_getSuperclass(tmpClass);
            }
            if (stop) {
                break;
            }

        }

        unsigned int count = 0;

        objc_property_t  * firstProperty = class_copyPropertyList(tmpClass, &count);
        objc_property_t property;

        for (NSInteger i = 0; i < count; ++i) {
            property = *(firstProperty + i) ;

            const char * propertyName = property_getName(property);
            if ([@(propertyName) isEqualToString:@"rowid"]) {
                continue;
            }

            BTDBProperty * btdbProperty = [[BTDBProperty alloc] initWithProperty:&property];
            if (btdbProperty) {
                [[self class] addConstraintWithProperty:btdbProperty];

                if ([container respondsToSelector:@selector(addObject:)]) {
                    [container addObject:btdbProperty];
                }else if([container respondsToSelector:@selector(setObject:forKey:)]) {
                    [container setObject:btdbProperty forKey:btdbProperty.columnName];
                }
            }
        }
        free(firstProperty);

        tmpClass = class_getSuperclass(tmpClass);
    }
}

+(NSMutableArray *)propertyListFromObject {
    NSMutableArray * pairs = [NSMutableArray array];

    [[self class] propertyContainer:pairs objectWithClassDecider:^BOOL(Class tmpClass, BOOL *stop) {
        if (tmpClass == [NSObject class]) {
            *stop = YES;
            return NO;
        }
        return YES;
    }];
    return pairs;
}

+(NSMutableDictionary *)propertyDictionaryFromObject {
    NSMutableDictionary * pairs = [NSMutableDictionary dictionary];
    [[self class] propertyContainer:pairs objectWithClassDecider:^BOOL(Class tmpClass, BOOL *stop) {
        if (tmpClass == [NSObject class]) {
            *stop = YES;
            return NO;
        }
        return YES;
    }];
    return pairs;
}

+(NSString *)tableName {
    [[self class] doesNotRecognizeSelector:_cmd];
    return nil;
}

+(void)addConstraintWithProperty:(BTDBProperty *)property {
    //subclasses can implementation
}

-(void)modelWithProperty:(BTDBProperty *)property value:(id)value {

    Class columnClass = NSClassFromString(property.propertyType);

    id modelValue = nil;

    NSString * columnType = property.columnType;
    if (columnClass == nil) {
        if ([columnType isEqualToString:DB_Type_Double])
        {
            double number = [value doubleValue];
            modelValue = @(number);
        }else if ([columnType isEqualToString:DB_Type_Int]) {
            if ([property.propertyType isEqualToString:@"long"]){
                long long number = [value longLongValue];
                modelValue = [NSNumber numberWithLongLong:number];
            }else {
                NSInteger number = [value integerValue];
                modelValue = [NSNumber numberWithInteger:number];
            }
        }else if ([columnType isEqualToString:@"CGRect"]) {
            CGRect rect = CGRectFromString(value);
            modelValue = [NSValue valueWithCGRect:rect];
        }else if ([columnType isEqualToString:@"CGPoint"]){
            CGPoint point  = CGPointFromString(value);
            modelValue = [NSValue valueWithCGPoint:point];
        }else if ([columnType isEqualToString:@"CGSize"]) {
            CGSize size = CGSizeFromString(value);
            modelValue = [NSValue valueWithCGSize:size];
        }else if ([columnType isEqualToString:@"_NSRange"]) {
            NSRange range = NSRangeFromString(value);
            modelValue = [NSValue valueWithRange:range];
        }

        if (modelValue == nil) {
            modelValue = @(0);
        }
    }else if ([columnType isEqualToString:DB_Type_Blob]) {
        if ([columnClass isSubclassOfClass:[NSObject class]]) {
            @try {
                modelValue = [NSKeyedUnarchiver unarchiveObjectWithData:value];
            } @catch (NSException * exception){
                modelValue = nil;
            } @finally {
                ;
            }
        }
    }else if ([value length] == 0) {
        //为了不继续遍历
    }else if ([columnClass isSubclassOfClass:[NSString class]]) {
        modelValue = value;
    }else if ([columnClass isSubclassOfClass:[NSNumber class]]) {
        modelValue = [NSNumber numberWithDouble:[value doubleValue]];
    }else if ([columnClass isSubclassOfClass:[UIImage class]]) {
        //TODO: 存在本地 ，存本地文件url ， 防止数据库过大
        modelValue = [UIImage imageWithContentsOfFile:value];
    }else {
        if ([columnClass isKindOfClass:[NSArray class]]) {
            modelValue = [value mj_JSONObject];
        }else if ([columnClass isKindOfClass:[NSDictionary class]]) {
            modelValue = [value mj_JSONObject];
        }
    }
    [self setValue:modelValue forKey:property.columnName];
}

-(id)valueForProperty:(BTDBProperty *)property {
    //subClasses can implementation
    id value = [self valueForKey:property.columnName];
    id returnValue = value;
    if (value == nil) {
        return nil;
    } else if ([value isKindOfClass:[NSString class]]) {
        returnValue = value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        returnValue = [value stringValue];
    } else if ([value isKindOfClass:[NSValue class]]) {
        NSString * columnType = property.propertyType;

        if ([columnType isEqualToString:@"CGRect"]) {
            returnValue = NSStringFromCGRect([value CGRectValue]);
        }else if ([columnType isEqualToString:@"CGPoint"]) {
            returnValue = NSStringFromCGPoint([value CGPointValue]);
        }else if ([columnType isEqualToString:@"CGSize"]) {
            returnValue = NSStringFromCGSize([value CGSizeValue]);
        }else if ([columnType isEqualToString:@"_NSRange"]) {
            returnValue = NSStringFromRange([value rangeValue]);
        }
    }else if ([value isKindOfClass:[NSObject class]]) {
        returnValue = [NSKeyedArchiver archivedDataWithRootObject:value];
    }else if ([value isSubclassOfClass:[UIImage class]]) {
        //TODO: 存在本地，存本地文件url 防止数据库过大
        returnValue = nil;
    }else {
        if ([value isKindOfClass:[NSArray class]]) {
            returnValue = [value mj_JSONString];
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            returnValue = [value mj_JSONString];
        }
    }
    return returnValue;
}

-(NSString *)joinedDeleteConditionColume:(NSString *)column {
    return [NSString stringWithFormat:@"%@=?" , column];
}

#pragma mark  -
-(void)setRowid:(NSInteger)rowid {
    objc_setAssociatedObject(self , &BTDBBase_Key_RowID, [NSNumber numberWithInteger:rowid], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)rowid {
    return [objc_getAssociatedObject(self , &BTDBBase_Key_RowID) integerValue];
}

+(BTDBManager *)dbManager {
    return [BTDBManager shareDBManager];
}

#pragma mark  -
+(BOOL)createTable {
    BTDBManager * manager = [[self class] dbManager];
    return [manager createTableWithClass:[self class]];
}
#pragma mark  -- search --
+(void)searchWithCondition:(BTDBSearchCondition *)condition completion:(void (^)(NSArray *))completion {
    BTDBManager * manager = [[self class] dbManager];
    [manager searchWithClass:[self class] condition:condition completion:completion];
}

+(NSArray *)searchWithCondition:(BTDBSearchCondition *)condition {
    BTDBManager * manager = [[self class] dbManager];
    return [manager searchWithClass:[self class] condition:condition];
}

#pragma mark -- update --
-(void)updateModelWithCondition:(BTDBCondition *)condition completion:(void (^)(BOOL))completion {
    BTDBManager * manager = [[self class] dbManager];
    [manager updateWithDB:self withCondition:condition completion:completion];
}

-(BOOL)updateModelWithCondition:(BTDBCondition *)condition {
    BTDBManager * manager = [[self class] dbManager];
    return [manager updateWithDB:self withCondition:condition];
}

#pragma mark -- inser --
-(void)insertModelCompletion:(void (^)(BOOL))completion {
    BTDBManager * manager = [[self class] dbManager];
    [manager insertWithDB:self completion:completion];
}

-(BOOL)insertModel {
    BTDBManager * manager = [[self class] dbManager];
    return  [manager insertWithDB:self];
}

#pragma mark -- delete --
-(void)deleteModelCompletion:(void (^)(BOOL))completion {
    BTDBManager * manager = [[self class] dbManager];
    [manager deleteWithDB:self completion:completion];
}

-(BOOL)deleteModel {
    BTDBManager * manager = [[self class] dbManager];
    return [manager deleteWithDB:self];
}

+(BOOL)deleteAll {
    BTDBManager * manager = [[self class] dbManager];
    return [manager deleteAllWithClass:[self class]];
}

#pragma mark -- trigger by user --
+(void)clearCacheByUser {
    BTDBManager * manager = [[self class] dbManager];
    [manager deleteAllWithClass:[self class]];
}
@end
