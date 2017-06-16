//
// Created by Beautilut on 2017/6/7.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const KDBManagerOpenedNotification;
extern NSString * const KDBManagerClosedNotification;


@class BTBaseDB;
@class BTDBSearchCondition;
@class BTDBCondition;

@interface BTDBManager : NSObject

+(BTDBManager *)shareDBManager;

-(BOOL)openDBWithName:(NSString*)dbName;

-(void)closeDB;

-(BOOL)dbIsOpen;

-(BOOL)createTableWithClass:(Class)dbClass;

// Search
-(void)searchWithClass:(Class)dbClass
             condition:(BTDBSearchCondition *)condition
            completion:(void(^)(NSArray *))completion;

-(NSArray *)searchWithClass:(Class)dbClass
                  condition:(BTDBSearchCondition *)condition;

// Insert
-(void)insertWithDB:(BTBaseDB *)db completion:(void(^)(BOOL))completion;

-(BOOL)insertWithDB:(BTBaseDB *)db;

// Update
-(void)updateWithDB:(BTBaseDB *)db
      withCondition:(BTDBCondition *)condition
         completion:(void(^)(BOOL))completion;

-(BOOL)updateWithDB:(BTBaseDB *)db withCondition:(BTDBCondition *)condition;

// Delete
-(void)deleteWithDB:(BTBaseDB *)db completion:(void(^)(BOOL))completion;

-(BOOL)deleteWithDB:(BTBaseDB *)db;

-(BOOL)deleteAllWithClass:(Class)dbClass;
@end