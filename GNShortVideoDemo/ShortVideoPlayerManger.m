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
    BOOL _isFullScreen;
}
@property (nonatomic, strong) ShortVideoPlayerShareView *shareView;
@property (nonatomic, strong) ShortVideoPlayerErrorView *errorView;
@property (nonatomic, strong) UIViewController *videoPlayerVC;

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, assign) BOOL videoIsVertical;

@end

@implementation ShortVideoPlayerManger

- (instancetype)init
{
    if (self = [super init])
    {
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

- (UIViewController *)playerWithVideoUrl:(NSString *)videoUrl
                              videoTitle:(NSString *)title
                              isVertical:(BOOL)isVertical
{
    if (_videoPlayerVC)
    {
         NSAssert(NO, @"[ERROR]: video player vc is exist!");
        _videoPlayerVC = nil;
    }
    
    _videoPlayerVC = [[PKPlayerManager sharedManager] lightPlayerWithVideoUrl:videoUrl
                                                                 completeView:self.shareView
                                                                    errorView:self.errorView];
    
    //切换url
    [self switchVideoUrl:videoUrl];
    
    //初始化播放资源
    [self initPlayStateSource];
    
    //初始化标题资源
    [self initTitleSource:title];
    
    _videoIsVertical = isVertical;
    
     [[PKPlayerManager sharedManager] resetLightPlayer];
    
    [_errorView removeFromSuperview];
    
    [_shareView removeFromSuperview];
    
    _isFullScreen = NO;
    
    return _videoPlayerVC;
}

- (void)resetPlayerWithVideoUrl:(NSString *)videoUrl
                     videoTitle:(NSString *)title
                     isVertical:(BOOL)isVertical
{
    //切换url
    [self switchVideoUrl:videoUrl];
    
    //标题资源
    [self initTitleSource:title];
    
    _videoIsVertical = isVertical;
    
    [[PKPlayerManager sharedManager] resetLightPlayer];
    
    [_errorView removeFromSuperview];
    
    [_shareView removeFromSuperview];
}

- (void)releasePlayer
{
    if (_videoPlayerVC) {
        _videoPlayerVC = nil;
    }
}

#pragma mark -- 私有
- (void)switchVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
    
    [PKPlayerManager sharedManager].videoUrl = videoUrl;
}

- (void)initPlayStateSource
{
    PKPlayerStatusSource *playerStateSource = [[PKPlayerStatusSource alloc] init];

    __weak typeof(self) weakSelf = self;
    [playerStateSource setScreenSizeSwitchBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (_isFullScreen) //全屏 -> 普通
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

- (void)initTitleSource:(NSString *)title
{
    _videoTitle = title;
    
    PKTitleSource *titleSource = [[PKTitleSource alloc] init];
    [titleSource setTitleBlock:^NSString *{
        return _videoTitle;
    }];
    
    PKSourceManager *sourceManager = [[PKPlayerManager sharedManager] currentSourceManager];
    sourceManager.titleSource = titleSource;
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
        
        [PKPlayerManager sharedManager].playerStyle = kVideoControlBarFull;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.playerVC.view.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
        
            _isFullScreen = YES;
            _playerOrientation = kVideoPlayerPortrait;
            
            if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                [_delegate shortVideoPlayerDidSwitchToFullScreen];
            }
        }];
    }
    else //横屏视频需要旋转
    {
        switch ([[UIApplication sharedApplication] statusBarOrientation])
        {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                {
                    [_delegate shortVideoPlayerWillSwitchToFullScreen];
                }
                
                _initRect = self.playerVC.view.frame;
                
                [PKPlayerManager sharedManager].playerStyle = kVideoControlBarFull;
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                } completion:^(BOOL finished) {
   
                    _isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                        [_delegate shortVideoPlayerDidSwitchToFullScreen];
                    }
                }];
                break;
            }
            case UIInterfaceOrientationLandscapeLeft:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                {
                    [_delegate shortVideoPlayerWillSwitchToFullScreen];
                }
                
                _initRect = self.playerVC.view.frame;
                
                [PKPlayerManager sharedManager].playerStyle = kVideoControlBarFull;
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds; //设备方向为横屏方向直接全屏
                } completion:^(BOOL finished) {
                    
                    _isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToFullScreen)]) {
                        [_delegate shortVideoPlayerDidSwitchToFullScreen];
                    }
                }];
                break;
            }
            case UIInterfaceOrientationLandscapeRight:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerWillSwitchToFullScreen)])
                {
                    [_delegate shortVideoPlayerWillSwitchToFullScreen];
                }
                
                _initRect = self.playerVC.view.frame;
                
                [PKPlayerManager sharedManager].playerStyle = kVideoControlBarFull;
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds; //设备方向为横屏方向直接全屏
                } completion:^(BOOL finished) {
  
                    _isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
         
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
    
    //换控制条
    [PKPlayerManager sharedManager].playerStyle = kVideoControlBarBase;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.playerVC.view.transform = CGAffineTransformIdentity;
        self.playerVC.view.frame = _initRect;
        
    } completion:^(BOOL finished) {

        _playerOrientation = kVideoPlayerPortrait;
        _isFullScreen = NO;

        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoPlayerDidSwitchToNormalScreen)]) {
            [_delegate shortVideoPlayerDidSwitchToNormalScreen];
        }
    }];

}

#pragma mark -- 属性
-  (ShortVideoPlayerShareView *)shareView
{
    if (!_shareView)
    {
        _shareView = [ShortVideoPlayerShareView instance];
        
        __weak typeof(self) weakSelf = self;
        _shareView.replayClickedBlock = ^(){
        
            [weakSelf resetPlayerWithVideoUrl:weakSelf.videoUrl
                                   videoTitle:weakSelf.videoTitle
                                   isVertical:weakSelf.videoIsVertical];
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
            
            [weakSelf resetPlayerWithVideoUrl:weakSelf.videoUrl
                                   videoTitle:weakSelf.videoTitle
                                   isVertical:weakSelf.videoIsVertical];
        };
    }
    
    return _errorView;
}

- (UIViewController *)playerVC
{
    return _videoPlayerVC;
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
                if (_isFullScreen) //全屏状态，直接旋转
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
                        [PKPlayerManager sharedManager].playerStyle = kVideoControlBarFull;
                        
                        _isFullScreen = YES;
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
                if (_isFullScreen) //全屏状态，直接旋转
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
                        [PKPlayerManager sharedManager].playerStyle = kVideoControlBarFull;
                        
                        _isFullScreen = YES;
                        _playerOrientation = kVideoPlayerLandscapeRight;
                        
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
