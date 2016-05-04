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

// 播放失败类型
typedef NS_ENUM(NSInteger, PKFailType) {
    kFailTypeOpening=0,     // 打开失败
    kFailTypePlaying,       // 播放过程失败
};

// 播放结束类型
typedef NS_ENUM(NSInteger, PKEndType) {
    kPlayEndByComplete = 0, //播放完成
    kPlayEndByUser, //用户停止
    kPlayEndByFail  //播放失败
};

#pragma mark -
@interface PKStatisticSource : NSObject

//开始播放统计
@property (copy, nonatomic) void (^startPlayingStatisticBlock) (PKVideoInfo *info);

//结束播放统计
@property (copy, nonatomic) void (^stopPlayingStatisticBlock) (PKEndType endType, NSTimeInterval playTime,
                                                               PKVideoInfo *videoInfo, NSError *error);
//快进/快退统计
@property (copy, nonatomic) void (^seekStatisticBlock) (BOOL isGesture, BOOL isRewind);

//分集按钮点击统计
@property (copy, nonatomic) void (^episodeBtnClickStatisticBlock) (void);

@property (copy, nonatomic) void (^subtitleBtnClickStatisticBlock) (void);

//全屏/非全屏切换统计
@property (copy, nonatomic) void (^displaymodeChangedStatisticBlock) (PKVideoViewDisplayMode mode);

@property (copy, nonatomic) void (^displayPlayerViewStatisticBlock) (void);

//DLNA按钮点击统计
@property (copy, nonatomic) void (^dlnaBtnClickStatisticBlock) (void);

//播放/开始按钮统计
@property (copy, nonatomic) void (^userPauseStatisticBlock) (BOOL isPauseMode);

//音轨按钮统计
@property (copy, nonatomic) void (^audioTrackBtnClickStatisticBlock) (void);

@property (copy, nonatomic) void (^audioTrackInfoStatisticBlock) (NSArray *audioTracks);

//下一集按钮统计
@property (copy, nonatomic) void (^nextBtnClickStatisticBlock) (void);

@end
