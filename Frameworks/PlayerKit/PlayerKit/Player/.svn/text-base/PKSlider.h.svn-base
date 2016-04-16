//
//  PKSlider.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/5.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -

@class PKSlider;

@protocol PKSliderDelegate <NSObject>

@optional

- (void)sliderProgressValueChanged:(PKSlider *)slider;

@end

#pragma mark -
@interface PKSlider : UIView

@property (weak, nonatomic) id<PKSliderDelegate> delegate;
@property (assign, nonatomic) CGFloat progressInPercent;                     /// 范围[0.0, 1.0]
@property (assign, nonatomic) CGFloat bufferProgressInPercent;               /// 范围[0.0, 1.0]
@property (assign, nonatomic, readonly) BOOL isUserInteracting;
@property (assign, nonatomic) BOOL showBufferProgress;

/// init: 根据xib初始化
+ (instancetype)nibInstance;

/// thumb的中心点位置
- (CGPoint)thumbBtnCenterInSlider;

@end
