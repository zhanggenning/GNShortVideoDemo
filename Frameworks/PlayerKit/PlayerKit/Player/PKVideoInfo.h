//
//  PKVideoInfo.h
//  TDPlayerKit
//
//  Created by lucky.li on 14/12/26.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

/// 视频播放地址类型
typedef NS_ENUM(NSInteger, PKVideoContentType) {
    kVideoContentTypeUnknown=0,             // unknown
    kVideoContentTypeLocalURLString,        // 本地URL
    kVideoContentTypeOnlineURLString,       // 在线URL
    kVideoContentTypeLocalStreamSlices,     // 本地切片
    kVideoContentTypeOnlineStreamSlices,    // 在线切片
};

#pragma mark -
@interface PKVideoInfo : NSObject

/// 视频播放地址类型
@property (assign, nonatomic, readonly) PKVideoContentType contentType;

/// 视频播放地址URL
@property (copy, nonatomic) NSString *contentURLString;

/// 视频播放地址切片
@property (copy, nonatomic) NSArray *contentStreamSlices;

/// 视频时长，单位毫秒
@property (assign, nonatomic) NSInteger videoDurationInMS;

/// 视频原宽
@property (assign, nonatomic) NSInteger videoWidth;

/// 视频原高
@property (assign, nonatomic) NSInteger videoHeight;

/// 容器格式
@property (copy, nonatomic) NSString *containerFormat;

/// 视频文件大小，单位Byte
@property (assign, nonatomic) long long filesize;

/// 视频码率，单位bps
@property (assign, nonatomic) NSInteger bitrate;

/// 视频编码信息
@property (copy, nonatomic) NSArray *videoFormatInfoArray;

/// 音频编码信息
@property (copy, nonatomic) NSArray *audioFormatInfoArray;

/// 是否是音乐
@property (assign, nonatomic) BOOL isAudio;

+ (NSString *)m3u8StringForStreamSlices:(NSArray *)streamSlices;

/// 播放地址
- (NSString *)playContentURLString;

/// 是否是在线视频
- (BOOL)isOnlineVideo;

/// 是否有视频或图片
- (BOOL)hasVideo;

/// 是否相同播放地址
- (BOOL)isSameWithVideoInfo:(PKVideoInfo *)videoInfo;

@end
