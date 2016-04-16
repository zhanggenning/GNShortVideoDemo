//
//  UIDevice+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/5.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "UIDevice+pk.h"
#import "UIScreen+pk.h"

@implementation UIDevice (pk)

+ (BOOL)isIPad {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isIphone_480 {
    static BOOL value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double screenWidth = [UIScreen landscapeScreenBounds].size.width;
        value = (fabs(screenWidth-(double)480) < DBL_EPSILON) ? YES : NO;
    });
    return value;
}

+ (BOOL)isIphone_568 {
    static BOOL value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double screenWidth = [UIScreen landscapeScreenBounds].size.width;
        value = (fabs(screenWidth-(double)568) < DBL_EPSILON) ? YES : NO;
    });
    return value;
}

+ (BOOL)isIphone_667 {
    static BOOL value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double screenWidth = [UIScreen landscapeScreenBounds].size.width;
        value = (fabs(screenWidth-(double)667) < DBL_EPSILON) ? YES : NO;
    });
    return value;
}

+ (BOOL)isIphone_736 {
    static BOOL value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double screenWidth = [UIScreen landscapeScreenBounds].size.width;
        value = (fabs(screenWidth-(double)736) < DBL_EPSILON) ? YES : NO;
    });
    return value;
}

+ (CGFloat)iosVersion {
    static CGFloat version = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray* verArray = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
        NSInteger j = 0;
        for (NSInteger i = 0; i < verArray.count; ++i) {
            CGFloat val = [verArray[i] floatValue];
            if (i == 0) {
                version = val;
                continue ;
            }
            j += (val?floorf(log10f(val)):0)+1;
            version += val/powf(10, j);
        }
    });
    return version;
}

@end
