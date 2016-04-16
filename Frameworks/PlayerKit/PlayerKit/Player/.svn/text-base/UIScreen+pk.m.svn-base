//
//  UIScreen+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/22.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "UIScreen+pk.h"
#import "UIApplication+pk.h"

@implementation UIScreen (pk)

+ (CGRect)screenBounds {
    CGRect rect = [UIScreen mainScreen].bounds;
    if ([UIApplication isLanscapeOrientation]) {
        CGFloat width = MAX(rect.size.width, rect.size.height);
        CGFloat height = MIN(rect.size.width, rect.size.height);
        rect = CGRectMake(rect.origin.x,
                          rect.origin.y,
                          width,
                          height);
    } else {
        CGFloat width = MIN(rect.size.width, rect.size.height);
        CGFloat height = MAX(rect.size.width, rect.size.height);
        rect = CGRectMake(rect.origin.x,
                          rect.origin.y,
                          width,
                          height);
    }
    return rect;
}

+ (CGRect)landscapeScreenBounds {
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat width = MAX(rect.size.width, rect.size.height);
    CGFloat height = MIN(rect.size.width, rect.size.height);
    rect = CGRectMake(rect.origin.x,
                      rect.origin.y,
                      width,
                      height);
    return rect;
}

+ (CGRect)portraitScreenBounds {
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat width = MIN(rect.size.width, rect.size.height);
    CGFloat height = MAX(rect.size.width, rect.size.height);
    rect = CGRectMake(rect.origin.x,
                      rect.origin.y,
                      width,
                      height);
    return rect;
}

@end
