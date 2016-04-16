//
//  PKVideoPlayerCoreBase.h
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/24.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PKVideoInfo;
@class PKSubtitleInfo;

#pragma mark -

/// 视频播放核类型
typedef NS_ENUM(NSInteger, PKVideoPlayerCoreType) {
    kVideoPlayerCoreTypeUnknown=0,              // unknown
    kVideoPlayerCoreTypeXMP,                    // XMP
    kVideoPlayerCoreTypeSystem,                 // System
};

/// 视频播放核状态
typedef NS_ENUM(NSInteger, PKVideoPlayerCoreState) {
    kVideoPlayerCoreStateReady=0,               // 准备就绪
    kVideoPlayerCoreStateOpening,               // 视频源加载中
    kVideoPlayerCoreStatePausing,               // 暂停中
    kVideoPlayerCoreStatePaused,                // 暂停
    kVideoPlayerCoreStatePlaying,               // 播放中
    kVideoPlayerCoreStatePlay=5,                // 播放
    kVideoPlayerCoreStateClosing,               // 视频关闭中
};

/// 视频显示模式
typedef NS_ENUM(NSInteger, PKVideoViewDisplayMode) {
    kVideoViewDisplayModeScaleAspectFit=0,      // 适合屏幕
    kVideoViewDisplayModeScaleAspectFill,       // 充满屏幕
};

/// 视频播放完成类型
typedef NS_ENUM(NSInteger, PKVideoPlayCompletionType) {
    kVideoPlayCompletionTypeEOF=0,              // 播放到文件末尾
    kVideoPlayCompletionTypeClosed,             // 手动关闭
    kVideoPlayCompletionTypeError,              // 播放出错
};

/// 默认完成回调
typedef void (^completionBlock) ();

/// 执行回调
typedef void (^executionBlock) (BOOL executed);

/// 获取播放库信息回调
typedef void (^loadVideoPlayerInfoCompletionBlock) (NSInteger playPositionInMS,
                                                    NSInteger bufferPositionInMS,
                                                    CGFloat bufferProgressInPercent,
                                                    long long downloadSpeedInBytes);

#pragma mark -

@class PKVideoPlayerCoreBase;

@protocol PKVideoPlayerCoreDelegate <NSObject>

@optional

/**
 *  加载完成回调，设置视频播放地址后，加载完成时调用
 *
 *  @param videoPlayerCore   播放核
 *  @param isReadyForPlaying 是否可以播放
 *  @param videoInfo         视频相关信息
 *  @param error             错误类型
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
openCompletedWithResult:(BOOL)isReadyForPlaying
              videoInfo:(PKVideoInfo *)videoInfo
                  error:(NSError *)error;

/**
 *  调整进度完成回调
 *
 *  @param videoPlayerCore 播放核
 *  @param error           error=nil表示调整进度成功，否则表示失败
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
 seekCompletedWithError:(NSError *)error;

/**
 *  视频播放完成回调
 *
 *  @param videoPlayerCore 播放核
 *  @param type            视频播放完成类型
 *  @param error           错误类型
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
  playCompletedWithType:(PKVideoPlayCompletionType)type
                  error:(NSError *)error;

/**
 *  播放进度更新
 *
 *  @param videoPlayerCore 播放核
 *  @param timeInMS        播放进度，单位毫秒
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
     playPositionUpdate:(NSInteger)timeInMS;

/**
 *  缓冲进度更新
 *
 *  @param videoPlayerCore 播放核
 *  @param timeInMS        缓冲进度，单位毫秒
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferPositionUpdate:(NSInteger)timeInMS;

/**
 *  缓冲百分比更新
 *
 *  @param videoPlayerCore   播放核
 *  @param progressInPercent 缓冲百分比
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferProgressUpdate:(CGFloat)progressInPercent;

/**
 *  下载速度更新
 *
 *  @param videoPlayerCore      播放核
 *  @param downloadSpeedInBytes 下载速度，单位Bytes/s
 */
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
    downloadSpeedUpdate:(long long)downloadSpeedInBytes;

@end

#pragma mark -
@interface PKVideoPlayerCoreBase : NSObject

#pragma mark - Public

@property (weak, nonatomic) id<PKVideoPlayerCoreDelegate> delegate;
@property (strong, nonatomic, readonly) PKVideoInfo *videoInfo;
@property (strong, nonatomic, readonly) UIView *videoView;
@property (assign, nonatomic) PKVideoViewDisplayMode videoViewDisplayMode;
@property (assign, nonatomic, readonly) BOOL isSwitching;

/// 是否允许硬解，需要在每次open都设置
@property (assign, nonatomic) BOOL hardwareSpeedupEnable;

/**
 *  打开单个播放地址
 *
 *  @param contentURLString 单个播放地址，本地或网络地址
 *
 *  @return PKVideoPlayerCoreBase或其子类
 */
- (void)openWithContentURLString:(NSString *)contentURLString;

/**
 *  打开切片播放地址
 *
 *  @param contentStreamSlices 切片播放地址，元素为PKStreamSlice
 *
 *  @return PKVideoPlayerCoreBase或其子类
 */
- (void)openWithContentStreamSlices:(NSArray *)contentStreamSlices;

/**
 *  打开视频
 *
 *  @param videoInfo 视频信息
 */
- (void)openWithVideoInfo:(PKVideoInfo *)videoInfo;

/**
 *  根据单个播放地址切换视频
 *
 *  @param contentURLString 单个播放地址，本地或网络地址
 */
- (void)switchVideoWithContentURLString:(NSString *)contentURLString;

/**
 *  根据切片播放地址切换视频
 *
 *  @param contentStreamSlices 切片播放地址，元素为PKStreamSlice
 */
- (void)switchVideoWithContentStreamSlices:(NSArray *)contentStreamSlices;

/**
 *  切换视频
 *
 *  @param videoInfo 视频信息
 */
- (void)switchVideoWithVideoInfo:(PKVideoInfo *)videoInfo;

/**
 *  设置视频显示区域大小
 *
 *  @param size 视频显示区域大小
 */
- (void)setVideoViewSize:(CGSize)size;

/// 是否准备就绪可以播放
- (BOOL)isReadyForPlaying;

/// 是否准备就绪且缓冲完成可以播放
- (BOOL)isBufferReadyForPlaying;

/// 是否已暂停
- (BOOL)isPaused;

/// 是否可以关闭
- (BOOL)canClose;

/**
 *  获取播放库信息
 *
 *  @param playPositionInMS    视频播放进度位置，单位毫秒
 *  @param bufferPositionInMS  视频缓冲buff进度位置，单位毫秒
 *  @param downloadSpeedInBytes 在线视频下载速度，单位Bytes/s
 */
- (void)loadVideoPlayerInfoWithCompletionHandler:(loadVideoPlayerInfoCompletionBlock)completionHandler;

/// 视频播放进度位置，单位毫秒
- (NSInteger)playPositionInMS;

/// 视频缓冲buff进度位置，单位毫秒
- (NSInteger)bufferPositionInMS;

/// 视频缓冲buff百分比，范围[0.0, 1.0]
- (CGFloat)bufferProgressInPercent;

/// 在线视频下载速度，单位Bytes/s
- (long long)downloadSpeedInBytes;

/// 播放
- (void)play;

/**
 *  播放
 *
 *  @param executionHandler 是否执行回调
 */
- (void)playWithExecutionHandler:(executionBlock)executionHandler;

/// 暂停
- (void)pause;

/**
 *  暂停
 *
 *  @param executionHandler 是否执行回调
 */
- (void)pauseWithExecutionHandler:(executionBlock)executionHandler;

/**
 *  根据百分比seek（调整播放进度）
 *
 *  @param progress 播放进度百分比，范围：[0.0, 1.0]
 */
- (void)seekWithProgress:(CGFloat)progressInPercent;

/**
 *  根据时间seek（调整播放进度）
 *
 *  @param timeInMS 播放进度时间，单位毫秒
 */
- (void)seekWithTimeInMS:(NSInteger)timeInMS;

/// 快进
- (NSInteger)fastForward;

/// 回退
- (NSInteger)rewind;

/// 关闭
- (void)close;

/// 当前音量，范围[0.0, 1.0]
- (CGFloat)volume;

/**
 *  设置当前音量
 *
 *  @param volumeInPercent 范围[0.0, 1.0]
 */
- (void)setVolume:(CGFloat)volumeInPercent;

/**
 *  增加音量
 *
 *  @param incrementInPercent 范围[0.0, 1.0]
 *
 *  @return 增加后的音量，范围[0.0, 1.0]
 */
- (CGFloat)increaseVolume:(CGFloat)incrementInPercent;

/**
 *  减少音量
 *
 *  @param decrementInPercent 范围[0.0, 1.0]
 *
 *  @return 减少后的音量，范围[0.0, 1.0]
 */
- (CGFloat)decreaseVolume:(CGFloat)decrementInPercent;

/**
 *  音量改变通知
 *  （block内必须使用weakSelf以防止retain circle；在dealloc时记得设置block为NULL以释放block）
 *
 *  @param newVolume 范围[0.0, 1.0]
 */
- (void)setVolumeChangedBlock:(void (^) (CGFloat newVolume))block;

/// 当前音轨
- (NSInteger)currentAudioTrackIndex;

/// 设置音轨
- (void)setCurrentAudioTrackIndex:(NSInteger)index;

/// 音轨列表
- (NSArray *)audioTracks;

/// 当前字幕
- (PKSubtitleInfo *)currentSubtitleInfo;

/// 设置字幕
- (void)setSubtitleWithInfo:(PKSubtitleInfo *)subtitleInfo;

/// 内嵌字幕数据
- (NSArray *)embeddedSubtitles;

/// 已播放时间
- (NSTimeInterval)timeIntervalSinceStartPlaying;

// Todo: Airplay

// Todo: DLNA（VC处理）

#pragma mark - Protected (for subclass)

@property (assign, atomic) PKVideoPlayerCoreState videoPlayerCoreState;
@property (strong, atomic) NSError *error;
@property (assign, atomic) long long latestDownloadSpeedInBytes;
@property (assign, atomic) BOOL isUsingHardwareSpeedup;

/// errorCode对应的NSError
+ (NSError *)errorWithCode:(NSInteger)errorCode;

/// 视频播放核类型
- (PKVideoPlayerCoreType)videoPlayerCoreType;

- (BOOL)isSeeking;

- (void)doInitWithCompletionHandler:(completionBlock)completionHandler;
- (void)doLoadVideoContentWithCompletionHandler:(completionBlock)completionHandler;
- (void)doLoadVideoPlayerInfoWithCompletionHandler:(loadVideoPlayerInfoCompletionBlock)completionHandler;
- (void)doSeekWithTimeInMS:(NSInteger)timeInMS completionHandler:(completionBlock)completionHandler;
- (BOOL)doPlayWithCompletionHandler:(completionBlock)completionHandler;
- (BOOL)doPauseWithCompletionHandler:(completionBlock)completionHandler;
- (void)doCloseWithCompletionHandler:(completionBlock)completionHandler;
- (void)doChangeVideoViewDisplayMode;
- (void)doChangeVideoViewSize:(CGSize)size;
- (NSInteger)doLoadCurrentAudioTrackIndex;
- (void)doSetCurrentAudioTrackIndex:(NSInteger)index;
- (NSArray *)doLoadAudioTracks;
- (PKSubtitleInfo *)doLoadCurrentSubtitleInfo;
- (void)doSetSubtitleWithInfo:(PKSubtitleInfo *)subtitleInfo;
- (NSArray *)doLoadEmbeddedSubtitles;
- (void)doSetHardwareSpeedupEnable:(BOOL)enable;
- (BOOL)doLoadHardwareSpeedupEnable;

- (void)handlePlayCompletedWithType:(PKVideoPlayCompletionType)type
                              error:(NSError *)error;

@end
