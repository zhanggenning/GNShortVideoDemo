//
//  PKLoading.h
//  PlayerKit
//
//  Created by lucky.li on 15/5/8.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKLoading : UIView

/// init: 根据xib初始化
+ (instancetype)nibInstance;

- (BOOL)isShowing;

- (void)showWithDescription:(NSString *)descriptionString;

- (void)hide;

@end
