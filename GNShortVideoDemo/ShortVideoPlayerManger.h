//
//  ShortVideoPlayerManger.h
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/26.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShortVideoPlayerManger : NSObject

@property (nonatomic, strong, readonly) UIViewController *playerVC;

@property (nonatomic, strong) UIWindow *playerWindow;

//保留player,防止被释放
@property (nonatomic, assign) BOOL playerRetain;

+ (instancetype)shareInstance;

- (UIViewController *)playerWithVideoUrl:(NSString *)videoUrl
                              videoTitle:(NSString *)title
                              isVertical:(BOOL)isVertical;

- (void)resetPlayerWithVideoUrl:(NSString *)videoUrl
                     videoTitle:(NSString *)title
                     isVertical:(BOOL)isVertical;


- (void)releasePlayer;

@end