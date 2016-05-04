//
//  PKLightVideoVolumeManager.h
//  PlayerKit
//
//  Created by zhanggenning on 16/5/4.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PKLightVideoVolumeManager : NSObject

@property (nonatomic, strong) MPVolumeView *volumeView;

@property (nonatomic, assign) CGFloat volume;

+ (instancetype)shareInstance;

- (CGFloat)increaseVolume:(CGFloat)incrementInPercent;

- (CGFloat)decreaseVolume:(CGFloat)decrementInPercent;

- (void)setVolume:(CGFloat)volumeInPercent;

@end
