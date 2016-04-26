//
//  ShortVideoPlayerShareView.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/26.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShortVideoPlayerShareView.h"

@implementation ShortVideoPlayerShareView

+ (instancetype)instance
{
    return  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
}

- (IBAction)replayAction:(UIButton *)sender
{
    if (_replayClickedBlock) {
        _replayClickedBlock();
    }
}

- (IBAction)shareAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
            NSLog(@"分享至微信");
            break;
        }
        case 101:
        {
            NSLog(@"分享至朋友圈");
            break;
        }
        case 102:
        {
            NSLog(@"分享至qq");
            break;
        }
        case 103:
        {
            NSLog(@"分享至微博");
            break;
        }
        default:
            break;
    }
    
}

@end
