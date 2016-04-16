//
//  PKDLNASource.h
//  PlayerKit
//
//  Created by lucky.li on 15/6/3.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PKEnum.h"
#import "PKVideoInfo.h"

/// DLNA开始回调
typedef void (^dlnaStartedBlock) (BOOL isCanceled);

/// DLNA结束回调
typedef void (^dlnaClosedBlock) ();

@interface PKDLNASource : NSObject

@property (copy, nonatomic) PKDisplayMode (^dlnaDisplayModeBlock) (void);
@property (copy, nonatomic) UIViewController * (^dlnaDeviceViewBlock) (PKVideoInfo *info,
dlnaStartedBlock callbackBlock);
@property (copy, nonatomic) UIViewController * (^dlnaPlayingTipViewBlock) (dlnaClosedBlock callbackBlock);

@end
