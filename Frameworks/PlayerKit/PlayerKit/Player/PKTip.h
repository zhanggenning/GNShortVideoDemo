//
//  PKTip.h
//  PlayerKit
//
//  Created by lucky.li on 15/5/8.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -

/// 播放器错误提示类型
typedef NS_ENUM(NSInteger, PKPlayerTipType) {
    kPlayerTipTypeNoNetwork=0,          // 没有网络
};

#pragma mark -
@interface PKTip : UIView

/// init: 根据xib初始化
+ (instancetype)nibInstance;

- (BOOL)isShowing;

- (void)showWithType:(PKPlayerTipType)type;

- (void)hideWithType:(PKPlayerTipType)type;

@end
