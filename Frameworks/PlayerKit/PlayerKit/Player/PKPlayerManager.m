//
//  PKPlayerManager.m
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/24.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKPlayerManager.h"
#import "PKVideoPlayerViewController.h"
#import "PKXMPVideoPlayerCore.h"
#import "PKSystemVideoPlayerCore.h"
#import "NSBundle+pk.h"
#import "NSObject+pk.h"
#import "UIViewController+pk.h"
#import "PKToolKit.h"
#import "PKStreamSlice.h"
#import "PKSourceManager.h"
#import "PKRecordSource.h"
#import "PKTitleSource.h"
#import "PKResolutionSource.h"
#import "PKEpisodeSource.h"
#import "PKSubtitleSource.h"
#import "PKStatisticSource.h"
#import "PKVolumeController.h"

#import "PKLightVideoPlayerViewController.h"

#pragma mark -
@interface PKPlayerManager ()

@property (strong, nonatomic) PKSourceManager *sourceManager;
@property (strong, nonatomic) PKXMPVideoPlayerCore *xmpVideoPlayerCore;
@property (strong, nonatomic) PKSystemVideoPlayerCore *systemVideoPlayerCore;
@property (weak, nonatomic) PKVideoPlayerViewController *videoPlayerVC;
@property (strong, nonatomic) PKLightVideoPlayerViewController *lightVideoPlayerVC;

- (void)initSourceManager;

@end

#pragma mark -
@implementation PKPlayerManager

- (PKXMPVideoPlayerCore *)xmpVideoPlayerCore {
    if (!_xmpVideoPlayerCore) {
        _xmpVideoPlayerCore = [[PKXMPVideoPlayerCore alloc] init];
    }
    
    return _xmpVideoPlayerCore;
}

- (PKSystemVideoPlayerCore *)systemVideoPlayerCore {
    if (!_systemVideoPlayerCore) {
        _systemVideoPlayerCore = [[PKSystemVideoPlayerCore alloc] init];
    }
    
    return _systemVideoPlayerCore;
}

#pragma mark - Public

+ (instancetype)sharedManager {
    static PKPlayerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PKPlayerManager alloc] init];
        /**
         * 解决iOS9音量bug：iOS9必须要在生成MPVolumeView后过一段时间才能获取到音量
         */
        [PKVolumeController volume];
    });
    return sharedInstance;
}

- (void)clearSources {
    self.sourceManager = nil;
}

- (PKSourceManager *)currentSourceManager {
    if (self.videoPlayerVC){
        return self.videoPlayerVC.sourceManager;
    }
    else if (_lightVideoPlayerVC.sourceManager) {
        return _lightVideoPlayerVC.sourceManager;
    }
    else {
        [self initSourceManager];
        return self.sourceManager;
    }
}

- (BOOL)isPlaying {
    return (self.videoPlayerVC != nil);
}

- (void)pause {
    if (self.videoPlayerVC) {
        [self.videoPlayerVC pause];
    }
}

- (void)resumePlaying {
    if (self.videoPlayerVC) {
        [self.videoPlayerVC resumePlaying];
    }
}

- (void)close {
    if (self.videoPlayerVC) {
        [self.videoPlayerVC close];
    }
}

- (PKVideoInfo *)currentVideoInfo {
    if (!self.isPlaying) {
        return nil;
    }
    
    return self.xmpVideoPlayerCore.videoInfo;
}

- (void)playWithContentURLString:(NSString *)contentURLString {
    if (self.videoPlayerVC) {
        NSAssert(NO, @"[ERROR]: Play when is playing!");
        [self clearSources];
        return;
    }
    
    PKVideoPlayerViewController *vc = [PKVideoPlayerViewController nibInstance];
    vc.sourceManager = self.sourceManager;
    [self clearSources];
    vc.videoPlayerCore = self.xmpVideoPlayerCore;
    self.videoPlayerVC = vc;
    
    [self.xmpVideoPlayerCore switchVideoWithContentURLString:contentURLString];
    
    [NSObject asyncTaskOnMainWithBlock:^{
        [UIViewController presentViewController:vc animated:YES completion:NULL];
    }];
}

- (void)playWithContentStreamSlices:(NSArray *)contentStreamSlices {
    if (self.videoPlayerVC) {
        NSAssert(NO, @"[ERROR]: Play when is playing!");
        [self clearSources];
        return;
    }
    
    PKVideoPlayerViewController *vc = [PKVideoPlayerViewController nibInstance];
    vc.sourceManager = self.sourceManager;
    [self clearSources];
    vc.videoPlayerCore = self.xmpVideoPlayerCore;
    self.videoPlayerVC = vc;
    
    [self.xmpVideoPlayerCore switchVideoWithContentStreamSlices:contentStreamSlices];
    
    [NSObject asyncTaskOnMainWithBlock:^{
        [UIViewController presentViewController:vc animated:YES completion:NULL];
    }];
}

- (void)playWithLocalPathsArray:(NSArray *)localPathsArray {
    [NSObject asyncTaskWithBlock:^{
        NSMutableArray *slices = [NSMutableArray array];
        for (NSString *localPath in localPathsArray) {
            NSInteger durationInMS = [PKToolKit videoDurationInMSWithLocalPath:localPath];
            if (durationInMS > 0) {
                PKStreamSlice *slice = [[PKStreamSlice alloc] init];
                slice.urlString = localPath;
                slice.durationInSeconds = durationInMS / 1000;
                [slices addObject:slice];
            } else {
                NSLog(@"[ERROR]: Video file with zero duration!\n%s", __FUNCTION__);
                [self clearSources];
                return;
            }
        }
        [self playWithContentStreamSlices:slices];
    }];
}

- (void)switchWithContentURLString:(NSString *)contentURLString {
    if (!self.videoPlayerVC) {
        NSAssert(NO, @"[ERROR]: Switch without playerVC!");
        return;
    }
    
    [self.videoPlayerVC switchWithContentURLString:contentURLString];
}

- (void)switchWithContentStreamSlices:(NSArray *)contentStreamSlices {
    if (!self.videoPlayerVC) {
        NSAssert(NO, @"[ERROR]: Switch without playerVC!");
        return;
    }
    
    [self.videoPlayerVC switchWithContentStreamSlices:contentStreamSlices];
}

- (void)switchWithLocalPathsArray:(NSArray *)localPathsArray {
    if (!self.videoPlayerVC) {
        NSAssert(NO, @"[ERROR]: Switch without playerVC!");
        return;
    }
    
    [NSObject asyncTaskWithBlock:^{
        NSMutableArray *slices = [NSMutableArray array];
        for (NSString *localPath in localPathsArray) {
            NSInteger durationInMS = [PKToolKit videoDurationInMSWithLocalPath:localPath];
            if (durationInMS > 0) {
                PKStreamSlice *slice = [[PKStreamSlice alloc] init];
                slice.urlString = localPath;
                slice.durationInSeconds = durationInMS / 1000;
                [slices addObject:slice];
            } else {
                NSLog(@"[ERROR]: Video file with zero duration!\n%s", __FUNCTION__);
                [self clearSources];
                return;
            }
        }
        [self.videoPlayerVC switchWithContentStreamSlices:slices];
    }];
}


#pragma mark -- 新增
- (UIViewController *)lightVideoPlayerVC
{
    if (!_lightVideoPlayerVC)
    {
        PKLightVideoPlayerViewController *vc = [PKLightVideoPlayerViewController nibInstance];
        vc.sourceManager = self.sourceManager;
        [self clearSources];
        vc.videoPlayerCore = self.xmpVideoPlayerCore;
        _lightVideoPlayerVC = vc;
    }

    return _lightVideoPlayerVC;
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
        
    [self.xmpVideoPlayerCore switchVideoWithContentURLString:videoUrl];
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    if (_isFullScreen != isFullScreen)
    {
        if (isFullScreen)
        {
            self.lightVideoPlayerVC.controlBarStyle = kVideoControlBarFull;
        }
        else
        {
            self.lightVideoPlayerVC.controlBarStyle = kVideoControlBarBase;
        }
        
        _isFullScreen = isFullScreen;
    }
    _isFullScreen = isFullScreen;
}

- (UIViewController *)playerVC
{
    return self.lightVideoPlayerVC;
}

- (void)releasePlayerVC
{
    if (self.lightVideoPlayerVC) {
        self.lightVideoPlayerVC = nil;
    }
}

#pragma mark - Private

- (void)initSourceManager {
    if (!self.sourceManager) {
        self.sourceManager = [[PKSourceManager alloc] init];
    }
    
    if (_lightVideoPlayerVC) {
        self.lightVideoPlayerVC.sourceManager = self.sourceManager;
    }
}

@end
