//
//  ShortVideoPlayerErrorView.h
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/26.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReplayClickedBlock)();

@interface ShortVideoPlayerErrorView : UIView

+ (instancetype)instance;

@property (nonatomic, strong) ReplayClickedBlock replayClickedBlock;

@end
