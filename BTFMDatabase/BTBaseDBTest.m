//
//  BTBaseDBTest.m
//  BTFMDatabase
//
//  Created by Beautilut on 2017/6/16.
//  Copyright © 2017年 beautilut. All rights reserved.
//

#import "BTBaseDBTest.h"
#import "BTDBManager.h"

static BTDBManager * shareInstance = nil;
@implementation BTBaseDBTest

+(NSString*)tableName
{
    return @"test_key";
}

+(BTDBManager*)dbManager
{
    return [BTDBManager shareDBManager];
}

@end
