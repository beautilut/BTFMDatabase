//
// Created by Beautilut on 2017/6/8.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "BTDBCondition.h"
@implementation BTDBConditionPair
@end

@implementation BTDBCondition {

}

-(NSString *)trimString:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)conditionWithPair:(BTDBConditionPair *)pair
          conditionArray:(NSMutableArray *)array
               addValues:(NSMutableArray *)values
{
    if (pair) {
        for (NSString * key in [pair.equlPair allKeys]) {
            NSString * value = [pair.equlPair objectForKey:key];
            if (value) {
                [array addObject:[NSString stringWithFormat:@"%@=?" , key]];
                [values addObject:value];
            }
        }
        for (NSString * key in [_andPairs.likePair allKeys]) {
            NSString * value = [_andPairs.likePair objectForKey:key];
            if (value) {
                [array addObject:[NSString stringWithFormat:@"%@ LIKE ?" , key]];
                [values addObject:value];
            }
        }
    }
}

-(NSString *)conditionStringAddValue:(NSMutableArray *)values {
    NSMutableArray * andArray = [[NSMutableArray alloc] init];
    [andArray addObjectsFromArray:_andPairs.conditionArray];
    [self conditionWithPair:_andPairs conditionArray:andArray addValues:values];
    NSString * conditionAndString = [andArray componentsJoinedByString:@" and "];

    NSMutableArray * orArray = [[NSMutableArray alloc] init];
    [orArray addObjectsFromArray:_orPairs.conditionArray];
    [self conditionWithPair:_orPairs conditionArray:orArray addValues:values];

    NSString * conditionOrString = [orArray componentsJoinedByString:@" or "];

    NSMutableString * conditionString = [[NSMutableString alloc] init];
    if ([conditionAndString length]) {
        [conditionString appendString:conditionAndString];
    }
    if ([conditionOrString length]) {
        if ([conditionString length]) {
            [conditionString appendFormat:@" and (%@)" , conditionOrString];
        }else {
            [conditionString appendString:conditionOrString];
        }
    }

    if ([conditionString length]) {
        [conditionString insertString:@" WHERE " atIndex:0];
    }else{
        [conditionString setString:@""];
    }
    return conditionString;
}

@end

@implementation BTDBSearchCondition

-(NSString *)columnSting {
    return [_columnList componentsJoinedByString:@","];
}

-(NSString *)conditionStringAddValue:(NSMutableArray *)values {
    NSMutableString * conditionString = [NSMutableString stringWithString:[super conditionStringAddValue:values]];

    NSString * groupByString = [_groupByList componentsJoinedByString:@","];
    if([groupByString length]) {
        [conditionString appendFormat:@" GROUP BY %@" , groupByString];
    }

    NSString * sortString = [_orderByList componentsJoinedByString:@","];
    if ([sortString length]) {
        [conditionString appendFormat:@" ORDER BY %@ %@" , sortString , _ascSort ? @"ASC" : @"DESC"];
    }
    if (_limit > 0) {
        [conditionString appendFormat:@" limit %ld offset %ld", (long) _limit, (
                long) _offset];
    } else if (_offset > 0) {
        [conditionString appendFormat:@" offset %ld" , (long)_offset];
    }
    return conditionString;
}

@end
