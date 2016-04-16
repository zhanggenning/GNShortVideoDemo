//
//  UIImage+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/22.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "UIImage+pk.h"
#import "NSBundle+pk.h"
#import "UIDevice+pk.h"

@implementation UIImage (pk)

+ (UIImage *)pk_imageNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle {
    if (name.length == 0) {
        return nil;
    }
    
    if (!bundle) {
        return [self.class imageNamed:name];
    }
    
    if ([UIDevice iosVersion] >= 8.0) {
        return [self.class imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    }
    
    NSString *filePath = nil;
    
    NSRange range = [name rangeOfString:@"@"];
    if (range.location != NSNotFound) {
        filePath = [bundle pathForResource:name ofType:nil];
    }
    
    if (filePath.length == 0) {
        NSString *fileName = [name stringByDeletingPathExtension];
        NSString *fileExtension = [name pathExtension];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        if (scale < 1.5) {/// 1倍屏幕
            filePath = [bundle pathForResource:name ofType:nil];
            
            if (filePath.length == 0) {/// 1倍屏幕没有就找@2x
                fileName = [fileName stringByAppendingString:@"@2x"];
                filePath = [bundle pathForResource:fileName ofType:fileExtension];
                if (filePath.length == 0) {
                    filePath = [bundle pathForResource:name ofType:nil];
                }
            }
        } else if (scale < 2.5) {/// 2倍屏幕
            fileName = [fileName stringByAppendingString:@"@2x"];
            filePath = [bundle pathForResource:fileName ofType:fileExtension];
            
            if (filePath.length == 0) {/// @2x没有就找1倍屏幕
                filePath = [bundle pathForResource:name ofType:nil];
            }
        } else if (scale < 3.5) {/// 3倍屏幕
            fileName = [fileName stringByAppendingString:@"@3x"];
            filePath = [bundle pathForResource:fileName ofType:fileExtension];
            
            if (filePath.length == 0) {/// @3x没有就找1倍屏幕
                filePath = [bundle pathForResource:name ofType:nil];
            }
        }
    }
    
    return [UIImage imageWithContentsOfFile:filePath];
}

+ (UIImage *)imageInPKBundleWithName:(NSString *)name {
    NSBundle *pkBundle = [NSBundle pkBundle];
    if ([UIDevice iosVersion] < 8.0) {
        return [self.class pk_imageNamed:name inBundle:pkBundle];
    } else {
        return [self.class imageNamed:name inBundle:pkBundle compatibleWithTraitCollection:nil];
    }
}

@end
