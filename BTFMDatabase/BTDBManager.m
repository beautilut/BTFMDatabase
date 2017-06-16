//
// Created by Beautilut on 2017/6/7.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "BTDBManager.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseQueue.h>
#import "BTDBProperty.h"
#import "BTBaseDB.h"
#import <sqlite3.h>

NSString * const KDBManagerOpenedNotification = @"DB_MANAGER_OPENED";
NSString * const KDBManagerClosedNotification = @"DB_MANAGER_CLOSED";

static NSString * const BTSQL_Attribute_NotNull = @"NOT NULL";
static NSString * const BTSQL_Attribute_PrimaryKey = @"PRIMARY KEY";
static NSString * const BTSQL_Attribute_Default = @"DEFAULT";
static NSString * const BTSQL_Attribute_Unique = @"UNIQUE";
static NSString * const BTSQL_Attribute_Check = @"CHECK";

@interface BTDBManager()

@property (nonatomic , strong) FMDatabaseQueue * dbQueue;

@end

@implementation BTDBManager {

}


+(id)shareDBManager {
    static dispatch_once_t onceToken;
    static BTDBManager * shareInstance;
    dispatch_once(&onceToken, ^{
        if (!shareInstance) {
            shareInstance = [[BTDBManager alloc] init];
        }
    });
    return shareInstance;
}

-(void)dealloc
{
    [self closeDB];
}

-(BOOL)openDBWithName:(NSString *)dbName {

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [NSString stringWithFormat:@"%@/%@.db" , [paths firstObject] , dbName];

    if ([_dbQueue openFlags] && [_dbQueue.path isEqualToString:path]) {
        return NO;
    }

    [self closeDB];

    self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];

    [[NSNotificationCenter defaultCenter] postNotificationName:KDBManagerOpenedNotification object:nil];

    return YES;
}

-(BOOL)dbIsOpen {
    return [_dbQueue openFlags];
}

-(void)closeDB {
    if ([_dbQueue openFlags]) {
        [_dbQueue close];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KDBManagerClosedNotification object:nil];
}

-(void)executeDB:(void(^)(FMDatabase * db))block
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = YES;
        block(db);
    }];
}

-(BOOL)executeSQL:(NSString *)sql withArgumentsInArray:(NSArray *)arguments
{
    __block BOOL execute = NO;
    [self executeDB:^(FMDatabase *db) {
        if ([arguments count]) {
            execute = [db executeUpdate:sql withArgumentsInArray:arguments];
        }else{
            execute = [db executeUpdate:sql];
        }
    }];
    return execute;
}

#pragma mark  -- create Table --
-(BOOL)createTableWithClass:(Class)dbClass {

    if (![dbClass isSubclassOfClass:[BTBaseDB class]]){
        return NO;
    }

    NSArray * propertyList = [dbClass propertyListFromObject];
    NSMutableArray * columns = [NSMutableArray array];
    NSMutableArray * primaryKeys = [NSMutableArray array];
    NSMutableArray * alertColumns = [NSMutableArray array];

    NSString * sqlToAlertTable;
    for (BTDBProperty * bProperty in propertyList) {

        if (![bProperty propertyCanUpdate]) {
            continue;
        }

        NSMutableString * tmpColumns = [NSMutableString string];
        [tmpColumns appendFormat:@"%@ %@" , bProperty.columnName , bProperty.columnType];

        if (bProperty.isNotNull) {
            [tmpColumns appendFormat:@" %@" , BTSQL_Attribute_NotNull];
        }
        if (bProperty.isUnique) {
            [tmpColumns appendFormat:@" %@" , BTSQL_Attribute_Unique];
        }
        if (bProperty.checkValue) {
            [tmpColumns appendFormat:@" %@(%@)" , BTSQL_Attribute_Check , bProperty.checkValue];
        }
        if (bProperty.defaultValue) {
            [tmpColumns appendFormat:@" %@ %@" , BTSQL_Attribute_Default , bProperty.defaultValue];
        }
        if (EDBColumnStatusAddition == bProperty.columnStatus) {
            sqlToAlertTable = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@" , [dbClass tableName] , tmpColumns];
            [alertColumns addObject:sqlToAlertTable];
            continue;
        }else if (EDBColumnStatusRemove == bProperty.columnStatus) {
            sqlToAlertTable = [NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@ " , [dbClass tableName] , bProperty.columnName];
            [alertColumns addObject:sqlToAlertTable];
            continue;
        }

        [columns addObject:tmpColumns];

        if (bProperty.isPrimary){
            [primaryKeys addObject:bProperty.columnName];
        }

    }

    NSMutableString * columnStr = [[NSMutableString alloc] initWithString:[columns componentsJoinedByString:@", "]];
    NSMutableString * primaryKeyStr = [[NSMutableString alloc] initWithString:[primaryKeys componentsJoinedByString:@", "]];
    if ([primaryKeyStr length]) {
        [primaryKeyStr insertString:@", primary key(" atIndex:0];
        [primaryKeyStr appendString:@")"];
    }

    NSString * createSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@%@)" , [dbClass tableName] , columnStr , primaryKeyStr];

    BOOL success = [self executeSQL:createSql withArgumentsInArray:nil];
    if (!success) {
        return NO;
    }

    for(NSString * alertSql in alertColumns) {
        success = [self executeSQL:alertSql withArgumentsInArray:nil];

        if (!success) {

        }

    };

    return YES;
}

-(NSMutableArray *)explainSet:(FMResultSet *)set withClass:(Class)dbClass;
{
    if (![dbClass isSubclassOfClass:[BTBaseDB class]]) {
        return nil;
    }

    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSDictionary * propertyDictionary = [[dbClass class] propertyDictionaryFromObject];
    NSInteger columnCount = [set columnCount];
    while ([set next]) {
        BTBaseDB * db = [[dbClass alloc] init];

        for (int i = 0 ; i < columnCount ; i ++) {

            NSString * columnName = [set columnNameForIndex:i];
            BTDBProperty * property = [propertyDictionary objectForKey:columnName];

            if (!property) {
                if ([[columnName lowercaseString] isEqualToString:@"rowid"]) {
                    db.rowid = [set longForColumnIndex:i];
                }
                continue;
            }

            if ([property.columnType isEqualToString:DB_Type_Blob]) {
                [db modelWithProperty:property value:[set dataForColumnIndex:i]];
            }else {
                [db modelWithProperty:property value:[set stringForColumnIndex:i]];
            }
        }
        [results addObject:db];
    }

    return results;
}

-(void)asyncTask:(void(^)(BTDBManager *))task
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            task(strongSelf);
        }
    });
}

#pragma mark  search

-(void)searchWithClass:(Class)dbClass condition:(BTDBSearchCondition *)condition completion:(void (^)(NSArray *))completion {
    [self asyncTask:^(BTDBManager *manager) {
        NSArray * results = [manager searchWithClass:dbClass condition:condition];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(results);
        });
    }];
}

-(NSArray *)searchWithClass:(Class)dbClass condition:(BTDBSearchCondition *)condition {

    if (![dbClass isSubclassOfClass:[BTBaseDB class]]) {
        return nil;
    }

    NSMutableArray * arguments = [[NSMutableArray alloc] init];

    NSString * columnString = [condition columnSting];
    NSString * conditionString = [condition conditionStringAddValue:arguments];
    columnString = [columnString length] ? columnString : @"*";
    conditionString = [conditionString length] ? conditionString : @"";
    NSMutableString * searchSql = [NSMutableString stringWithFormat:@"select %@,rowid from %@ %@" , columnString , [dbClass tableName] , conditionString];
    __block NSMutableArray * results = nil;
    [self executeDB:^(FMDatabase *db) {
        FMResultSet * set = nil;
        if (![arguments count]) {
            set = [db executeQuery:searchSql];
        }else {
            set = [db executeQuery:searchSql withArgumentsInArray:arguments];
        }
        results = [self explainSet:set withClass:dbClass];

        [set close];
    }];

    return results;
}

#pragma mark  - insert -

-(void)insertWithDB:(BTBaseDB *)db completion:(void (^)(BOOL))completion {
    [self asyncTask:^(BTDBManager *manager) {
        BOOL success = [manager insertWithDB:db];
        dispatch_async(dispatch_get_main_queue(), ^{
           completion(success);
        });
    }];
}

-(BOOL)insertWithDB:(BTBaseDB *)db {

    if(![db isKindOfClass:[BTBaseDB class]]) {
        return NO;
    }

    NSArray * propertyList = [[db class] propertyListFromObject];
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    NSMutableArray * values = [[NSMutableArray alloc] init];
    NSMutableArray * arguments = [[NSMutableArray alloc] init];
    id value = nil;
    for (BTDBProperty * bProperty in propertyList) {
        if (![bProperty propertyCanUpdate]) {
            continue;
        }
        value = [db valueForProperty:bProperty];
        if (value) {
            [columns addObject:bProperty.columnName];
            [values addObject:@"?"];
            [arguments addObject:value];
        }
    }

    NSMutableString * columnStr = [[NSMutableString alloc] initWithString:[columns componentsJoinedByString:@","]];
    NSMutableString * valueStr = [[NSMutableString alloc] initWithString:[values componentsJoinedByString:@","]];
    NSString * insertSql = [NSString stringWithFormat:@"replace into %@(%@) values(%@)" , [[db class] tableName] , columnStr , valueStr];

    __block BOOL success = NO;
    __block sqlite_int64 lastInsertRowId = 0;

    [self executeDB:^(FMDatabase *db) {
        success = [db executeUpdate:insertSql withArgumentsInArray:arguments];
        lastInsertRowId = db.lastInsertRowId;
    }];
    db.rowid = (NSInteger)lastInsertRowId;

    if (!success) {

    }
    return success;
}

#pragma mark  -- update --
-(void)updateWithDB:(BTBaseDB *)db withCondition:(BTDBCondition *)condition completion:(void (^)(BOOL))completion {

    [self asyncTask:^(BTDBManager *manager) {
        BOOL success = [manager updateWithDB:db withCondition:condition];
        dispatch_async(dispatch_get_main_queue(), ^{
           completion(success);
        });
    }];
}

-(BOOL)updateWithDB:(BTBaseDB *)db withCondition:(BTDBCondition *)condition {

    if (![[db class] isSubclassOfClass:[BTBaseDB class]]) {
        return NO;
    }

    NSMutableString * updateSql = [NSMutableString stringWithFormat:@"update %@ set " , [[db class] tableName]];

    NSArray * propertyList = [[db class] propertyListFromObject];
    id value = nil;
    NSMutableArray * values = [[NSMutableArray alloc] init];
    NSMutableArray * arguments = [[NSMutableArray alloc] init];
    for (BTDBProperty * aProperty in propertyList) {
        if (![aProperty propertyCanUpdate]) {
            continue;
        }
        value = [db valueForProperty:aProperty];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@=?" , aProperty.columnName]];
            [arguments addObject:value];
        }
    }

    NSString * valueString = [values componentsJoinedByString:@","];
    [updateSql appendString:valueString];

    NSString * conditionStr = [condition conditionStringAddValue:arguments];
    //有优先条件
    if ([conditionStr length]) {

    }

    //无优先条件
    else if (db.rowid > 0) {
        conditionStr = [NSString stringWithFormat:@" where rowid=%ld",(long)db.rowid];
    }

    //都没有
    else {
        return NO;
    }

    [updateSql appendString:conditionStr];

    BOOL success = [self executeSQL:updateSql withArgumentsInArray:arguments];

    if (!success) {

    }
    return success;
}

#pragma mark  -- delete --
-(void)deleteWithDB:(BTBaseDB *)db completion:(void (^)(BOOL))completion {
    [self asyncTask:^(BTDBManager *manager) {
        BOOL success = [manager deleteWithDB:db];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success);
        });
    }];
}

-(BOOL)deleteWithDB:(BTBaseDB *)db {
    if(![[db class] isSubclassOfClass:[db class]]) {
        return NO;
    }

    NSMutableString * deleteSql = [NSMutableString stringWithFormat:@"DELETE FROM %@" , [[db class] tableName]];
    NSMutableArray * arguments = [NSMutableArray array];
    NSMutableString * conditionStr = [[NSMutableString alloc] init];

    if (db.rowid > 0) {
        [conditionStr appendFormat:@"rowid=%ld" , (long)db.rowid];
    }else {
        NSArray * propertyList = [[db class] propertyListFromObject];
        id value = nil;
        NSString * joinedStr = nil;

        NSMutableArray * conditions = [[NSMutableArray alloc] init];
        for (BTDBProperty * bProperty in propertyList) {
            if (![bProperty propertyCanUpdate]) {
                continue;
            }
            value = [db valueForProperty:bProperty];
            if(value) {
                joinedStr = [db joinedDeleteConditionColume:bProperty.columnName];
                if ([joinedStr length]) {
                    [arguments addObject:value];
                    [conditions addObject:joinedStr];
                }
            }
        }
        [conditionStr appendString:[conditions componentsJoinedByString:@" and "]];
    }

    if ([conditionStr length]) {
        [conditionStr insertString:@" where " atIndex:0];
    }else{

    }

    [deleteSql appendString:conditionStr];

    BOOL success = [self executeSQL:deleteSql withArgumentsInArray:arguments];
    if (!success) {

    }else {
        db.rowid = 0;
    }
    return success;
}

-(BOOL)deleteAllWithClass:(Class)dbClass {
    if (! [dbClass isSubclassOfClass:[dbClass class]]) {
        return NO;
    }
    NSMutableString * deleteSql = [NSMutableString stringWithFormat:@"delete from %@" , [dbClass tableName]];
    BOOL success = [self executeSQL:deleteSql withArgumentsInArray:nil];
    if (!success) {

    }
    return success;
}
@end
