//
//  PKLightVideoPlayerViewController.m
//  PlayerKit
//  轻量级播放器
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoPlayerViewController.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"
#import "NSObject+pk.h"
#import "PKVideoPlayerCoreBase.h"
#import "PKVideoInfo.h"
#import "PKSourceManager.h"
#import "PKLightVideoControlBarModel.h"
#import "PKTitleSource.h"
#import "PKPlayerStatusSource.h"
#import "TWeakTimer.h"
#import "PKPlayerManager.h"
#import "PKLightVideoVolumeManager.h"

@interface PKLightVideoPlayerViewController () <PKVideoPlayerCoreDelegate, PKControlBarEventProtocol>
{
    BOOL _isContorlBarLoaded; //控制条加载
    BOOL _isProcessChangeing; //进度改变中
    BOOL _isPlayerUIInited;   //界面初始化
    CGRect _currentRect;
}

@property (strong, nonatomic) TWeakTimer *autoHideControlTimer;
@property (strong, nonatomic) PKLightVideoControlBarModel *controlBarModel;

@end

@implementation PKLightVideoPlayerViewController

- (void)dealloc
{
    [self unloadVideoControlBar];
    
    [self.videoPlayerCore close];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSLog(@"页面释放.....");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //装载控制条
    [self loadVideoControlBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    //注：音量视图一定要在当前视图层级才能隐藏
    [self.view addSubview:[PKLightVideoVolumeManager shareInstance].volumeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //刷新标题
    if (_sourceManager.titleSource.titleBlock)
    {
        self.controlBarModel.mainTitle = _sourceManager.titleSource.titleBlock();
    }
    
    //同步状态
    if (!_videoPlayerCore.isReadyForPlaying)
    {
        self.controlBarModel.playState = kVideoControlBarBuffering;
        self.controlBarModel.userInteractive = NO;
        [self addExternBackView];
    }
    
    self.controlBarModel.volume = [PKLightVideoVolumeManager shareInstance].volume;
    self.controlBarModel.brightness = [UIScreen mainScreen].brightness;
}

- (void)viewDidLayoutSubviews
{
    if (!CGRectEqualToRect(_currentRect, self.view.bounds)) {
        
        if (_videoPlayerCore.videoView.superview == self.view) {
            [_videoPlayerCore setVideoViewSize:self.view.bounds.size];
        }
        
        _currentRect = self.view.bounds;
    }
}

#pragma mark -- 公共API
+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKLightVideoPlayerViewController *instance = nil;
    instance = [[PKLightVideoPlayerViewController alloc]
                    initWithNibName:NSStringFromClass([PKLightVideoPlayerViewController class])
                    bundle:bundle];
    return instance;
}

- (void)resetPlayerUI
{
    self.controlBarModel.playProcess = 0.0;
    self.controlBarModel.bufferProcess = 0.0;
    self.controlBarModel.playTime = 0;
    self.controlBarModel.durationTime = 0;
    self.controlBarModel.controlBarHidden = NO;
    [self stopAutoHideControlTimer];
    
    //外部视图
    if (_externalErrorView && _externalErrorView.superview) {
        [_externalErrorView removeFromSuperview];
    }
    if (_externalCompleteView && _externalCompleteView.superview) {
        [_externalCompleteView removeFromSuperview];
    }
    
    //隐藏播放视图
    [self removeVideoView];
}

- (void)resumePlaying
{
    if (_videoPlayerCore.isPaused) {
        [self switchPlayStateToPause:NO];
    }
}

- (void)pause
{
    if (!_videoPlayerCore.isPaused) {
        [self switchPlayStateToPause:YES];
    }
}

#pragma mark -- 私有API
- (void)addVideoView
{
    [self removeVideoView];
    
    _videoPlayerCore.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:_videoPlayerCore.videoView atIndex:0];
    [_videoPlayerCore setVideoViewSize:self.view.bounds.size];
}

- (void)removeVideoView
{
    if (_videoPlayerCore.videoView.superview)
    {
        [_videoPlayerCore.videoView removeFromSuperview];
    }
}


- (void)loadVideoControlBar
{
    if (!_isContorlBarLoaded)
    {
        [self.view addSubview:self.controlBarModel.controlBarView];
        
        [self addContraintsOnView:self.controlBarModel.controlBarView];
        
        self.controlBarModel.delegate = self;
        
        _isContorlBarLoaded = YES;
    }
}

- (void)unloadVideoControlBar
{
    if (_isContorlBarLoaded)
    {
        [self.controlBarModel.controlBarView removeFromSuperview];

        self.controlBarModel.delegate = nil;
        
        _isContorlBarLoaded = NO;
    }
}


- (void)addExternBackView
{
    if (_externalBackView && _isContorlBarLoaded) {
        
        if (_externalBackView.superview) {
            [_externalBackView removeFromSuperview];
        }
        
        [self.view insertSubview:_externalBackView belowSubview:self.controlBarModel.controlBarView];
        [self addContraintsOnView:_externalBackView];
    }
}

- (void)removeExternBackView
{
    if (_externalBackView && _externalBackView.superview) {
        [_externalBackView removeFromSuperview];
    }
}

- (void)addContraintsOnView:(UIView *)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *contraints1 = [NSLayoutConstraint  constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(view)];
    NSArray *contraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(view)];
    
    if (view.superview)
    {
        [view.superview addConstraints:contraints1];
        [view.superview addConstraints:contraints2];
    }
}

- (void)startAutoHideControlTimer
{
    [NSObject asyncTaskOnMainWithBlock:^{
            self.autoHideControlTimer =
            [[TWeakTimer alloc] initWithTimeInterval:2.0
                                              target:self
                                            selector:@selector(autoHideControlBar:)
                                            userInfo:nil
                                             repeats:NO];
    }];
}

- (void)stopAutoHideControlTimer
{
    self.autoHideControlTimer = nil;
}

- (void)postStartPlayingNotification {
    NSDictionary *userInfo = @{kPKPlayerNotificationVideoInfoKey:self.videoPlayerCore.videoInfo};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPKPlayerStartPlayingNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)postFinishPlayingNotification {
    NSDictionary *userInfo = @{kPKPlayerNotificationVideoInfoKey:self.videoPlayerCore.videoInfo};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPKPlayerFinishPlayingNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)switchPlayStateToPause:(BOOL)isPause
{
    __weak typeof(self) weakSelf = self;
    
    if (isPause)
    {
        [self.videoPlayerCore pauseWithExecutionHandler:^(BOOL executed) {
            
            __strong typeof(weakSelf) self = weakSelf;
            
            if (executed)
            {
                //停止自动隐藏
                [self stopAutoHideControlTimer];
                
                [NSObject asyncTaskOnMainWithBlock:^{
                    self.controlBarModel.playState = kVideoControlBarPlay;
                    self.controlBarModel.controlBarHidden = NO;
                }];
            }
        }];
    }
    else
    {
        [self.videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            
            __strong typeof(weakSelf) self = weakSelf;
            
            if (executed)
            {
                //重置自动隐藏
                [self startAutoHideControlTimer];
                
                [NSObject asyncTaskOnMainWithBlock:^{
                    self.controlBarModel.playState = kVideoControlBarPause;
                }];
            }
        }];
    }
}

#pragma mark -- 事件
- (void)autoHideControlBar:(TWeakTimer *)timer
{
    if (!_videoPlayerCore.isPaused && !_controlBarModel.controlBarHidden)
    {
        _controlBarModel.controlBarHidden = YES;
    }
}

//进入后台，停止播放
- (void)resignActiveNotification:(NSNotification *)notification
{
    if (!self.videoPlayerCore.isPaused)
    {
        [self switchPlayStateToPause:YES];
    }
}

//音量改变
- (void)volumeChanged:(NSNotification *)notification
{
    CGFloat volume = [[[notification userInfo]
                       objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    _controlBarModel.volume = volume;
}

#pragma mark -- 属性
- (PKLightVideoControlBarModel *)controlBarModel
{
    if (!_controlBarModel)
    {
        _controlBarModel = [[PKLightVideoControlBarModel alloc] init];
        _controlBarModel.delegate = self;
    }
    return _controlBarModel;
}

- (void)setControlBarStyle:(PKVideoControlBarStyle)controlBarStyle
{
    if (_controlBarStyle != controlBarStyle)
    {
        //更换控制栏
        [self unloadVideoControlBar];
         self.controlBarModel.controlBarStyle = controlBarStyle;
        [self loadVideoControlBar];
        
        //重置自动隐藏
        self.controlBarModel.controlBarHidden = NO;
        [self startAutoHideControlTimer];
        
        _controlBarStyle = controlBarStyle;
    }
}

- (void)setVideoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
{
    _videoPlayerCore = videoPlayerCore;
    
    if (_videoPlayerCore)
    {
        _videoPlayerCore.delegate = self;
    }
}

#pragma mark -- 代理
#pragma mark ---- <PKVideoPlayerCoreDelegate>
- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
openCompletedWithResult:(BOOL)isReadyForPlaying
              videoInfo:(PKVideoInfo *)videoInfo
                  error:(NSError *)error
{
    NSLog(@"轻量级播放器>>>>>>>>>>>>> 加载完成");

    if (isReadyForPlaying)
    {
        self.controlBarModel.userInteractive = YES;
        
        //开始播放通知
        [self postStartPlayingNotification];
        
        //加载完成回调
        if (_sourceManager.playerStatusSource.openCompletedBlock) {
            _sourceManager.playerStatusSource.openCompletedBlock(videoInfo);
        }
        
        [NSObject syncTaskOnMainWithBlock:^{
            
            [self addVideoView];
            
            if (_externalErrorView && _externalErrorView.superview) {
                [_externalErrorView removeFromSuperview];
            }
            if (_externalCompleteView && _externalCompleteView.superview) {
                [_externalCompleteView removeFromSuperview];
            }
            
            [self removeExternBackView];
        }];
 
        [NSObject asyncTaskOnMainWithBlock:^{
            self.controlBarModel.durationTime = videoInfo.videoDurationInMS / 1000; //设置文件时长
        }];
        
        __weak typeof(self) weakSelf = self;
        
        [videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            
            __strong typeof(weakSelf) self = weakSelf;
            
            if (executed) {
 
                //自动隐藏
                [self startAutoHideControlTimer];
            }
        }];
    }
    else
    {
        //加载完成回调
        if (_sourceManager.playerStatusSource.openCompletedBlock) {
            _sourceManager.playerStatusSource.openCompletedBlock(nil);
        }
        
        NSLog(@"文件打开错误");
    }
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
  playCompletedWithType:(PKVideoPlayCompletionType)type
                  error:(NSError *)error
{
    switch (type)
    {
        case kVideoPlayCompletionTypeEOF:
        {
            if (_externalCompleteView && !videoPlayerCore.isSwitching) {
                
                [self addExternBackView];
                [self.view addSubview:_externalCompleteView];
                [self addContraintsOnView:_externalCompleteView];
                
                //播放完成回调
                if (_sourceManager.playerStatusSource.playCompletedBlock) {
                    _sourceManager.playerStatusSource.playCompletedBlock(videoPlayerCore.videoInfo);
                }
            }
            
            break;
        }
        case kVideoPlayCompletionTypeClosed:
        {
            //手动关闭不显示
            break;
        }
        case kVideoPlayCompletionTypeError:
        {
            if (_externalErrorView && !videoPlayerCore.isSwitching) {
                
                [self addExternBackView];
                [self.view addSubview:_externalErrorView];
                [self addContraintsOnView:_externalErrorView];
                
                //播放完成回调
                if (_sourceManager.playerStatusSource.playCompletedBlock) {
                    _sourceManager.playerStatusSource.playCompletedBlock(videoPlayerCore.videoInfo);
                }
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [self removeVideoView];
    
    //结束播放通知
    [self postFinishPlayingNotification];
    
    NSLog(@"轻量级播放器>>>>>>>>>>>>> 播放完成");
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
     playPositionUpdate:(NSInteger)timeInMS
{
    if (_isProcessChangeing) //seek过程中，停止更新UI
    {
        return;
    }
    
    [NSObject asyncTaskOnMainWithBlock:^{
        NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
        CGFloat process = (durationInMS == 0.0) ?: (CGFloat)timeInMS/durationInMS;
        self.controlBarModel.playProcess = process;
        self.controlBarModel.playTime = timeInMS / 1000;
    }];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferPositionUpdate:(NSInteger)timeInMS
{
    [NSObject asyncTaskOnMainWithBlock:^{
        NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
        CGFloat bufferProcess = (durationInMS == 0.0) ?: (CGFloat)timeInMS/durationInMS;
        self.controlBarModel.bufferProcess = bufferProcess;
    } delay:.3];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferProgressUpdate:(CGFloat)progressInPercent
{
    NSInteger state = kVideoControlBarPlay;
    
    if (progressInPercent < 1.0)
    {
        state = (self.videoPlayerCore.isPaused ? kVideoControlBarPlay : kVideoControlBarBuffering);
    }
    else
    {
        state = (self.videoPlayerCore.isPaused ?  kVideoControlBarPlay : kVideoControlBarPause);
    }
    
    if (self.controlBarModel.playState != state && !self.videoPlayerCore.isSwitching)
    {
        [NSObject asyncTaskOnMainWithBlock:^{
            self.controlBarModel.playState = state;
        }];
    }
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
 seekCompletedWithError:(NSError *)error
{
    NSLog(@"轻量级播放器>>>>>>>>>>>>> seek完成");
    _isProcessChangeing = NO;

    //开始自动隐藏
    [self startAutoHideControlTimer];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
    downloadSpeedUpdate:(long long)downloadSpeedInBytes
{

}

#pragma mark -- <PKControlBarEventProtocol>
//播放按键点击事件
- (void)videoControlBarPlayBtnClicked:(id<PKControlBarProtocol>) controlBar
{
    if (!_videoPlayerCore.isPaused)
    {
        [self switchPlayStateToPause:YES];
    }
    else
    {
        [self switchPlayStateToPause:NO];
    }
}

//进度值开始改变
- (void)videoControlBarProcessWillChange:(id<PKControlBarProtocol>)controlBar
{
    //停止更新UI
    _isProcessChangeing = YES;
    
    //停止自动隐藏
    [self stopAutoHideControlTimer];
}

//进度值改变完成
- (void)videoControlBar:(id<PKControlBarProtocol>)controlBar processValueDidChange:(CGFloat)process
{
    //播放核执行操作
    [self.videoPlayerCore seekWithProgress:process];
}

//全屏按键点击事件
- (void)videoControlBarFullScreenBtnClicked:(id<PKControlBarProtocol>)controlBar
{
    if (_sourceManager.playerStatusSource.screenSizeSwitchBlock)
    {
        _sourceManager.playerStatusSource.screenSizeSwitchBlock();
    }
    
    NSLog(@"控制栏更换完毕");
}

//屏幕点击事件
- (void)videoControlBarTapClicked:(id<PKControlBarProtocol>)controlBar
{
    self.controlBarModel.controlBarHidden = !_controlBarModel.controlBarHidden;
    
    if (_controlBarModel.controlBarHidden) //隐藏后停止自动隐藏计时器
    {
        [self stopAutoHideControlTimer];
    }
    else //显示时开始自动隐藏计时器
    {
        [self startAutoHideControlTimer];
    }
}

//音量改变事件
- (void)videoControlBarVolumeChange:(BOOL)isIncrease percent:(CGFloat)percent
{
    if (isIncrease)
    {
        [[PKLightVideoVolumeManager shareInstance] increaseVolume:percent];
    }
    else
    {
        [[PKLightVideoVolumeManager shareInstance] decreaseVolume:percent];
    }
}

//亮度改变事件
- (void)videoControlBarBrightnessChange:(BOOL)isIncrease percent:(CGFloat)percent
{
    if (isIncrease)
    {
        [UIScreen mainScreen].brightness += percent;
    }
    else
    {
        [UIScreen mainScreen].brightness -= percent;
    }
}

@end