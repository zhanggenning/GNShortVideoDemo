//
//  PKControlBarProtocol.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/19.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKControlBarDefine.h"

/**
 *  控制界面参数设置协议（传值方向：vc -> view）
 */
@protocol PKControlBarProtocol <NSObject>

+ (id<PKControlBarProtocol>)nibInstance;

@optional

- (void)setControlBarDelegate: (id)vc;

- (void)setControlBarHidden:(BOOL)isHidden;

- (void)setControlBarPlayState:(PKVideoControlBarPlayState)state;

- (void)setControlBarPlayProcess:(CGFloat)process;

- (void)setControlBarBufferProcess:(CGFloat)bufferProcess;

- (void)setControlBarPlayTime:(NSInteger)time;

- (void)setControlBarDurationTime:(NSInteger)time;

- (void)setControlBarMainTitle:(NSString *)title;

- (void)setControlBarVolumeProcess:(CGFloat)process;

- (void)setControlBarBrightnessProcess:(CGFloat)process;

@end


/**
 *  控制界面的事件协议（传值方向：view -> vc）
 */
@protocol PKControlBarEventProtocol <NSObject>

@optional

//播放按键点击事件
- (void)videoControlBarPlayBtnClicked:(id<PKControlBarProtocol>) controlBar;

//全屏按键点击事件
- (void)videoControlBarFullScreenBtnClicked:(id<PKControlBarProtocol>)controlBar;

//进度值开始改变
- (void)videoControlBarProcessWillChange:(id<PKControlBarProtocol>)controlBar;

//进度值改变完成
- (void)videoControlBar:(id<PKControlBarProtocol>)controlBar processValueDidChange:(CGFloat)process;

//控制栏点击事件
- (void)videoControlBarTapClicked:(id<PKControlBarProtocol>)controlBar;

//音量改变事件
- (void)videoControlBarVolumeChange:(BOOL)isIncrease percent:(CGFloat)percent;

//亮度改变事件
- (void)videoControlBarBrightnessChange:(BOOL)isIncrease percent:(CGFloat)percent;

@end