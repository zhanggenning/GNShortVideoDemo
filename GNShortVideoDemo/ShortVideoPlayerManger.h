//
//  ShortVideoPlayerManger.h
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/26.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ShortVideoPlayerProtocol;

@interface ShortVideoPlayerManger : NSObject

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, copy) NSString *videoTitle;

@property (nonatomic, assign) BOOL videoIsVertical; //视频是否为竖屏

@property (nonatomic, strong) UIViewController *playerVC;

@property (nonatomic, weak) id<ShortVideoPlayerProtocol> delegate;

+ (instancetype)shareInstance;

@end


@protocol ShortVideoPlayerProtocol <NSObject>

@optional

- (void)shortVideoPlayerWillSwitchToFullScreen;

- (void)shortVideoPlayerDidSwitchToFullScreen;

- (void)shortVideoPlayerWillSwitchToNormalScreen;

- (void)shortVideoPlayerDidSwitchToNormalScreen;

@end