//
//  PKLightVideoVolumeManager.m
//  PlayerKit
//
//  Created by zhanggenning on 16/5/4.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoVolumeManager.h"

@interface PKLightVideoVolumeManager()

@property (nonatomic, strong) UISlider *volumeSlider;

@end

@implementation PKLightVideoVolumeManager

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PKLightVideoVolumeManager alloc] init];
    });
    
    return instance;
}

- (CGFloat)increaseVolume:(CGFloat)incrementInPercent {
    CGFloat volume = self.volumeSlider.value;
    volume += incrementInPercent;
    volume = MIN(1.0, volume);
    self.volumeSlider.value = volume;
    return volume;
}

- (CGFloat)decreaseVolume:(CGFloat)decrementInPercent {
    CGFloat volume = self.volumeSlider.value;
    volume -= decrementInPercent;
    volume = MAX(0.0, volume);
    self.volumeSlider.value = volume;
    return volume;
}

- (void)setVolume:(CGFloat)volumeInPercent {
    if (volumeInPercent < 0.0 || volumeInPercent > 1.0) {
        return;
    }
    
    self.volumeSlider.value = volumeInPercent;
}

- (MPVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -100, 100, 100)];
    }
    return _volumeView;
}

- (UISlider *)volumeSlider
{
    if (!_volumeSlider) {
        for (id subView in self.volumeView.subviews) {
            if ([subView isKindOfClass:[UISlider class]]) {
                _volumeSlider = subView;
            }
        }
    }
    return _volumeSlider;
}

- (CGFloat)volume
{
    if (self.volumeSlider) {
        return self.volumeSlider.value;
    }
    return 0.0;
}

@end
