//
// Created by Beautilut on 2017/6/7.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTDBProperty.h"
#import "BTDBCondition.h"

#pragma mark  - key protocol -
//表示为主键

@protocol BTDBKeyPrimay
@end

//表示可以忽略字段
@protocol BTDBKeyIgnore
@end

//表示唯一字段
@protocol BTDBKeyUnique
@end

//表示不能为空
@protocol BTDBKeyNotNull
@end

#pragma mark -- column protocol --
//表示新增字段
@protocol BTDBKeyAddition
@end

//表示需要删除的字段
@protocol BTDBKeyRemove
@end

#pragma mark --

@class BTDBManager;

@interface BTBaseDB : NSObject

@property NSInteger rowid;

+(NSMutableArray * )propertyListFromObject;
+(NSMutableDictionary *)propertyDictionaryFromObject;

/**
 *  使用的DBManager
 * @return null
 */
+(BTDBManager *)dbManager;

/**
 *  表名
 * @return null
 */
+(NSString *)tableName;

/**
 *  创建表
 * @return null
 */
+(BOOL)createTable;

/**
 *  增加对应属性的约束，主要是defalutvalue 和 checkValue 默认无
 * @param property null
 */
+(void)addConstraintWithProperty:(BTDBProperty *)property;

/**
 *  db对应字段值转模型
 * @param property null
 * @param value null
 */
-(void)modelWithProperty:(BTDBProperty *)property value:(id)value;

/**
 *  模型转db对应字段值
 * @param property null
 * @return null
 */
-(id)valueForProperty:(BTDBProperty *)property;

/**
 *
 * @param column null
 * @return null
 */
-(NSString *)joinedDeleteConditionColume:(NSString *)column;

/**
 *  异步执行查询
 * @param condition 查询条件模型 ， 可为空
 * @param completion 完成回调block
 */
+(void)searchWithCondition:(BTDBSearchCondition *)condition completion:(void(^)(NSArray*))completion;

/**
 *  同步执行查询
 * @param condition 查询条件模型 ， 可为空
 * @return null
 */
+(NSArray *)searchWithCondition:(BTDBSearchCondition *)condition;

/**
 *     异步执行更新
 * @param condition 更新条件模型 ， 可为空
 * @param completion 完成回调block
 */
-(void)updateModelWithCondition:(BTDBCondition *)condition completion:(void(^)(BOOL))completion;


/**
 *  同步执行更新
 * @param condition 更新条件模型 可为空
 * @return null
 */
-(BOOL)updateModelWithCondition:(BTDBCondition *)condition;



/**
 *  异步执行插入
 * @param completion 完成回调block
 */
-(void)insertModelCompletion:(void(^)(BOOL))completion;

/**
 *  同步执行插入
 * @return 成功 / 失败
 */
-(BOOL)insertModel;

/**
 *  异步执行删除
 * @param completion 完成回调block
 */
-(void)deleteModelCompletion:(void(^)(BOOL))completion;

/**
 *  同步执行删除
 * @return 成功 /失败
 */
-(BOOL)deleteModel;

/**
 *  删除该表所有数据
 * @return 成功 / 失败
 */
+(BOOL)deleteAll;

/**
 *  用户手动清楚缓存所调用的方法
 */
+(void)clearCacheByUser;

@end
