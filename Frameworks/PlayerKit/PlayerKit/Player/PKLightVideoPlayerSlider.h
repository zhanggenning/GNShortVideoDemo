//
//  PKLightVideoPlayerSlider.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//  进度条（轻量级播放器专用）

#import <UIKit/UIKit.h>

@protocol PKLightVideoPlayerSliderProtocol;

typedef void(^SliderValueChangeBlock)(CGFloat process);

@interface PKLightVideoPlayerSlider : UIView

//隐藏滑块
@property (nonatomic, assign) CGFloat thumbHidden;

//进度
@property (nonatomic, assign) CGFloat process;

//缓冲进度
@property (nonatomic, assign) CGFloat bufferProcess;

@property (nonatomic, weak) id<PKLightVideoPlayerSliderProtocol> delegate;

@end

@protocol PKLightVideoPlayerSliderProtocol <NSObject>

@optional

- (void)PKLightPlayerSlider:(PKLightVideoPlayerSlider *)slider progressWillChange:(CGFloat)process;

- (void)PKLightPlayerSlider:(PKLightVideoPlayerSlider *)slider progressDidChange:(CGFloat)process;

@end