//
//  PKStatisticSource.h
//  PlayerKit
//
//  Created by lucky.li on 15/4/22.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKVideoInfo.h"
#import "PKVideoPlayerCoreBase.h"

#pragma mark -

/// 播放失败类型
typedef NS_ENUM(NSInteger, PKFailType) {
    kFailTypeOpening=0,     // 打开失败
    kFailTypePlaying,       // 播放过程失败
};

#pragma mark -
@interface PKStatisticSource : NSObject

@property (copy, nonatomic) void (^startPlayingStatisticBlock) (void);
@property (copy, nonatomic) void (^playFailedStatisticBlock) (PKFailType type);
@property (copy, nonatomic) void (^seekStatisticBlock) (BOOL isGesture, BOOL isRewind);
@property (copy, nonatomic) void (^videoInfoStatisticBlock) (PKVideoInfo *info);
@property (copy, nonatomic) void (^playTimeStatisticBlock) (NSTimeInterval time);
@property (copy, nonatomic) void (^episodeBtnClickStatisticBlock) (void);
@property (copy, nonatomic) void (^subtitleBtnClickStatisticBlock) (void);
@property (copy, nonatomic) void (^displaymodeChangedStatisticBlock) (PKVideoViewDisplayMode mode);
@property (copy, nonatomic) void (^displayPlayerViewStatisticBlock) (void);
@property (copy, nonatomic) void (^dlnaBtnClickStatisticBlock) (void);
@property (copy, nonatomic) void (^userPauseStatisticBlock) (void);
@property (copy, nonatomic) void (^audioTrackBtnClickStatisticBlock) (void);
@property (copy, nonatomic) void (^audioTrackInfoStatisticBlock) (NSArray *audioTracks);
@property (copy, nonatomic) void (^nextBtnClickStatisticBlock) (void);

@end
