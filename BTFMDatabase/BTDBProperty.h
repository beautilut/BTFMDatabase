//
// Created by Beautilut on 2017/6/7.
// Copyright (c) 2017 beautilut. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

extern NSString * const DB_Type_Text;
extern NSString * const DB_Type_Int;
extern NSString * const DB_Type_Double;
extern NSString * const DB_Type_Blob;

typedef enum : NSUInteger  {
    EDBColumnStatusNormal,
    EDBColumnStatusAddition,
    EDBColumnStatusRemove,
}EDBColumnStatus;

@interface BTDBProperty : NSObject


//是否是主键
@property (nonatomic , readonly) BOOL isPrimary;

//是否是无效字段
@property (nonatomic , readonly) BOOL isIgnore;

//是否是唯一性字段
@property (nonatomic , readonly) BOOL isUnique;

//是否可以为空字段
@property (nonatomic , readonly) BOOL isNotNull;

//字段状态
@property (nonatomic , readonly) EDBColumnStatus columnStatus;

//默认值
@property (nonatomic , nonatomic) NSString * defaultValue;

//
@property (nonatomic , nonatomic) NSString * checkValue;

//属性类型
@property (nonatomic , readonly) NSString * propertyType;

//列名称
@property (nonatomic , readonly) NSString * columnName;

//列类型
@property (nonatomic , readonly) NSString * columnType;

//该属性是否可以增删改
-(BOOL)propertyCanUpdate;

-(id)initWithProperty:(objc_property_t *)property;
@end
