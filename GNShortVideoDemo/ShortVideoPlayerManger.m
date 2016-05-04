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
@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) UIViewController *videoPlayerVC;

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, assign) BOOL videoIsVertical;

@property (nonatomic, weak) UIViewController *superViewController;
@property (nonatomic, weak) UIView *superView;

@end

@implementation ShortVideoPlayerManger


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
    
    //初始化播放资源
    [self initPlayStateSource];
    
    //初始化标题资源
    [self initTitleSource:title];
    
    //初始化播放器
    _videoPlayerVC = [[PKPlayerManager sharedManager] lightPlayerWithVideoUrl:videoUrl
                                                                 completeView:self.shareView
                                                                    errorView:self.errorView
                                                                    backView:self.backView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _videoIsVertical = isVertical;
    _videoUrl = videoUrl;
    _videoTitle = title;
    _isFullScreen = NO;
    
    
    return _videoPlayerVC;
}

- (void)resetPlayerWithVideoUrl:(NSString *)videoUrl
                     videoTitle:(NSString *)title
                     isVertical:(BOOL)isVertical
{
    //切换url
    [[PKPlayerManager sharedManager] lightPlayerSwitchVideoUrl:videoUrl];
    
    //标题资源
    [self initTitleSource:title];
    
    _videoIsVertical = isVertical;
    _videoUrl = videoUrl;
    _videoTitle = title;
    _isFullScreen = NO;

}

- (void)releasePlayer
{
    if (_videoPlayerVC && !_playerRetain) {
        
        if ([_videoPlayerVC.view superview]) {
            [_videoPlayerVC.view removeFromSuperview];
        }
        
        if ([_videoPlayerVC parentViewController]) {
            [_videoPlayerVC removeFromParentViewController];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [self.playerWindow resignKeyWindow];
        self.playerWindow.hidden = YES;
        
        _videoPlayerVC = nil;
    }
}

#pragma mark -- 私有
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

    PKSourceManager *sourceManager = [[PKPlayerManager sharedManager] currentLightPlayerSourceManger];
    sourceManager.playerStatusSource = playerStateSource;
}

- (void)sendPlayerToWindow
{
    _playerRetain = YES;
    
    self.superViewController = _videoPlayerVC.parentViewController;
    self.superView = _videoPlayerVC.view.superview;

    [_videoPlayerVC removeFromParentViewController];

    _videoPlayerVC.view.frame = [_superView convertRect:_videoPlayerVC.view.frame toView:self.playerWindow];
    [_videoPlayerVC.view removeFromSuperview];
    
    [self.playerWindow makeKeyAndVisible];
    [self.playerWindow addSubview:_videoPlayerVC.view];
    
    _playerRetain = NO;
}

- (void)sendPlayerToSuperView
{
    _playerRetain = YES;
    
    if (_superViewController) {
        [_videoPlayerVC removeFromParentViewController];
        [_superViewController addChildViewController:_videoPlayerVC];
    }
    if (_superView) {
        _videoPlayerVC.view.frame = [self.playerWindow convertRect:_videoPlayerVC.view.frame toView:_superView];;
        [_videoPlayerVC.view removeFromSuperview];
        [_superView addSubview:_videoPlayerVC.view];
    }
    
    [self.playerWindow resignKeyWindow];
    self.playerWindow.hidden = YES;
    
    _playerRetain = NO;
}

- (void)initTitleSource:(NSString *)title
{
    PKTitleSource *titleSource = [[PKTitleSource alloc] init];
    [titleSource setTitleBlock:^NSString *{
        return _videoTitle;
    }];
    
    PKSourceManager *sourceManager = [[PKPlayerManager sharedManager] currentLightPlayerSourceManger];
    sourceManager.titleSource = titleSource;
}

- (void)switchToFullScreen
{
    if (_videoIsVertical) //竖屏视频直接全屏
    {
        [self sendPlayerToWindow];
        
        _initRect = self.playerVC.view.frame;
        
        [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.playerVC.view.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
        
            _isFullScreen = YES;
            _playerOrientation = kVideoPlayerPortrait;
            
        }];
    }
    else //横屏视频需要旋转
    {
        switch ([[UIApplication sharedApplication] statusBarOrientation])
        {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                [self sendPlayerToWindow];
                
                _initRect = self.playerVC.view.frame;
                
                [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                } completion:^(BOOL finished) {
   
                    _isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
                    
                }];
                break;
            }
            case UIInterfaceOrientationLandscapeLeft:
            {
                [self sendPlayerToWindow];
                
                _initRect = self.playerVC.view.frame;
                
                [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds; //设备方向为横屏方向直接全屏
                } completion:^(BOOL finished) {
                    
                    _isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;
 
                }];
                break;
            }
            case UIInterfaceOrientationLandscapeRight:
            {
                [self sendPlayerToWindow];
                
                _initRect = self.playerVC.view.frame;
                
                [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.playerVC.view.frame = [UIScreen mainScreen].bounds; //设备方向为横屏方向直接全屏
                } completion:^(BOOL finished) {
  
                    _isFullScreen = YES;
                    _playerOrientation = kVideoPlayerLandscapeRight;

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
    //换控制条
    [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarBase];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.playerVC.view.transform = CGAffineTransformIdentity;
        self.playerVC.view.frame = _initRect;
        
    } completion:^(BOOL finished) {

        _playerOrientation = kVideoPlayerPortrait;
        _isFullScreen = NO;

        [self sendPlayerToSuperView];
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

- (UIImageView *)backView
{
    if (!_backView) {
        _backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test"]];
    }
    return _backView;
}

- (UIViewController *)playerVC
{
    return _videoPlayerVC;
}

- (UIWindow *)playerWindow
{
    if (!_playerWindow)
    {
        _playerWindow = [[UIWindow alloc] init];
        _playerWindow.frame = [UIScreen mainScreen].bounds;
        _playerWindow.backgroundColor = [UIColor clearColor];
    }
    return _playerWindow;
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
                    [self sendPlayerToWindow];
                    
                    _initRect = self.playerVC.view.frame;
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                        self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                    } completion:^(BOOL finished) {
                        [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];
                        
                        _isFullScreen = YES;
                        _playerOrientation = kVideoPlayerLandscapeRight;
                        
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
                    [self sendPlayerToWindow];
                    
                    _initRect = self.playerVC.view.frame;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.playerVC.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        self.playerVC.view.frame = [UIScreen mainScreen].bounds;
                    } completion:^(BOOL finished) {
                        [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];
                        
                        _isFullScreen = YES;
                        _playerOrientation = kVideoPlayerLandscapeRight;

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
