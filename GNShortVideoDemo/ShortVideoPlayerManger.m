//
//  ShortVideoPlayerManger.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/26.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShortVideoPlayerManger.h"
#import "PlayerKit.h"
#import "PKTitleSource.h"
#import "PKPlayerStatusSource.h"
#import "PKSourceManager.h"
#import "ShortVideoPlayerShareView.h"
#import "ShortVideoPlayerErrorView.h"

//播放器当前方向
typedef NS_ENUM(NSInteger, PKVideoPlayerOrientation)
{
    kVideoPlayerPortrait = 0,    //竖直向上
    kVideoPlayerLandscapeLeft,   //水平向左
    kVideoPlayerLandscapeRight   //水平向右
};

@interface ShortVideoPlayerManger ()
{
    CGRect _initRect;
    PKVideoPlayerOrientation _playerOrientation;
}
@property (nonatomic, strong) ShortVideoPlayerShareView *shareView;
@property (nonatomic, strong) ShortVideoPlayerErrorView *errorView;

@end

@implementation ShortVideoPlayerManger

- (instancetype)init
{
    if (self = [super init])
    {
        [self initPlayer];
        
        [self initPlayStateSource];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ShortVideoPlayerManger alloc] init];
    });
    return instance;
}

#pragma mark -- 私有
- (void)initPlayer
{
    [PKPlayerManager sharedManager].externalCompleteView = self.shareView;
    [PKPlayerManager sharedManager].externalErrorView = self.errorView;
}

- (void)initPlayStateSource
{
    PKPlayerStatusSource *playerStateSource = [[PKPlayerStatusSource alloc] init];

    __weak typeof(self) weakSelf = self;
    [playerStateSource setScreenSizeSwitchBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if ([PKPlayerManager sharedManager].isFullScreen) //全屏 -> 普通
        {
            [self switchToNormal];
        }
        else //普通 -> 全屏
        {
            [self switchToFullScreen];
        }
    }];

    PKSourceManager *sourceManager = [[PKPlayerManager sharedManager] currentSourceManager];
    sourceManager.playerStatusSource = playerStateSource;
}

- (void)switchToFullScreen
{
    if (_videoIsVertical) //竖屏视频直接全屏
    {
        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
        {
            [_delegate shortVideoPlayerWillSwitchToFullScreen];
        }
        
        _initRect = self.playerVC.view.frame;
        [UIView animateWithDuration:0.3 animations:^{
            self.playerVC.view.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            [PKPlayerManager sharedManager].isFullScreen = YES;
            _playerOrientation = kVideoPlayerPortrait;
            
            if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                [_delegate shortVideoPlayerDidSwitchToFullScreen];
            }
        }];
    }
    else //横屏视频需要旋转
    {
        switch ([UIDevice currentDevice].orientation)
        {
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                {
                    [_delegate shortVideoPlayerWillSwitchToFullScreen];
                }
                
                _initRect = self.playerVC.view.frame;
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                } completion:^(BOOL finished) {
                    [PKPlayerManager sharedManager].isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                        [_delegate shortVideoPlayerDidSwitchToFullScreen];
                    }
                }];
                break;
            }
            case UIDeviceOrientationLandscapeLeft:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                {
                    [_delegate shortVideoPlayerWillSwitchToFullScreen];
                }
                
                _initRect = self.playerVC.view.frame;
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds; //设备方向为横屏方向直接全屏
                } completion:^(BOOL finished) {
                    [PKPlayerManager sharedManager].isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                        [_delegate shortVideoPlayerDidSwitchToFullScreen];
                    }
                }];
                break;
            }
            case UIDeviceOrientationLandscapeRight:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                {
                    [_delegate shortVideoPlayerWillSwitchToFullScreen];
                }
                
                _initRect = self.playerVC.view.frame;
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds; //设备方向为横屏方向直接全屏
                } completion:^(BOOL finished) {
                    [PKPlayerManager sharedManager].isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeLeft;
         
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                        [_delegate shortVideoPlayerDidSwitchToFullScreen];
                    }
                }];
                break;
            }
            default:
                break;
        }
    }
}

- (void)switchToNormal
{
    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToNormalScreen)]) {
        [_delegate shortVideoPlayerWillSwitchToNormalScreen];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.playerVC.view.transform = CGAffineTransformIdentity;
        self.playerVC.view.frame = _initRect;
        
    } completion:^(BOOL finished) {
        [PKPlayerManager sharedManager].isFullScreen = NO;
        _playerOrientation = kVideoPlayerPortrait;
        
        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToNormalScreen)]) {
            [_delegate shortVideoPlayerDidSwitchToNormalScreen];
        }
    }];

}

#pragma mark -- 属性
- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
    
    [PKPlayerManager sharedManager].videoUrl = videoUrl;
}

- (void)setVideoTitle:(NSString *)videoTitle
{
    _videoTitle = videoTitle;
    
    PKTitleSource *titleSource = [[PKTitleSource alloc] init];
    [titleSource setTitleBlock:^NSString *{
        return videoTitle;
    }];

    PKSourceManager *sourceManager = [[PKPlayerManager sharedManager] currentSourceManager];
    sourceManager.titleSource = titleSource;
}

- (UIViewController *)playerVC
{
    return [PKPlayerManager sharedManager].playerVC;
}

- (void)setPlayerVC:(UIViewController *)playerVC
{
    if (playerVC == nil) {
        [[PKPlayerManager sharedManager] releasePlayerVC];
    }
}

-  (ShortVideoPlayerShareView *)shareView
{
    if (!_shareView)
    {
        _shareView = [ShortVideoPlayerShareView instance];
        
        __weak typeof(self) weakSelf = self;
        _shareView.replayClickedBlock = ^(){
        
            __strong typeof(weakSelf) self = weakSelf;
            [self.shareView removeFromSuperview];
            self.videoUrl = self.videoUrl;
        };
    }
    return _shareView;
}

- (ShortVideoPlayerErrorView *)errorView
{
    if (!_errorView)
    {
        _errorView = [ShortVideoPlayerErrorView instance];
        
        __weak typeof(self) weakSelf = self;
        _errorView.replayClickedBlock = ^(){
            
            __strong typeof(weakSelf) self = weakSelf;
            [self.errorView removeFromSuperview];
            self.videoUrl = self.videoUrl;
        };
    }
    
    return _errorView;
}

#pragma mark -- 事件
- (void)orientChange:(NSNotification *)note
{
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;

    switch (orient)
    {
        case UIDeviceOrientationPortrait:
        {
            if (_playerOrientation != kVideoPlayerPortrait) //转向竖屏
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.transform = CGAffineTransformIdentity;
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                } completion:^(BOOL finished) {
                    _playerOrientation = kVideoPlayerPortrait;
                }];
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft://设备向左转
        {
            if (_playerOrientation == kVideoPlayerPortrait) //垂直 -> 右侧
            {
                if ([PKPlayerManager sharedManager].isFullScreen) //全屏状态，直接旋转
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                        self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                    } completion:^(BOOL finished) {
                        _playerOrientation = kVideoPlayerLandscapeRight;
                    }];
                }
                else //半屏状态，切换成全屏
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                    {
                        [_delegate shortVideoPlayerWillSwitchToFullScreen];
                    }
                    
                    _initRect = self.playerVC.view.frame;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                        self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                    } completion:^(BOOL finished) {
                        [PKPlayerManager sharedManager].isFullScreen = YES;
                        _playerOrientation = kVideoPlayerLandscapeRight;
                        
                        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)])
                        {
                            [_delegate shortVideoPlayerDidSwitchToFullScreen];
                        }
                    }];
                }
            }
            else if (_playerOrientation == kVideoPlayerLandscapeLeft) //左侧 -> 右侧
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.transform = CGAffineTransformMakeRotation(-M_PI_2 * 3);
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                } completion:^(BOOL finished) {
                    _playerOrientation = kVideoPlayerLandscapeRight;
                }];
            }
            
            break;
        }
        case UIDeviceOrientationLandscapeRight: //设备向右侧转
        {
            if (_playerOrientation == kVideoPlayerPortrait) //垂直 -> 左侧
            {
                if ([PKPlayerManager sharedManager].isFullScreen) //全屏状态，直接旋转
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.playerVC.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                    } completion:^(BOOL finished) {
                        _playerOrientation = kVideoPlayerLandscapeLeft;
                    }];
                }
                else //半屏状态，切换成全屏
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                    {
                        [_delegate shortVideoPlayerWillSwitchToFullScreen];
                    }
                    
                    _initRect = self.playerVC.view.frame;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.playerVC.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                    } completion:^(BOOL finished) {
                        [PKPlayerManager sharedManager].isFullScreen = YES;
                        _playerOrientation = kVideoPlayerLandscapeLeft;
                        
                        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)])
                        {
                            [_delegate shortVideoPlayerDidSwitchToFullScreen];
                        }
                    }];
                }
            }
            else if (_playerOrientation == kVideoPlayerLandscapeRight)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2 * 3);
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                } completion:^(BOOL finished) {
                    _playerOrientation = kVideoPlayerLandscapeLeft;
                }];
            }
            
            break;
        }
        default:
            break;
    }
}

@end
