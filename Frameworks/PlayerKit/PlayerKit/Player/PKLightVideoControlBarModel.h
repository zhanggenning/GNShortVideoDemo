//
//  PKLightVideoControlBarModel.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/20.
//  Copyright © 2016年 xunlei. All rights reserved.
//  控制条相关信息

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PKControlBarProtocol.h"

@interface PKLightVideoControlBarModel : NSObject

@property (nonatomic, weak) id<PKControlBarEventProtocol> delegate;

@property (nonatomic, strong, readonly) UIView *controlBarView;

@property (nonatomic, assign) PKVideoControlBarStyle controlBarStyle;

@property (nonatomic, assign) BOOL controlBarHidden;

@property (nonatomic, assign) PKVideoControlBarPlayState playState;

@property (nonatomic, assign) CGFloat playProcess;

@property (nonatomic, assign) CGFloat bufferProcess;

@property (nonatomic, assign) CGFloat playTime;

@property (nonatomic, assign) CGFloat durationTime;

@property (nonatomic, copy) NSString *mainTitle;

@end
