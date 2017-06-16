//
// Created by Beautilut on 2017/6/9.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface UIView (Frame)

@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat right;

@property (nonatomic) CGFloat top;

@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;

@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;

@property (nonatomic) CGFloat centerY;


//查找相对位置 self相对于relativeView的Rect relativeView 必须是self的父视图
-(CGRect)relativeRectForView:(UIView *)relativeView;

@end
