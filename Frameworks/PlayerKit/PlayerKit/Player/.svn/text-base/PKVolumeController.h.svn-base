//
//  PKVolumeController.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/15.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PKVolumeController : NSObject

/// 声音大小改变通知
@property (copy, nonatomic) void (^volumeChangedBlock) (CGFloat newVolume);

/// init
+ (instancetype)sharedController;

/// 当前音量，范围[0.0, 1.0]
+ (CGFloat)volume;

/**
 *  设置当前音量
 *
 *  @param volumeInPercent 范围[0.0, 1.0]
 */
+ (void)setVolume:(CGFloat)volumeInPercent;

/**
 *  增加音量
 *
 *  @param incrementInPercent 范围[0.0, 1.0]
 *
 *  @return 增加后的音量，范围[0.0, 1.0]
 */
+ (CGFloat)increaseVolume:(CGFloat)incrementInPercent;

/**
 *  减少音量
 *
 *  @param decrementInPercent 范围[0.0, 1.0]
 *
 *  @return 减少后的音量，范围[0.0, 1.0]
 */
+ (CGFloat)decreaseVolume:(CGFloat)decrementInPercent;

@end
