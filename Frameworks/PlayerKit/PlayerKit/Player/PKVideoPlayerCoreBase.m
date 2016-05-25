//
//  PKVideoPlayerCoreBase.m
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/24.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKVideoPlayerCoreBase.h"
#import "PKVideoInfo.h"
#import "TWeakTimer.h"
#import "PKVolumeController.h"
#import "NSObject+pk.h"
#import "UIScreen+pk.h"
#import "PKSubtitleInfo.h"

#pragma mark -

/// 快进时间20秒
static const NSInteger kFastForwardTimeInMS = 20*1000;

#pragma mark -
@interface PKVideoPlayerCoreBase ()

@property (strong, nonatomic) PKVideoInfo *videoInfo;
@property (strong, nonatomic) PKVideoInfo *nextVideoInfo;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) TWeakTimer *pollTimer;
@property (assign, nonatomic) BOOL isSwitching;
@property (assign, nonatomic) BOOL delayOpenForInactive;
@property (strong, nonatomic) NSDate *startPlayingTime;

- (void)handleLoadVideoContentCompleted;
- (void)handleLoadVideoPlayerInfoCompletedWithPlayPosition:(NSInteger)playPositionInMS
                                        bufferPositionInMS:(NSInteger)bufferPositionInMS
                                            bufferProgress:(CGFloat)bufferProgress
                                      downloadSpeedInBytes:(long long)downloadSpeedInBytes;
- (void)handleSeekCompleted;

- (void)resetInit;
- (void)startTimer;
- (void)stopTimer;
- (void)pollTimerAction:(TWeakTimer *)timer;
- (void)switchToNext;
- (BOOL)needSwitchToNext;
- (void)initNotifications;
- (void)removeNotifications;
- (void)becomeActiveNotification:(NSNotification *)notification;

@end

#pragma mark -
@implementation PKVideoPlayerCoreBase

@dynamic hardwareSpeedupEnable;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initNotifications];
        if (!self.videoView) {
            CGRect rect = [UIScreen landscapeScreenBounds];
            self.videoView = [[UIView alloc] initWithFrame:rect];
        }
        [self doInitWithCompletionHandler:NULL];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [self removeNotifications];
    [self setVolumeChangedBlock:NULL];
    [self stopTimer];
}

- (void)setVideoViewDisplayMode:(PKVideoViewDisplayMode)videoViewDisplayMode {
    _videoViewDisplayMode = videoViewDisplayMode;
    
    [self doChangeVideoViewDisplayMode];
}

- (void)setHardwareSpeedupEnable:(BOOL)hardwareSpeedupEnable {
    [self doSetHardwareSpeedupEnable:hardwareSpeedupEnable];
}

- (BOOL)hardwareSpeedupEnable {
    BOOL enable = [self doLoadHardwareSpeedupEnable];
    return enable;
}

#pragma mark - Public

- (void)openWithContentURLString:(NSString *)contentURLString {
    PKVideoInfo *vi = [[PKVideoInfo alloc] init];
    vi.contentURLString = contentURLString;
    [self openWithVideoInfo:vi];
}

- (void)openWithContentStreamSlices:(NSArray *)contentStreamSlices {
    PKVideoInfo *vi = [[PKVideoInfo alloc] init];
    vi.contentStreamSlices = contentStreamSlices;
    [self openWithVideoInfo:vi];
}

- (void)openWithVideoInfo:(PKVideoInfo *)videoInfo {
    if (self.videoPlayerCoreState != kVideoPlayerCoreStateReady) {
        NSLog(@"[WARNING]:\nOpen video when it is not ready!");
        return;
    }
    
    [self resetInit];
    self.videoInfo = videoInfo;
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        self.delayOpenForInactive = YES;
    } else {
        [NSObject asyncTaskWithBlock:^{
            __weak typeof(self) weakSelf = self;
            [self doLoadVideoContentWithCompletionHandler:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf handleLoadVideoContentCompleted];
            }];
        }];
    }
}

- (void)switchVideoWithContentURLString:(NSString *)contentURLString {
    PKVideoInfo *vi = [[PKVideoInfo alloc] init];
    vi.contentURLString = contentURLString;
    [self switchVideoWithVideoInfo:vi];
}

- (void)switchVideoWithContentStreamSlices:(NSArray *)contentStreamSlices {
    PKVideoInfo *vi = [[PKVideoInfo alloc] init];
    vi.contentStreamSlices = contentStreamSlices;
    [self switchVideoWithVideoInfo:vi];
}

- (void)switchVideoWithVideoInfo:(PKVideoInfo *)videoInfo {
    self.nextVideoInfo = videoInfo;
    [self switchToNext];
}

- (void)setVideoViewSize:(CGSize)size {
    self.videoView.frame = CGRectMake(0, 0, size.width, size.height);
    
    [self doChangeVideoViewSize:self.videoView.bounds.size];
}

- (BOOL)isReadyForPlaying {
    if (self.videoPlayerCoreState > kVideoPlayerCoreStateOpening &&
        self.videoPlayerCoreState < kVideoPlayerCoreStateClosing) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isBufferReadyForPlaying {
    if (!self.videoInfo.isOnlineVideo) {
        return YES;
    } if (self.isReadyForPlaying && self.bufferProgressInPercent >= 1.0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isPaused {
    if (self.videoPlayerCoreState == kVideoPlayerCoreStatePaused) {
        return YES;
    } else {
        return NO;
    }
}

/// 是否可以关闭
- (BOOL)canClose {
    if (self.videoPlayerCoreState == kVideoPlayerCoreStateReady ||
        self.videoPlayerCoreState == kVideoPlayerCoreStateClosing) {
        return NO;
    } else {
        return YES;
    }
}

- (void)loadVideoPlayerInfoWithCompletionHandler:(loadVideoPlayerInfoCompletionBlock)completionHandler {
    [self doLoadVideoPlayerInfoWithCompletionHandler:completionHandler];
}

- (NSInteger)playPositionInMS {
    __block NSInteger result = 0;
    [self doLoadVideoPlayerInfoWithCompletionHandler:^(NSInteger playPositionInMS,
                                                       NSInteger bufferPositionInMS,
                                                       CGFloat bufferProgressInPercent,
                                                       long long downloadSpeedInBytes) {
        result = playPositionInMS;
    }];
    return result;
}

- (NSInteger)bufferPositionInMS {
    __block NSInteger result = 0;
    [self doLoadVideoPlayerInfoWithCompletionHandler:^(NSInteger playPositionInMS,
                                                       NSInteger bufferPositionInMS,
                                                       CGFloat bufferProgressInPercent,
                                                       long long downloadSpeedInBytes) {
        result = bufferPositionInMS;
    }];
    return result;
}

- (CGFloat)bufferProgressInPercent {
    __block CGFloat result = 0;
    [self doLoadVideoPlayerInfoWithCompletionHandler:^(NSInteger playPositionInMS,
                                                       NSInteger bufferPositionInMS,
                                                       CGFloat bufferProgressInPercent,
                                                       long long downloadSpeedInBytes) {
        result = bufferProgressInPercent;
    }];
    return result;
}

- (long long)downloadSpeedInBytes {
    return self.latestDownloadSpeedInBytes;
}

- (void)play {
    [self playWithExecutionHandler:NULL];
}

- (void)playWithExecutionHandler:(executionBlock)executionHandler {
    if (self.isReadyForPlaying) {
        [self.class asyncTaskWithBlock:^{
            BOOL result = [self doPlayWithCompletionHandler:NULL];
            if (executionHandler) {
                executionHandler (result);
            }
        }];
    } else {
        NSLog(@"[WARNING]:\nPlay video when it is not ready!");
        if (executionHandler) {
            executionHandler (NO);
        }
    }
}

- (void)pause {
    [self pauseWithExecutionHandler:NULL];
}

- (void)pauseWithExecutionHandler:(executionBlock)executionHandler {
    if (self.isReadyForPlaying) {
        [self.class asyncTaskWithBlock:^{
            BOOL result = [self doPauseWithCompletionHandler:NULL];
            if (executionHandler) {
                executionHandler (result);
            }
        }];
    } else {
        NSLog(@"[WARNING]:\nPause video when it is not ready!");
        if (executionHandler) {
            executionHandler (NO);
        }
    }
}

- (void)seekWithProgress:(CGFloat)progress {
    if (progress < 0.0 || progress > 1.0) {
        return;
    }
    
    NSInteger timeInMS = progress*self.videoInfo.videoDurationInMS;
    [self seekWithTimeInMS:timeInMS];
}

- (void)seekWithTimeInMS:(NSInteger)timeInMS {
    [self.class asyncTaskWithBlock:^{
        __weak typeof(self) weakSelf = self;
        [self doSeekWithTimeInMS:timeInMS completionHandler:^{
            [weakSelf handleSeekCompleted];
        }];
    }];
}

- (NSInteger)fastForward {
    NSInteger positionInMS = self.playPositionInMS;
    positionInMS += kFastForwardTimeInMS;
    positionInMS = MIN(self.videoInfo.videoDurationInMS, positionInMS);
    [self seekWithTimeInMS:positionInMS];
    return positionInMS;
}

- (NSInteger)rewind {
    NSInteger positionInMS = self.playPositionInMS;
    positionInMS -= kFastForwardTimeInMS;
    positionInMS = MAX(0, positionInMS);
    [self seekWithTimeInMS:positionInMS];
    return positionInMS;
}

- (void)close {
    self.nextVideoInfo = nil;
    [self.class asyncTaskWithBlock:^{
        [self doCloseWithCompletionHandler:NULL];
    }];
}

- (CGFloat)volume {
    return [PKVolumeController volume];
}

- (void)setVolume:(CGFloat)volumeInPercent {
    [PKVolumeController setVolume:volumeInPercent];
}

- (CGFloat)increaseVolume:(CGFloat)incrementInPercent {
    return [PKVolumeController increaseVolume:incrementInPercent];
}

- (CGFloat)decreaseVolume:(CGFloat)decrementInPercent {
    return [PKVolumeController decreaseVolume:decrementInPercent];
}

- (void)setVolumeChangedBlock:(void (^) (CGFloat newVolume))block {
    [PKVolumeController sharedController].volumeChangedBlock = block;
}

- (NSInteger)currentAudioTrackIndex {
    NSInteger index = [self doLoadCurrentAudioTrackIndex];
    return index;
}

- (void)setCurrentAudioTrackIndex:(NSInteger)index {
    [self doSetCurrentAudioTrackIndex:index];
}

- (NSArray *)audioTracks {
    NSArray *array = [self doLoadAudioTracks];
    return array;
}

- (PKSubtitleInfo *)currentSubtitleInfo {
    PKSubtitleInfo *info = [self doLoadCurrentSubtitleInfo];
    return info;
}

- (void)setSubtitleWithInfo:(PKSubtitleInfo *)subtitleInfo {
    [self doSetSubtitleWithInfo:subtitleInfo];
}

- (NSArray *)embeddedSubtitles {
    NSArray *array = [self doLoadEmbeddedSubtitles];
    return array;
}

- (NSTimeInterval)timeIntervalSinceStartPlaying {
    if (!self.startPlayingTime) {
        return 0;
    }
    
    NSDate *currentTime = [NSDate date];
    NSTimeInterval seconds = [currentTime timeIntervalSinceDate:self.startPlayingTime];
    return seconds;
}

#pragma mark - Protected

+ (NSError *)errorWithCode:(NSInteger)errorCode {
    NSString *errorMessage = [NSString stringWithFormat:@"{ErrorCode = %ld}", (long)errorCode];
    NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:nil];
    return error;
}

- (PKVideoPlayerCoreType)videoPlayerCoreType {
    NSAssert(NO, @"[Forbidden]");
    return kVideoPlayerCoreTypeUnknown;
}

- (BOOL)isSeeking {
    NSAssert(NO, @"[Forbidden]");
    return NO;
}

- (void)doInitWithCompletionHandler:(completionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
}

- (void)doLoadVideoContentWithCompletionHandler:(completionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
}

- (void)doLoadVideoPlayerInfoWithCompletionHandler:(loadVideoPlayerInfoCompletionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
}

- (void)doSeekWithTimeInMS:(NSInteger)timeInMS completionHandler:(completionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
}

- (BOOL)doPlayWithCompletionHandler:(completionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
    return NO;
}

- (BOOL)doPauseWithCompletionHandler:(completionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
    return NO;
}

- (void)doCloseWithCompletionHandler:(completionBlock)completionHandler {
    NSAssert(NO, @"[Forbidden]");
}

- (void)doChangeVideoViewDisplayMode {
    NSAssert(NO, @"[Forbidden]");
}

- (void)doChangeVideoViewSize:(CGSize)size {
    NSAssert(NO, @"[Forbidden]");
}

- (NSInteger)doLoadCurrentAudioTrackIndex {
    NSAssert(NO, @"[Forbidden]");
    return 0;
}

- (void)doSetCurrentAudioTrackIndex:(NSInteger)index {
    NSAssert(NO, @"[Forbidden]");
    return;
}

- (NSArray *)doLoadAudioTracks {
    NSAssert(NO, @"[Forbidden]");
    return nil;
}

- (PKSubtitleInfo *)doLoadCurrentSubtitleInfo {
    NSAssert(NO, @"[Forbidden]");
    return nil;
}

- (void)doSetSubtitleWithInfo:(PKSubtitleInfo *)subtitleInfo {
    NSAssert(NO, @"[Forbidden]");
}

- (NSArray *)doLoadEmbeddedSubtitles {
    NSAssert(NO, @"[Forbidden]");
    return nil;
}

- (void)doSetHardwareSpeedupEnable:(BOOL)enable {
    NSAssert(NO, @"[Forbidden]");
}

- (BOOL)doLoadHardwareSpeedupEnable {
    NSAssert(NO, @"[Forbidden]");
    return NO;
}

- (void)handlePlayCompletedWithType:(PKVideoPlayCompletionType)type
                              error:(NSError *)error {
    [self stopTimer];
    
    [self switchToNext];

    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerCore:playCompletedWithType:error:)]) {
        [self.delegate videoPlayerCore:self
                 playCompletedWithType:type
                                 error:error];
    }
}

#pragma mark - Private

- (void)handleLoadVideoContentCompleted {
    if (self.isSwitching && [self.videoInfo isSameWithVideoInfo:self.nextVideoInfo]) {
        self.isSwitching = NO;
        self.nextVideoInfo = nil;
    }
    
    if (self.isReadyForPlaying) {
        self.startPlayingTime = [NSDate date];
        self.error = nil;
        [self startTimer];
    } else {
        self.startPlayingTime = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerCore:openCompletedWithResult:videoInfo:error:)]) {
        [self.delegate videoPlayerCore:self
               openCompletedWithResult:self.isReadyForPlaying
                             videoInfo:self.videoInfo
                                 error:self.error];
    }
}

- (void)handleLoadVideoPlayerInfoCompletedWithPlayPosition:(NSInteger)playPositionInMS
                                        bufferPositionInMS:(NSInteger)bufferPositionInMS
                                            bufferProgress:(CGFloat)bufferProgress
                                      downloadSpeedInBytes:(long long)downloadSpeedInBytes; {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerCore:playPositionUpdate:)]) {
        [self.delegate videoPlayerCore:self playPositionUpdate:playPositionInMS];
    }
    
    if (self.videoInfo.isOnlineVideo && self.delegate &&
        [self.delegate respondsToSelector:@selector(videoPlayerCore:bufferPositionUpdate:)]) {
        [self.delegate videoPlayerCore:self bufferPositionUpdate:bufferPositionInMS];
    }
    
    if (self.videoInfo.isOnlineVideo && self.delegate &&
        [self.delegate respondsToSelector:@selector(videoPlayerCore:bufferProgressUpdate:)]) {
        [self.delegate videoPlayerCore:self bufferProgressUpdate:bufferProgress];
    }
    
    if (self.videoInfo.isOnlineVideo && self.delegate &&
        [self.delegate respondsToSelector:@selector(videoPlayerCore:downloadSpeedUpdate:)]) {
        [self.delegate videoPlayerCore:self downloadSpeedUpdate:downloadSpeedInBytes];
    }
}

- (void)handleSeekCompleted {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerCore:seekCompletedWithError:)]) {
        [self.delegate videoPlayerCore:self seekCompletedWithError:nil];
    }
}

- (void)resetInit {
    self.error = nil;
    self.isUsingHardwareSpeedup = NO;
}

- (void)startTimer {
    if (!self.pollTimer) {
        [self.class asyncTaskWithBlock:^{
            @autoreleasepool {
                self.pollTimer =
                [[TWeakTimer alloc] initWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(pollTimerAction:)
                                                userInfo:nil
                                                 repeats:YES];
            }
            [[NSRunLoop currentRunLoop] run];
        }];
    }
}

- (void)stopTimer {
    if (self.pollTimer) {
        self.pollTimer = nil;
    }
}

- (void)pollTimerAction:(TWeakTimer *)timer {
    if (self.isSeeking) {
        NSLog(@"[WARNING]: Update player info when seeking!\n%s", __FUNCTION__);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self doLoadVideoPlayerInfoWithCompletionHandler:^(NSInteger playPositionInMS,
                                                       NSInteger bufferPositionInMS,
                                                       CGFloat bufferProgressInPercent,
                                                       long long downloadSpeedInBytes) {
        [weakSelf handleLoadVideoPlayerInfoCompletedWithPlayPosition:playPositionInMS
                                                  bufferPositionInMS:bufferPositionInMS
                                                      bufferProgress:bufferProgressInPercent
                                                downloadSpeedInBytes:downloadSpeedInBytes];
    }];
}

- (void)switchToNext {
    if (self.needSwitchToNext) {
        self.isSwitching = YES;
        if (self.videoPlayerCoreState == kVideoPlayerCoreStateReady) {
            [self openWithVideoInfo:self.nextVideoInfo];
        } else {
            [self doCloseWithCompletionHandler:NULL];
        }
    }
}

- (BOOL)needSwitchToNext {
    if (self.nextVideoInfo && ![self.nextVideoInfo isSameWithVideoInfo:self.videoInfo]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)initNotifications {
    [self removeNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)becomeActiveNotification:(NSNotification *)notification {
    if (self.delayOpenForInactive) {
        self.delayOpenForInactive = NO;
        [self openWithVideoInfo:self.videoInfo];
    }
}

@end
