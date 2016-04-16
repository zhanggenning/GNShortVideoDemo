//
//  PKXMPVideoPlayerCore.m
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/24.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKXMPVideoPlayerCore.h"
//#import "APlayerIOS.h"
#import <APlayerIOS/APlayerIOS.h>
#import "PKVideoInfo.h"
#import "PKSubtitleInfo.h"
#import "NSString+pk.h"

#pragma mark -

/// APlayerIOS配置参数枚举
typedef NS_ENUM(NSInteger, PKXMPVideoPlayerConfigType) {
    KXMPVideoPlayerConfigTypePlayResult=7,                  // 播放结果(CONFIGID_PLAYRESULT)
    KXMPVideoPlayerConfigTypeDisplayMode=251,               // 显示模式(CONFIGID_VIEWMODE)
    KXMPVideoPlayerConfigTypeBufferPosition=31,             // bufferPositionInMS(CONFIGID_READPOSITION)
    KXMPVideoPlayerConfigTypeDownloadSizeInBytes=29,        // downloadSizeInBytes(CONFIGID_READSIZE)
    KXMPVideoPlayerConfigTypeCurrentSubtitleIndex=506,      // 当前字幕(CONFIGID_SUBTITLESELECTED)
    KXMPVideoPlayerConfigTypeEmbeddedSubtitles=505,         // 内嵌字幕列表(CONFIGID_SUBTITLELIST)
    KXMPVideoPlayerConfigTypeExternalSubtitlePath=503,      // 外挂字幕路径(CONFIGID_SUBTITLEFILENAME)
    KXMPVideoPlayerConfigTypeMediaInfo=34,                  // 视频信息(CONFIGID_MEDIAINFO)
    KXMPVideoPlayerConfigTypeFilesize=5,                    // 视频文件大小(CONFIGID_FILESIZE)
    KXMPVideoPlayerConfigTypeHardwareSpeedupStatus=211,     // 硬解状态(CONFIGID_SPEEDUPSTATUS)
    KXMPVideoPlayerConfigTypeHardwareSpeedupEnable=209,     // 是否允许硬解(CONFIGID_SPEEDUPENABLE)
    KXMPVideoPlayerConfigTypeCurrentAudioTrackIndex=403,    // 当前音轨(CONFIGID_AUDIOTRACKCURRENT)
    KXMPVideoPlayerConfigTypeAudioTracks=402,               // 音轨列表(CONFIGID_AUDIOTRACKLIST)
    KXMPVideoPlayerConfigTypeMediaType=1199,                // 文件类型（视频／音乐）(CONFIGID_VALID_AUDIOVIDEO)
};

#pragma mark -
@interface PKXMPVideoPlayerCore () <APlayerIOSDelegate>

@property (strong, nonatomic) APlayerIOS *aPlayer;
@property (copy, nonatomic) completionBlock loadVideoContentCompletionBlock;
@property (copy, nonatomic) completionBlock seekCompletionBlock;
@property (assign, nonatomic) long long lastDownloadSizeInBytes;
@property (strong, nonatomic) NSDate *lastTimeReadDownloadSize;

- (void)handleOpenCompleted;
- (void)handlePlayCompleted;
- (void)clearLastDownloadSize;

@end

#pragma mark -
@implementation PKXMPVideoPlayerCore

- (PKVideoPlayerCoreType)videoPlayerCoreType {
    return kVideoPlayerCoreTypeXMP;
}

- (BOOL)isSeeking {
    return self.aPlayer.IsSeeking;
}

- (void)doInitWithCompletionHandler:(completionBlock)completionHandler {
    self.aPlayer = [[APlayerIOS alloc] Init:self.videoView];
    self.aPlayer.delegate = self;
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)doLoadVideoContentWithCompletionHandler:(completionBlock)completionHandler {
    self.loadVideoContentCompletionBlock = completionHandler;
    NSInteger result = [self.aPlayer Open:self.videoInfo.playContentURLString];
    if (result != 0) {
        NSLog(@"[ERROR]: Didn't execute opening!");
    }
}

- (void)doLoadVideoPlayerInfoWithCompletionHandler:(loadVideoPlayerInfoCompletionBlock)completionHandler {
    NSInteger playPositionInMS = 0;
    NSInteger bufferPositionInMS = 0;
    CGFloat bufferProgressInPercent = 0.0;
    long long downloadSpeedInBytes = 0;
    
    playPositionInMS = self.aPlayer.GetPosition;
    
    if (self.videoInfo.isOnlineVideo) {
        NSString *bufferPositionString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeBufferPosition];
        bufferPositionInMS = bufferPositionString.integerValue;
        
        NSInteger bufferProgressInInt = self.aPlayer.GetBufferProgress;
        if (bufferProgressInInt == -1 || bufferProgressInInt == 100) {
            bufferProgressInPercent = 1.0;
        } else if (bufferProgressInInt >= 0 && bufferProgressInInt < 100) {
            bufferProgressInPercent = (double)bufferProgressInInt/100;
        }
        
        NSString *downloadSizeString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeDownloadSizeInBytes];
        long long downloadSizeInBytes = downloadSizeString.longLongValue;
        NSDate *currentTime = [NSDate date];
        if (self.lastDownloadSizeInBytes > 0) {
            NSTimeInterval duration = [currentTime timeIntervalSinceDate:self.lastTimeReadDownloadSize];
            downloadSpeedInBytes = (double)(downloadSizeInBytes - self.lastDownloadSizeInBytes) / duration;
        }
        self.lastDownloadSizeInBytes = downloadSizeInBytes;
        self.lastTimeReadDownloadSize = currentTime;
        self.latestDownloadSpeedInBytes = downloadSpeedInBytes;
    }
    
    NSLog(@"[PLAYER INFO]: \nplayPositionInMS: %ld\nbufferPositionInMS: %ld\nbufferProgressInPercent: %f\ndownloadSpeedInBytes: %lld",
          (long)playPositionInMS,
          (long)bufferPositionInMS,
          bufferProgressInPercent,
          downloadSpeedInBytes);
    
    if (completionHandler) {
        completionHandler(playPositionInMS,
                          bufferPositionInMS,
                          bufferProgressInPercent,
                          downloadSpeedInBytes);
    }
}

- (void)doSeekWithTimeInMS:(NSInteger)timeInMS completionHandler:(completionBlock)completionHandler {
    [self clearLastDownloadSize];
    
    self.seekCompletionBlock = completionHandler;
    NSInteger result = [self.aPlayer SetPosition:timeInMS];
    if (result != 0) {
        NSLog(@"[WARNING]: Didn't execute seeking!");
    }
}

- (BOOL)doPlayWithCompletionHandler:(completionBlock)completionHandler {
    NSInteger result = [self.aPlayer Play];
    if (result != 0) {
        NSLog(@"[WARNING]: Didn't execute playing!");
    }
    
    if (completionHandler) {
        completionHandler();
    }
    
    return (result == 0);
}

- (BOOL)doPauseWithCompletionHandler:(completionBlock)completionHandler {
    NSInteger result = [self.aPlayer Pause];
    if (result != 0) {
        NSLog(@"[WARNING]: Didn't execute pausing!");
    }
    
    if (completionHandler) {
        completionHandler();
    }
    
    return (result == 0);
}

- (void)doCloseWithCompletionHandler:(completionBlock)completionHandler {
    NSInteger result = [self.aPlayer Close];
    if (result != 0) {
        NSLog(@"[WARNING]: Didn't execute closing!");
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)doChangeVideoViewDisplayMode {
    [self.aPlayer SetConfig:KXMPVideoPlayerConfigTypeDisplayMode
                   strValue:[NSString stringWithFormat:@"%ld", (long)self.videoViewDisplayMode]];
}

- (void)doChangeVideoViewSize:(CGSize)size {
    [self.aPlayer SetView:self.videoView];
}

- (NSInteger)doLoadCurrentAudioTrackIndex {
    NSString *indexString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeCurrentAudioTrackIndex];
    NSInteger index = indexString.integerValue;
    return index;
}

- (void)doSetCurrentAudioTrackIndex:(NSInteger)index {
    NSString *indexString = [NSString stringWithFormat:@"%ld", (long)index];
    [self.aPlayer SetConfig:KXMPVideoPlayerConfigTypeCurrentAudioTrackIndex strValue:indexString];
    return;
}

- (NSArray *)doLoadAudioTracks {
    NSString *tracksString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeAudioTracks];
    NSArray *array = [tracksString componentsSeparatedByString:@";"];
    return array;
}

- (PKSubtitleInfo *)doLoadCurrentSubtitleInfo {
    PKSubtitleInfo *info = [[PKSubtitleInfo alloc] init];
    
    NSInteger index = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeCurrentSubtitleIndex].integerValue;
    if (index == -1) {
        info.type = kSubtitleTypeNone;
    } else {
        NSArray *embeddedSubtitles = [self doLoadEmbeddedSubtitles];
        if (index >= 0 && index < embeddedSubtitles.count) {
            info.type = kSubtitleTypeEmbedded;
            info.embeddedSubtitleIndex = index;
        } else if (index == embeddedSubtitles.count) {
            NSString *path = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeExternalSubtitlePath];
            info.type = kSubtitleTypeExternal;
            info.externalSubtitlePath = path;
        }
    }
    
    return info;
}

- (void)doSetSubtitleWithInfo:(PKSubtitleInfo *)subtitleInfo {
    if (subtitleInfo.type == kSubtitleTypeNone) {
        [self.aPlayer SetConfig:KXMPVideoPlayerConfigTypeCurrentSubtitleIndex
                       strValue:[NSString stringWithFormat:@"%ld", (long)-1]];
    } else {
        NSArray *embeddedSubtitles = [self doLoadEmbeddedSubtitles];
        if (subtitleInfo.type == kSubtitleTypeEmbedded &&
            subtitleInfo.embeddedSubtitleIndex >=0 &&
            subtitleInfo.embeddedSubtitleIndex < embeddedSubtitles.count) {
            [self.aPlayer SetConfig:KXMPVideoPlayerConfigTypeCurrentSubtitleIndex
                           strValue:[NSString stringWithFormat:@"%ld", (long)subtitleInfo.embeddedSubtitleIndex]];
        } else if (subtitleInfo.type == kSubtitleTypeExternal) {
            [self.aPlayer SetConfig:KXMPVideoPlayerConfigTypeExternalSubtitlePath
                           strValue:subtitleInfo.externalSubtitlePath];
        }
    }
}

- (NSArray *)doLoadEmbeddedSubtitles {
    NSString *subtitlesString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeEmbeddedSubtitles];
    NSArray *subtitlesArray = [subtitlesString componentsSeparatedByString:@";"];
    
    NSString *path = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeExternalSubtitlePath];
    if (path) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:subtitlesArray];
        [array removeLastObject];
        subtitlesArray = [array copy];
    }
    
    return subtitlesArray;
}

- (void)doSetHardwareSpeedupEnable:(BOOL)enable {
    NSString *speedupString = enable?@"1":@"0";
    [self.aPlayer SetConfig:KXMPVideoPlayerConfigTypeHardwareSpeedupEnable strValue:speedupString];
}

- (BOOL)doLoadHardwareSpeedupEnable {
    NSString *speedupString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeHardwareSpeedupEnable];
    NSInteger speedupInt = [speedupString integerValue];
    BOOL enable = (speedupInt == 1)?YES:NO;
    return enable;
}

#pragma mark - Public

#pragma mark - Private

- (void)handleOpenCompleted {
    [self clearLastDownloadSize];
    
    if (!self.isReadyForPlaying) {
        NSString *playResult = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypePlayResult];
        NSInteger errorCode = [playResult integerValue];
        self.error = [self.class errorWithCode:errorCode];
    } else {
        self.videoInfo.videoDurationInMS = self.aPlayer.GetDuration;
        self.videoInfo.videoWidth = self.aPlayer.GetVideoWidth;
        self.videoInfo.videoHeight = self.aPlayer.GetVideoHeight;
        
        NSString *filesizeString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeFilesize];
        self.videoInfo.filesize = [filesizeString longLongValue];
        
        NSString *mediaInfoString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeMediaInfo];
        NSDictionary *mediaInfoDic = [mediaInfoString jsonFormat];
        self.videoInfo.containerFormat = mediaInfoDic[@"format"];
        self.videoInfo.bitrate = [mediaInfoDic[@"bitrate"] integerValue];
        self.videoInfo.videoFormatInfoArray = mediaInfoDic[@"video"];
        self.videoInfo.audioFormatInfoArray = mediaInfoDic[@"audio"];
        
        NSString *speedupString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeHardwareSpeedupStatus];
        NSInteger speedupInt = [speedupString integerValue];
        self.isUsingHardwareSpeedup = (speedupInt == 1)?YES:NO;
        
        NSString *mediaTypeString = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypeMediaType];
        NSInteger mediaTypeInt = [mediaTypeString integerValue];
        self.videoInfo.isAudio = (mediaTypeInt == 1)?YES:NO;
    }
    
    if (self.loadVideoContentCompletionBlock) {
        self.loadVideoContentCompletionBlock();
        self.loadVideoContentCompletionBlock = NULL;
    }
}

- (void)handlePlayCompleted {
    PKVideoPlayCompletionType type = kVideoPlayCompletionTypeEOF;

    NSInteger playResult = [self.aPlayer GetConfig:KXMPVideoPlayerConfigTypePlayResult].integerValue;
    if (playResult >= 0 && playResult <= 1) {
        type = playResult;
    } else {
        type = kVideoPlayCompletionTypeError;
        NSInteger errorCode = playResult;
        self.error = [self.class errorWithCode:errorCode];
    }
    
    [self handlePlayCompletedWithType:type error:self.error];
}

- (void)clearLastDownloadSize {
    self.lastDownloadSizeInBytes = 0;
    self.lastTimeReadDownloadSize = nil;
}

#pragma mark - APlayerIOSDelegate

- (void)player:(APlayerIOS *)player OnStateChanged:(NSInteger)nOldState nNewState:(NSInteger)nNewState {
    NSLog(@"%s\nold: %ld\nnew: %ld", __FUNCTION__, (long)nOldState, (long)nNewState);
    self.videoPlayerCoreState = (PKVideoPlayerCoreState)nNewState;
    
    if (nOldState == kVideoPlayerCoreStateOpening) {
        [self handleOpenCompleted];
    } else if (nNewState == kVideoPlayerCoreStateReady) {
        [self handlePlayCompleted];
    }
}

- (void)OnOpenSucceeded:(APlayerIOS *)player {
    NSLog(@"%s", __FUNCTION__);
}

- (void)player:(APlayerIOS *)player OnSeekCompleted:(NSInteger)nPosition {
    if (self.seekCompletionBlock) {
        self.seekCompletionBlock();
        self.seekCompletionBlock = NULL;
    }
}

- (void)player:(APlayerIOS *)player OnBufferProgress:(CGFloat)nProgress {
    NSLog(@"%s", __FUNCTION__);
}

- (void)player:(APlayerIOS *)player OnEvent:(NSInteger)nEventCode nEventParam:(NSInteger)nEventParam {
    NSLog(@"%s", __FUNCTION__);
}

@end
