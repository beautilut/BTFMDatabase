//
// Created by Beautilut on 2017/6/8.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTDBConditionPair : NSObject
@property (nonatomic , strong) NSArray * conditionArray;
@property (nonatomic , strong) NSDictionary * equlPair;
@property (nonatomic , strong) NSDictionary * likePair;
@end

@interface BTDBCondition : NSObject
@property (nonatomic , strong) BTDBConditionPair * andPairs;
@property (nonatomic , strong) BTDBConditionPair * orPairs;

-(NSString *)conditionStringAddValue:(NSMutableArray *)values;
@end

@interface BTDBSearchCondition : BTDBCondition
@property (nonatomic , strong) NSArray * columnList;
@property (nonatomic , strong) NSArray * groupByList;
@property (nonatomic , strong) NSArray * orderByList;
@property (nonatomic , assign) BOOL ascSort;

@property (nonatomic , assign) NSInteger limit;
@property (nonatomic , assign) NSInteger offset;

-(NSString *)columnSting;

@end