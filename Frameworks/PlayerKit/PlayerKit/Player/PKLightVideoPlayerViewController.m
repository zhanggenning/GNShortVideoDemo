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
#import "PKStatisticSource.h"

@interface PKLightVideoPlayerViewController () <PKVideoPlayerCoreDelegate, PKControlBarEventProtocol>
{
    BOOL _isContorlBarLoaded; //控制条加载
    BOOL _isProcessChangeing; //进度改变中
    BOOL _isPlayerUIInited;   //界面初始化
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
    
    //播放结束统计
    if (_sourceManager.statisticSource.stopPlayingStatisticBlock)
    {
        NSTimeInterval playTime = [self.videoPlayerCore timeIntervalSinceStartPlaying];
        _sourceManager.statisticSource.stopPlayingStatisticBlock(kPlayEndByUser,
                                                                 playTime,
                                                                 _videoPlayerCore.videoInfo,
                                                                 nil);
    }

    NSLog(@"页面释放.....");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //装载控制条
    [self loadVideoControlBar];
    
    //外部背景
    [self addExternBackViewBelowControlBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
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
    if (_videoPlayerCore.videoPlayerCoreState == kVideoPlayerCoreStateOpening && !_isStartSwitch)
    {
        self.controlBarModel.playState = kVideoControlBarBuffering;
        self.controlBarModel.controlBarView.userInteractionEnabled = NO;
        [self addExternBackViewBelowControlBar];
    }
}

- (void)viewDidLayoutSubviews
{
    if (_videoPlayerCore.videoView.superview == self.view &&
        !CGRectEqualToRect(_videoPlayerCore.videoView.frame, self.view.bounds))
    {
        [_videoPlayerCore setVideoViewSize:self.view.bounds.size];
    }
    
    if (_controlBarModel.controlBarView &&
        !CGRectEqualToRect(_controlBarModel.controlBarView.frame, self.view.bounds))
    {
        _controlBarModel.controlBarView.frame = self.view.bounds;
    }
    
    if (_externalBackView && !CGRectEqualToRect(_externalBackView.frame, self.view.bounds))
    {
        _externalBackView.frame = self.view.bounds;
    }
    
    if (_externalErrorView && !CGRectEqualToRect(_externalErrorView.frame, self.view.bounds))
    {
        _externalErrorView.frame = self.view.bounds;
    }
    
    if (_externalCompleteView && !CGRectEqualToRect(_externalCompleteView.frame, self.view.bounds))
    {
        _externalCompleteView.frame = self.view.bounds;
    }
    
    //调整层级
    if (_externalErrorView.superview && [_externalErrorView.superview.subviews lastObject] != _externalErrorView)
    {
        [_externalErrorView.superview bringSubviewToFront:_externalErrorView];
    }
    if (_externalCompleteView.superview && [_externalCompleteView.superview.subviews lastObject] != _externalCompleteView)
    {
        [_externalCompleteView.superview bringSubviewToFront:_externalCompleteView];
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
    self.controlBarModel.volume = [PKLightVideoVolumeManager shareInstance].volume;
    self.controlBarModel.brightness = [UIScreen mainScreen].brightness;
    [self stopAutoHideControlTimer];
    
    //外部视图
    if (_externalErrorView && _externalErrorView.superview) {
        [_externalErrorView removeFromSuperview];
    }
    if (_externalCompleteView && _externalCompleteView.superview) {
        [_externalCompleteView removeFromSuperview];
    }
    
    //隐藏播放视图
    if (_videoPlayerCore.videoView.superview)
    {
        [_videoPlayerCore.videoView removeFromSuperview];
    }
    
    //等待视频打开完成
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

- (void)seekWithProcess:(CGFloat)process
{
    CGFloat dstProcess = process;
    
    if (process < 0.0)
    {
        dstProcess = 0.0;
    }
    if (process > 1.0)
    {
        dstProcess = 1.0;
    }
    
    if (!_isStartSwitch)
    {
        [_videoPlayerCore seekWithProgress:dstProcess];
    }
}

- (CGFloat)playProcess
{
    if (_controlBarModel)
    {
        return _controlBarModel.playProcess;
    }
    return 0.0;
}

#pragma mark -- 私有API
- (void)addVideoView
{
    if (_videoPlayerCore.videoView.superview)
    {
        [_videoPlayerCore.videoView removeFromSuperview];
    }
    
    _videoPlayerCore.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:_videoPlayerCore.videoView atIndex:0];
    [_videoPlayerCore setVideoViewSize:self.view.bounds.size];
}

- (void)loadVideoControlBar
{
    if (!_isContorlBarLoaded)
    {
        self.controlBarModel.controlBarView.frame = self.view.bounds;
        
        if (self.videoPlayerCore.videoView.superview == self.view)
        {
            [self.view insertSubview:self.controlBarModel.controlBarView aboveSubview:self.controlBarModel.controlBarView];
        }
        else
        {
            [self.view insertSubview:self.controlBarModel.controlBarView atIndex:0];
        }
        
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


- (void)addExternBackViewBelowControlBar
{
    if (_externalBackView && _isContorlBarLoaded) {
        
        if (_externalBackView.superview) {
            [_externalBackView removeFromSuperview];
        }
        
        _externalBackView.frame = self.view.bounds;

        [self.view insertSubview:_externalBackView belowSubview:self.controlBarModel.controlBarView];
    }
}

- (void)addExternBackView
{
    if (_externalBackView) {
        
        if (_externalBackView.superview) {
            [_externalBackView removeFromSuperview];
        }
        
        _externalBackView.frame = self.view.bounds;
        
        [self.view addSubview:_externalBackView];
    }
}

- (void)addExternCompleteView
{
    if (_externalCompleteView)
    {
        if (_externalCompleteView.superview) {
            [_externalCompleteView removeFromSuperview];
        }
        
        _externalCompleteView.frame = self.view.bounds;
        [self.view addSubview:_externalCompleteView];
    }
}

- (void)addExternErrorView
{
    if (_externalErrorView)
    {
        if (_externalErrorView.superview) {
            [_externalErrorView removeFromSuperview];
        }
        
        _externalErrorView.frame = self.view.bounds;
        [self.view addSubview:_externalErrorView];
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
                //开始播放通知
                [self postStartPlayingNotification];
                
                //开始播放回调
                if (self.sourceManager.playerStatusSource.playStartBlock) {
                    self.sourceManager.playerStatusSource.playStartBlock(self.videoPlayerCore.videoInfo);
                }
                
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
        self.hiddenControlBar = NO;
        
        //隐藏声音
        if (controlBarStyle == kVideoControlBarBase)
        {
            [[PKLightVideoVolumeManager shareInstance].volumeView removeFromSuperview];
        }
        else
        {
            //注：音量视图一定要在当前视图层级才能隐藏
            [self.view addSubview:[PKLightVideoVolumeManager shareInstance].volumeView];
        }
        
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

- (void)setHiddenControlBar:(BOOL)hiddenControlBar
{
    _hiddenControlBar = hiddenControlBar;
    
    _controlBarModel.controlBarHidden = hiddenControlBar;
        
    if (hiddenControlBar)
    {
        [self stopAutoHideControlTimer];
    }
    else
    {
        [self startAutoHideControlTimer];
    }
}

- (void)setHiddenMainTitle:(BOOL)hiddenMainTitle
{
    _hiddenMainTitle = hiddenMainTitle;
    
    _controlBarModel.mainTitleHidden = hiddenMainTitle;
}

- (void)setIsStartSwitch:(BOOL)isStartSwitch
{
    if (isStartSwitch)
    {
        self.controlBarModel.playState = kVideoControlBarBuffering;
        self.controlBarModel.controlBarView.userInteractionEnabled = NO;
        [self addExternBackViewBelowControlBar];
        _isStartSwitch = isStartSwitch;
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
    
    _isStartSwitch = NO;
    
    if (isReadyForPlaying)
    {
        self.controlBarModel.controlBarView.userInteractionEnabled = YES;
        
        //加载完成回调
        if (_sourceManager.playerStatusSource.openCompletedBlock) {
            _sourceManager.playerStatusSource.openCompletedBlock(videoInfo);
        }
        
        if (_sourceManager.statisticSource.startPlayingStatisticBlock)
        {
            _sourceManager.statisticSource.startPlayingStatisticBlock(videoInfo);
        }
        
        
        [NSObject asyncTaskOnMainWithBlock:^{
            
            [self addVideoView];
            
            if (_externalErrorView && _externalErrorView.superview) {
                [_externalErrorView removeFromSuperview];
            }
            if (_externalCompleteView && _externalCompleteView.superview) {
                [_externalCompleteView removeFromSuperview];
            }
            
            if (_externalBackView && _externalBackView.superview) {
                [_externalBackView removeFromSuperview];
            }
            
            self.controlBarModel.durationTime = videoInfo.videoDurationInMS / 1000; //设置文件时长
        }];
        
        __weak typeof(self) weakSelf = self;
        
        [videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            
            __strong typeof(weakSelf) self = weakSelf;
            
            if (executed) {
 
                //开始播放通知
                [self postStartPlayingNotification];
                
                //开始播放回调
                if (self.sourceManager.playerStatusSource.playStartBlock) {
                    self.sourceManager.playerStatusSource.playStartBlock(videoInfo);
                }
                
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
    //播放完成移除
    [_videoPlayerCore.videoView removeFromSuperview];
    
    switch (type)
    {
        case kVideoPlayCompletionTypeEOF:
        {
            if (_externalErrorView
                && !videoPlayerCore.isSwitching)
            {
                //添加外部视图
                [self addExternBackView];
                [self addExternCompleteView];
                
                //更换播放图标
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.controlBarModel.playState = kVideoControlBarPlay;
                    [self stopAutoHideControlTimer];
                });
            }
            
            if (_sourceManager.statisticSource.stopPlayingStatisticBlock)
            {
                NSTimeInterval playTime = [self.videoPlayerCore timeIntervalSinceStartPlaying];
                _sourceManager.statisticSource.stopPlayingStatisticBlock(kPlayEndByComplete,
                                                                     playTime,
                                                                     videoPlayerCore.videoInfo,
                                                                     error);
            }
            break;
        }
        case kVideoPlayCompletionTypeError:
        {
            //添加外部视图
            if (_externalErrorView
                && !videoPlayerCore.isSwitching)
            {
                [self addExternBackView];
                [self addExternErrorView];
                
                //更换播放图标
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.controlBarModel.playState = kVideoControlBarPlay;
                    [self stopAutoHideControlTimer];
                });
            }
            
            if (_sourceManager.statisticSource.stopPlayingStatisticBlock)
            {
                NSTimeInterval playTime = [self.videoPlayerCore timeIntervalSinceStartPlaying];
                _sourceManager.statisticSource.stopPlayingStatisticBlock(kPlayEndByFail,
                                                                         playTime,
                                                                         videoPlayerCore.videoInfo,
                                                                         error);
            }
            
            break;
        }
        case kVideoPlayCompletionTypeClosed:
        {
            if (_sourceManager.statisticSource.stopPlayingStatisticBlock)
            {
                //播放结束统计
                NSTimeInterval playTime = [self.videoPlayerCore timeIntervalSinceStartPlaying];
                _sourceManager.statisticSource.stopPlayingStatisticBlock(kPlayEndByUser,
                                                                         playTime,
                                                                         _videoPlayerCore.videoInfo,
                                                                         nil);
            }
            break;
        }
        default:
            break;
    }
    
    //播放完成回调
    if (_sourceManager.playerStatusSource.playCompletedBlock) {
        _sourceManager.playerStatusSource.playCompletedBlock(videoPlayerCore.videoInfo);
    }
    
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
    
    if (!_isStartSwitch)
    {
        [NSObject asyncTaskOnMainWithBlock:^{
            NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
            CGFloat process = (durationInMS == 0.0) ?: (CGFloat)timeInMS/durationInMS;
            self.controlBarModel.playProcess = process;
            self.controlBarModel.playTime = timeInMS / 1000;
        }];
    }
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferPositionUpdate:(NSInteger)timeInMS
{
    if (!_isStartSwitch)
    {
        [NSObject asyncTaskOnMainWithBlock:^{
            NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
            CGFloat bufferProcess = (durationInMS == 0.0) ?: (CGFloat)timeInMS/durationInMS;
            
            if (bufferProcess > 0.95) //取整一下
            {
                bufferProcess = 1.0;
            }
            
            self.controlBarModel.bufferProcess = bufferProcess;
        }];
    }
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
    BOOL state = NO;
    
    if (!_videoPlayerCore.isPaused)
    {
        state = YES;
    }
    else
    {
        state = NO;
    }
    
    [self switchPlayStateToPause:state];
    
    if (_sourceManager.statisticSource.userPauseStatisticBlock)
    {
        _sourceManager.statisticSource.userPauseStatisticBlock(state);
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