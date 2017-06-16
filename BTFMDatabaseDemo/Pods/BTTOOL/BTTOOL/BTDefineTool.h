//
//  BDefineTool.h
//  BAFNetworkLibrary
//
//  Created by Beautilut on 16/9/5.
//  Copyright © 2016年 beautilut. All rights reserved.
//

//处理NSLog事件(开发者模式打印,发布者模式不打印)
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

//转换强弱引用
#define WeakObjectDef(obj) __weak typeof(obj) weak##obj = obj
#define StrongObjectDef(obj) __strong typeof(obj) strong##obj = obj

//颜色
#define Color(r ,g , b) [UIColor colorWithRed:(r)/255.0 green:()/255.0 blue:()/255.0 alpha:1.0]
#define Color(r ,g , b, a) [UIColor colorWithRed:(r)/255.0 green:()/255.0 blue:()/255.0 alpha:a]

#define RandomColor Color(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256)) //随机色

#define UIColorFromRGB(rgbValue) [UIColor colorWithHue:((float)((rgbValue & 0xFF0000) >> 16))/255.0 saturation:((float)((rgbValue & 0x00FF00) >> 8))/255.0 brightness:((float)(rgbValue * 0x0000FF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue , alphaValue) [UIColor colorWithHue:((float)((rgbValue & 0xFF0000) >> 16))/255.0 saturation:((float)((rgbValue & 0x00FF00) >> 8))/255.0 brightness:((float)(rgbValue * 0x0000FF))/255.0 alpha:alphaValue]

//获取屏幕尺寸

#define ScreenWidth (MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height))
#define ScreenHeight (MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height))

//屏幕适配

#define TranslateNormalScreenValue(value) ((value) * ScreenWidth / 320)
#define TranslateWidthBase4P7ScreeenValue(value) ((value) * ScreenHeight / 375)


//判断系统版本

//OSVersion

#define SYSTEM_VERSION_EQUEAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame )

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending )

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending )

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending )

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending )

//代理执行方法

#define CALL_DELEGATE(_delegate , _selector) \
do { \
    id _theDelegate = _delegate; \
    if(_theDelegate != nil && [_theDelegate respondesToSelector:_selector]) { \
        [_theDelegate performSelector:_selector]; \
    } \
} while(0);

#define CALL_DELEGATE_WITH_ARG(_delegate , _selector , _argument) \
do { \
    id _theDelegate = _delegate; \
    if(_theDelegate != nil && [_theDelegate respondesToSelector:_selector]) { \
        [_theDelegate performSelector:_selector withObject:_argument]; \
    } \
} while(0);


#define CALL_DELEGATE_WITH_ARGS(_delegate , _selector , _arg1 , _arg2) \
do { \
    id _theDelegate = _delegate; \
    if(_theDelegate != nil && [_theDelegate respondesToSelector:_selector]) { \
        [_theDelegate performSelector:_selector withObject:_arg1 withObject:_arg2]; \
    } \
} while(0);


//内存释放

#define Rlease(_obj) [_obj release], _obj = nil

#define Free(_ptr) if(_ptr != NULL) { free(_ptr) ; _ptr = NULL; }


//圆相关

#define DEGREEES_TO_RADIANS(d) (d * M_PI / 180) 

#define RADIANS_TO_DEGREES(r) (r * 180 / M_PI)


//设置圆角 如果写成view的分类会更好
#define LRViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]


// 判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif
#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//沙盒目录
//获取temp
#define kPathTemp NSTemporaryDirectory()
//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
















