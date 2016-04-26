//
//  PKLightVideoPlayerViewController.h
//  PlayerKit
//  轻量级播放器
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKControlBarDefine.h"

@class PKVideoPlayerCoreBase;
@class PKSourceManager;

@interface PKLightVideoPlayerViewController : UIViewController

@property (strong, nonatomic) PKVideoPlayerCoreBase *videoPlayerCore;
@property (strong, nonatomic) PKSourceManager *sourceManager;

@property (assign, nonatomic) PKVideoControlBarStyle controlBarStyle;

+ (instancetype)nibInstance;

@end
