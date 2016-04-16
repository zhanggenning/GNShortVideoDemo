//
//  PKVolumeController.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/15.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKVolumeController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIDevice+pk.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark -
@interface PKVolumeController ()

+ (MPVolumeView *)volumeView;

+ (UISlider *)volumeSlider;

- (void)initNotifications;

- (void)removeNotifications;

- (void)volumeChangedNotification:(NSNotification *)notification;

@end

#pragma mark -
@implementation PKVolumeController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initNotifications];
    }
    return self;
}

- (void)dealloc {
    [self removeNotifications];
}

#pragma mark - Public

+ (instancetype)sharedController {
    static PKVolumeController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PKVolumeController alloc] init];
    });
    return sharedInstance;
}

+ (CGFloat)volume {
    UISlider *volumeSlider = [self volumeSlider];
    return volumeSlider.value;
}

+ (void)setVolume:(CGFloat)volumeInPercent {
    if (volumeInPercent < 0.0 || volumeInPercent > 1.0) {
        return;
    }
    
    UISlider *volumeSlider = [self volumeSlider];
    volumeSlider.value = volumeInPercent;
}

+ (CGFloat)increaseVolume:(CGFloat)incrementInPercent {
    CGFloat volume = [self volume];
    volume += incrementInPercent;
    volume = MIN(1.0, volume);
    [self setVolume:volume];
    return volume;
}

+ (CGFloat)decreaseVolume:(CGFloat)decrementInPercent {
    CGFloat volume = [self volume];
    volume -= decrementInPercent;
    volume = MAX(0.0, volume);
    [self setVolume:volume];
    return volume;
}

#pragma mark - Private

+ (MPVolumeView *)volumeView {
    static MPVolumeView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPVolumeView alloc] init];
    });
    return sharedInstance;
}

+ (UISlider *)volumeSlider {
    static UISlider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MPVolumeView *volumeView = [self volumeView];
        for (id subView in volumeView.subviews) {
            if ([subView isKindOfClass:[UISlider class]]) {
                sharedInstance = subView;
            }
        }
    });
    return sharedInstance;
}

- (void)initNotifications {
    [self removeNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChangedNotification:) name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)volumeChangedNotification:(NSNotification *)notification {
    CGFloat volume = [[[notification userInfo]
                       objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (self.volumeChangedBlock) {
        self.volumeChangedBlock(volume);
    }
}

@end
