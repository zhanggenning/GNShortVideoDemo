//
//  UIDevice+pk.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/5.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIDevice (pk)

+ (BOOL)isIPad;

+ (BOOL)isIphone_480;

+ (BOOL)isIphone_568;

+ (BOOL)isIphone_667;

+ (BOOL)isIphone_736;

+ (CGFloat)iosVersion;

@end
