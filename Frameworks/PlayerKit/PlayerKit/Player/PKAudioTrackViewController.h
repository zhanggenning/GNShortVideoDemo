//
//  PKAudioTrackViewController.h
//  PlayerKit
//
//  Created by lucky.li on 15/7/1.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKAudioTrackViewController : UIViewController

@property(copy, nonatomic) void (^selectionChangeHandler) (NSInteger newIndex);

/// init: 根据xib初始化
+ (instancetype)nibInstance;

- (void)setDataSourceArray:(NSArray *)dataSourceArray currentIndex:(NSInteger)currentIndex;

@end
