//
//  PKVideoPlayerViewController.h
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/22.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKVideoPlayerCoreBase;
@class PKSourceManager;

@interface PKVideoPlayerViewController : UIViewController

@property (strong, nonatomic) PKVideoPlayerCoreBase *videoPlayerCore;
@property (strong, nonatomic) PKSourceManager *sourceManager;

/// init: 根据xib初始化
+ (instancetype)nibInstance;

- (void)switchWithContentURLString:(NSString *)contentURLString;

- (void)switchWithContentStreamSlices:(NSArray *)contentStreamSlices;

- (void)pause;

- (void)resumePlaying;

- (void)close;

@end
