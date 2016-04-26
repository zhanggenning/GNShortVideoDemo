//
//  ShortVideoControlFlagView.h
//  ShortVideoFeedTest
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ShortVideoContorlFlagStyle) {
    ShortVideoControlFlagFun = 0,
    ShortVideoControlFlagComment,
    ShortVideoControlFlagShare
};

@interface ShortVideoControlFlagView : UIControl

@property (nonatomic, assign) ShortVideoContorlFlagStyle controlStyle;

@property (nonatomic, assign, readonly) BOOL isFlag;

- (void)setFlag:(BOOL)isFlag count:(NSInteger)count animation:(BOOL)isAnimation;

@end
