//
//  ShortVideoPlayerErrorView.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/26.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShortVideoPlayerErrorView.h"

@implementation ShortVideoPlayerErrorView

+ (instancetype)instance
{
    return  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
}

- (IBAction)replayBtnAction:(UIButton *)sender
{
    if (_replayClickedBlock) {
        _replayClickedBlock();
    }
}

@end
