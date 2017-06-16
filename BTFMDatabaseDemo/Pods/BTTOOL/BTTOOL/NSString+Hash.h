//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hash)

@property  (readonly) NSString * MD5Hash;
@property  (readonly) NSString * sha1String;
@property  (readonly) NSString * sha256String;
@property  (readonly) NSString * sha512String;

@end