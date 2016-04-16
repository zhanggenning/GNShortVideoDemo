//
//  PKToolKit.m
//  PlayerKit
//
//  Created by lucky.li on 15/3/12.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKToolKit.h"
#import <APlayerIOS/APlayerIOSMediaInfo.h>

@implementation PKToolKit

+ (NSInteger)videoDurationInMSWithLocalPath:(NSString *)path {
    APlayerIOSMediaInfo *info = [APlayerIOSMediaInfo mediaInfoWithFile:path];
    return (NSInteger)info.getDuration * 1000;
}

@end
