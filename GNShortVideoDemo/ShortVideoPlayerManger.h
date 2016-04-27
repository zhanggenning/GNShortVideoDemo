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

@property (nonatomic, strong, readonly) UIViewController *playerVC;

@property (nonatomic, weak) id<ShortVideoPlayerProtocol> delegate;

+ (instancetype)shareInstance;

- (UIViewController *)playerWithVideoUrl:(NSString *)videoUrl
                              videoTitle:(NSString *)title
                              isVertical:(BOOL)isVertical;

- (void)resetPlayerWithVideoUrl:(NSString *)videoUrl
                     videoTitle:(NSString *)title
                     isVertical:(BOOL)isVertical;


- (void)releasePlayer;

@end


@protocol ShortVideoPlayerProtocol <NSObject>

@optional

- (void)shortVideoPlayerWillSwitchToFullScreen;

- (void)shortVideoPlayerDidSwitchToFullScreen;

- (void)shortVideoPlayerWillSwitchToNormalScreen;

- (void)shortVideoPlayerDidSwitchToNormalScreen;

@end