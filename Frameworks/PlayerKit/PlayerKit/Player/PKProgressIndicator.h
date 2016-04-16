//
//  PKProgressIndicator.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/9.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKProgressIndicator : UIView

@property (assign, nonatomic) BOOL isRewind;
@property (strong, nonatomic) NSString *descriptionString;
@property (assign, nonatomic, readonly) BOOL isShowing;
@property (assign, nonatomic) BOOL enableAutoHide;

/// init: 根据xib初始化
+ (instancetype)nibInstance;

- (void)showWithDescription:(NSString *)descriptionString
                   isRewind:(BOOL)isRewind;

- (void)hide;

@end
