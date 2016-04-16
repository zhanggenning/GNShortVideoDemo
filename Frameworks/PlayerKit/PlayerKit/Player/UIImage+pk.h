//
//  UIImage+pk.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/22.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (pk)

+ (UIImage *)pk_imageNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle;

+ (UIImage *)imageInPKBundleWithName:(NSString *)name;

@end
