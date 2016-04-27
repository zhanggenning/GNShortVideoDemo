//
//  PKPlayerManager.h
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/24.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PKControlBarDefine.h"

@class PKSourceManager;
@class PKVideoInfo;

/// 开始播放通知
extern NSString *const kPKPlayerStartPlayingNotification;

/// 结束播放通知
extern NSString *const kPKPlayerFinishPlayingNotification;

/// （开始／结束）播放通知视频信息数据的key
extern NSString *const kPKPlayerNotificationVideoInfoKey;

@interface PKPlayerManager : NSObject

/// init
+ (instancetype)sharedManager;

/// 清空所有源
- (void)clearSources;

/// 当前源管理器
- (PKSourceManager *)currentSourceManager;

/// 是否正在播放
- (BOOL)isPlaying;

/// 暂停播放
- (void)pause;

/// 恢复播放
- (void)resumePlaying;

/// 关闭
- (void)close;

/// 当前播放视频信息
- (PKVideoInfo *)currentVideoInfo;

/**
 *  根据单个URL播放
 *
 *  @param contentURLString URL
 */
- (void)playWithContentURLString:(NSString *)contentURLString;

/**
 *  根据多个切片信息播放
 *
 *  @param contentStreamSlices 多个切片信息的数组，元素为PKStreamSlice
 */
- (void)playWithContentStreamSlices:(NSArray *)contentStreamSlices;

/**
 *  根据多个本地路径播放
 *
 *  @param localPathsArray 多个本地路径的数组，元素为NSString
 */
- (void)playWithLocalPathsArray:(NSArray *)localPathsArray;

/**
 *  根据单个URL切换视频播放
 *
 *  @param contentURLString URL
 */
- (void)switchWithContentURLString:(NSString *)contentURLString;

/**
 *  根据多个切片信息切换视频播放
 *
 *  @param contentStreamSlices 多个切片信息的数组，元素为PKStreamSlice
 */
- (void)switchWithContentStreamSlices:(NSArray *)contentStreamSlices;

/**
 *  根据多个本地路径切换视频播放
 *
 *  @param localPathsArray 多个本地路径的数组，元素为NSString
 */
- (void)switchWithLocalPathsArray:(NSArray *)localPathsArray;

#pragma mark -- 新接口
//播放完成展现的视图（外部设置）
@property (nonatomic, weak) UIView *externalCompleteView;

//播放出错时展现的视图（外部设置）
@property (nonatomic, weak) UIView *externalErrorView;

//播放器控制栏风格
@property (nonatomic, assign) PKVideoControlBarStyle playerControlStyle;

- (UIViewController *)lightPlayerWithVideoUrl:(NSString *)videoUrl
                                 completeView:(UIView *)completeView
                                    errorView:(UIView *)errorView;

- (void)switchVideoUrl:(NSString *)videoUrl;

- (void)resetLightPlayer;

@end
