//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import "NSString+Hash.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Hash)

-(NSString *)MD5Hash {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG) strlen(cStr), digest);

    NSMutableString * output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [output appendFormat:@"%02X" , digest[i]];
    }
    return output;
}

-(NSString *)sha1String {
    const char *string = self.UTF8String;
    int length = (int) strlen(string);
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}

-(NSString *)sha256String {
    const char *string = self.UTF8String;
    int length = (int) strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

-(NSString *)sha512String {
    const char *string = self.UTF8String;
    int length = (int) strlen(string);
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
}

#pragma mark  - Helpers
-(NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length
{
    NSMutableString * mutableString = @"".mutableCopy;
    for (int i = 0; i < length; ++i) {
        [mutableString appendFormat:@"%02x" , bytes[i]];
    }
    return [NSString stringWithString:mutableString];
}

@end