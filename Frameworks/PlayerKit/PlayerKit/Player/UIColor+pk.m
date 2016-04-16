//
//  UIColor+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/3/25.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "UIColor+pk.h"

@implementation UIColor (pk)

+ (UIColor*)colorWithHexValue:(NSInteger)hexValue
                        alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((CGFloat)((hexValue&0xFF0000)>>16))/255.0
                           green:((CGFloat)((hexValue&0xFF00)>>8))/255.0
                            blue:((CGFloat)(hexValue&0xFF))/255.0
                           alpha:alpha];
}

@end
