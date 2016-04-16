//
//  PKXMPVideoPlayerCore.h
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/24.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKVideoPlayerCoreBase.h"

@interface PKXMPVideoPlayerCore : PKVideoPlayerCoreBase

@end

/**
 *  问题记录：
 *  1.setVideoViewSize需要在play延迟一小段时间之后才能开始有用，导致init的时候必须要传完全正确的VideoViewSize
 *  （fixed）2.setVideoViewSize界面有红色
 *  （fixed）3.isSeeking未实现
 *  4.切片播放seek目前只能跳到那块切片的开始位置，不能准确seek
 *  （fixed）5.在未open完立即close会在close后继续open，快速open／close多次容易出现问题
 *  （fixed）6.TS切片seek可能会往前很多，不能准确seek
 *  7.open/close/play/pause/seek需要返回YES/NO，表明是否执行了这些操作
 *  8.open完成后获取视频信息：本地／在线，容器、视频、音频、字幕格式
 *  （fixed）9.在已缓冲范围内seek也清除buffer重新缓冲了
 *  （fixed）10.本地播放，快速多次seek，会导致不能再播放
 *  （fixed）11.暂停时seek，缓冲进度一直是0%
 *  12.暂停时seek，视频图片没有更改到seek位置
 *  （fixed）13.缓冲100%之前，buffer位置会飘
 *  （fixed）14.flv缓冲进度一直是0%
 *  （fixed）15.在暂停状态下seek不缓冲，点击播放将不再播放
 *  （fixed）16.播放音频之后，再播放视频，没有画面
 *  （fixed）17.缓冲到底后，在已缓冲范围内seek会直接结束
 */