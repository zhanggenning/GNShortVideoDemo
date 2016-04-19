//
//  PKLightVideoPlayerViewController.h
//  PlayerKit
//  轻量级播放器
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKVideoPlayerCoreBase;
@class PKSourceManager;

@interface PKLightVideoPlayerViewController : UIViewController

@property (weak, nonatomic) PKVideoPlayerCoreBase *videoPlayerCore;
@property (weak, nonatomic) PKSourceManager *sourceManager;

+ (instancetype)nibInstance;

@end
