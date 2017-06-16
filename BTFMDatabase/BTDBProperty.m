//
// Created by Beautilut on 2017/6/7.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "BTDBProperty.h"

NSString * const DB_Type_Text = @"text";
NSString * const DB_Type_Int = @"integer";
NSString * const DB_Type_Double = @"double";
NSString * const DB_Type_Blob = @"blob";

@implementation BTDBProperty {

}

-(BOOL)propertyCanUpdate {
    if (self.isIgnore || EDBColumnStatusRemove == self.columnStatus) {
        return NO;
    }
    return YES;
}

-(id)initWithProperty:(objc_property_t *)property {

    if(self = [super init]) {
        _isPrimary = NO;
        _isIgnore = NO;
        _columnStatus = EDBColumnStatusNormal;

        const char * propertyName = property_getName(*property);
        _columnName = @(propertyName);

        const char * attrs = property_getAttributes(*property);
        NSString * propertyAttributes = @(attrs);
        NSString * propertyType = nil;

        NSScanner * scanner = [NSScanner scannerWithString:propertyAttributes];
        [scanner scanUpToString:@"T" intoString:nil];
        [scanner scanString:@"T" intoString:nil];

        if ([scanner scanString:@"@\"" intoString:&propertyType]) {
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&propertyType];

            _propertyType = propertyType;

            _columnType = [[NSClassFromString(propertyType) class] isSubclassOfClass:NSClassFromString(@"GWObject")] ?  DB_Type_Blob : DB_Type_Text ;

            while ([scanner scanString:@"<" intoString:NULL]) {

                NSString * protocolName = nil;

                [scanner scanUpToString:@">" intoString:&protocolName];

                if ([protocolName isEqualToString:@"BTDBKeyIgnore"]) {
                    _isIgnore = YES;
                }else if([protocolName isEqualToString:@"BTDBKeyPrimay"]) {
                    _isPrimary = YES;
                }else {
                    if ([protocolName isEqualToString:@"BTDBKeyAddition"]) {
                        _columnStatus = EDBColumnStatusAddition;
                    }else if([protocolName isEqualToString:@"BTDBKeyRemove"]) {
                        _columnStatus = EDBColumnStatusRemove;
                    }else if([protocolName isEqualToString:@"BTDBKeyUnique"]) {
                        _isUnique = YES;
                    }else if([protocolName isEqualToString:@"BTDBKeyNotNull"]) {
                        _isNotNull = YES;
                    }
                }
                [scanner scanString:@">" intoString:NULL];
            }

        } else if ([scanner scanString:@"{" intoString:&propertyType]) {

            [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&propertyType];
            _propertyType = propertyType;
            return nil;

        } else {

            NSDictionary * primitivesNames = @{
                    @"f" : @"float",
                    @"i" : @"int",
                    @"d" : @"double",
                    @"l" : @"long",
                    @"c" : @"BOOL",
                    @"s" : @"short",
                    @"q" : @"long",
                    @"I" : @"NSInteger",
                    @"Q" : @"NSUinteger",
                    @"B" : @"BOOL",
                    @"@?" : @"Block",
            };

            NSDictionary * mapTypes = @{
                    @"float" : DB_Type_Double,
                    @"double" : DB_Type_Double,
                    @"decimal" : DB_Type_Double,
                    @"int" : DB_Type_Int,
                    @"char" : DB_Type_Int,
                    @"short" : DB_Type_Int,
                    @"long" : DB_Type_Int,
                    @"NSInteger" : DB_Type_Int,
                    @"NSUInteger" : DB_Type_Int,
                    @"BOOL" : DB_Type_Int
            };

            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","] intoString:&propertyType];

            _propertyType = primitivesNames[propertyType];
            propertyType = mapTypes[_propertyType];
            _columnType = [propertyType length] ? propertyType : DB_Type_Blob;

            if ([_propertyType isEqualToString:@"Block"]) {
                return nil;
            }
        }

    }
    return self;
}
@end
