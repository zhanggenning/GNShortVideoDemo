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

@interface PKLightVideoPlayerViewController () <PKVideoPlayerCoreDelegate, PKControlBarEventProtocol>
{
    BOOL _isPlayerCoreLoaded; //播放核加载
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
    
    [self unloadVideoPlayerCore];
    
    [self.videoPlayerCore close];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSLog(@"页面释放.....");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //装载播放核
    [self loadVideoPlayerCore];
    
    //装载控制条
    [self loadVideoControlBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //刷新标题
    if (_sourceManager.titleSource.titleBlock)
    {
        self.controlBarModel.mainTitle = _sourceManager.titleSource.titleBlock();
    }
        
    //同步状态
    if (!_videoPlayerCore.isReadyForPlaying)
    {
        self.controlBarModel.playState = kVideoControlBarBuffering;
    }
        
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
    self.videoPlayerCore.videoView.hidden = YES;
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
- (void)loadVideoPlayerCore
{
    if (!_isPlayerCoreLoaded && _videoPlayerCore)
    {
        _videoPlayerCore.videoView.translatesAutoresizingMaskIntoConstraints = NO;
        
        //添加videoView
        [self.view insertSubview:_videoPlayerCore.videoView atIndex:0];
        
        [self addContraintsOnView:_videoPlayerCore.videoView];
 
        //设置delegate
        _videoPlayerCore.delegate = self;
        
        _isPlayerCoreLoaded = YES;
    }
}

- (void)unloadVideoPlayerCore
{
    if (_isPlayerCoreLoaded && _videoPlayerCore)
    {
        //移除videoView
        [_videoPlayerCore.videoView removeFromSuperview];
        
        //移除delegate
        _videoPlayerCore.delegate = nil;
        
        _isPlayerCoreLoaded = NO;
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
        //开始播放通知
        [self postStartPlayingNotification];
        
        [NSObject syncTaskOnMainWithBlock:^{
            self.videoPlayerCore.videoView.hidden = NO;
            
            if (_externalErrorView && _externalErrorView.superview) {
                [_externalErrorView removeFromSuperview];
            }
            if (_externalCompleteView && _externalCompleteView.superview) {
                [_externalCompleteView removeFromSuperview];
            }
        }];
 
        
        __weak typeof(self) weakSelf = self;
        
        [videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            
            __strong typeof(weakSelf) self = weakSelf;
            
            if (executed) {
                [NSObject asyncTaskOnMainWithBlock:^{
                    self.controlBarModel.playState = kVideoControlBarPause; //播放时，换成暂停的图片
                    self.controlBarModel.durationTime = videoInfo.videoDurationInMS / 1000; //设置文件时长
                }];
                
                //自动隐藏
                [self startAutoHideControlTimer];
            }
        }];
    }
    else
    {
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
                [self.view addSubview:_externalCompleteView];
                [self addContraintsOnView:_externalCompleteView];
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
                [self.view addSubview:_externalErrorView];
                [self addContraintsOnView:_externalErrorView];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    self.videoPlayerCore.videoView.hidden = YES;
    
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
    
    [NSObject asyncTaskOnMainWithBlock:^{
        self.controlBarModel.playState = state;
    }];
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

@end