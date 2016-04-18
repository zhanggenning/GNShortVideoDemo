//
//  PKLightVideoPlayerSlider.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//  进度条（轻量级播放器专用）

#import <UIKit/UIKit.h>

typedef void(^SliderValueChangeBlock)(CGFloat process);

@interface PKLightVideoPlayerSlider : UIView

@property (nonatomic, assign) CGFloat process;

@property (nonatomic, assign) CGFloat bufferProcess;

@property (nonatomic, strong) SliderValueChangeBlock valuedChangedBlock ;

@end
