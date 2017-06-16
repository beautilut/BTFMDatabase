//
//  BTBaseDBTest.h
//  BTFMDatabase
//
//  Created by Beautilut on 2017/6/16.
//  Copyright © 2017年 beautilut. All rights reserved.
//

#import "BTBaseDB.h"

@interface BTBaseDBTest : BTBaseDB

@property (nonatomic , copy) NSString < BTDBKeyPrimay , BTDBKeyNotNull> * key;
@property (nonatomic , strong) NSString * value;


@end
