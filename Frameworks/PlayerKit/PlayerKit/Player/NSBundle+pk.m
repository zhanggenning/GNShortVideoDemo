//
//  NSBundle+pk.m
//  TDPlayerKit
//
//  Created by lucky.li on 14/12/30.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "NSBundle+pk.h"

@implementation NSBundle (pk)

+ (NSBundle *)pkBundle {
    return [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PlayerKitResources" withExtension:@"bundle"]];
}

@end
