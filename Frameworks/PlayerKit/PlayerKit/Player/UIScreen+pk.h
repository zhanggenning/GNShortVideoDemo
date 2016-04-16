//
//  UIScreen+pk.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/22.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIScreen (pk)

/// 当前屏幕范围，已判断横竖屏幕
+ (CGRect)screenBounds;

/// 横屏屏幕范围
+ (CGRect)landscapeScreenBounds;

/// 竖屏屏幕范围
+ (CGRect)portraitScreenBounds;

@end
