//
//  ShortVideoFeedCellModel.h
//  ShortVideoFeedTest
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShortVideoFeedCellModel : NSObject

@property (nonatomic, copy) NSString *imgUrl;

@property (nonatomic, copy) NSString *mainTitle;

@property (nonatomic, copy) NSString *userHeaderUrl;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BOOL isZanFlagged;

@property (nonatomic, assign) NSInteger zanCount;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, assign) BOOL videoIsVertical;

@end
