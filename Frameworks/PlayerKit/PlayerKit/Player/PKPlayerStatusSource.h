//
//  PKPlayerStatusSource.h
//  PlayerKit
//
//  Created by lucky.li on 15/4/15.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKVideoInfo.h"

@interface PKPlayerStatusSource : NSObject

@property (copy, nonatomic) BOOL (^needResumePlayingBlock) ();
@property (copy, nonatomic) void (^openCompletedBlock) (PKVideoInfo *info);
@property (copy, nonatomic) void (^playCompletedBlock) (PKVideoInfo *info);
@property (copy, nonatomic) void (^screenSizeSwitchBlock)(); //半屏／全屏状态切换
@end
