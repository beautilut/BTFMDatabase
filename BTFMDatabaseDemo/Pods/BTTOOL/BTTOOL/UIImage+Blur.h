//
// Created by Beautilut on 2017/6/14.
// Copyright (c) 2017 beautilut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
@interface UIImage (Blur)

+(UIImage *)boxBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;

@end
