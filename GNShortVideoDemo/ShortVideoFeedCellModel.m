//
//  ShortVideoFeedCellModel.m
//  ShortVideoFeedTest
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShortVideoFeedCellModel.h"

@implementation ShortVideoFeedCellModel

- (void)setImgUrl:(NSString *)imgUrl
{
    _imgUrl = imgUrl ? imgUrl : @"";
}

- (void)setMainTitle:(NSString *)mainTitle
{
    _mainTitle = mainTitle ? mainTitle : @"";
}

- (void)setUserHeaderUrl:(NSString *)userHeaderUrl
{
    _userHeaderUrl = userHeaderUrl ? userHeaderUrl : @"";
}

- (void)setUserName:(NSString *)userName
{
    _userName = userName ? userName : @"";
}

@end
