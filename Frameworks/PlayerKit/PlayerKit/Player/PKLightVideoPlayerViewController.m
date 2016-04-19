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
#import "PKLightVideoPlayerSlider.h"

#import "PKLightVideoControlBar.h"

@interface PKLightVideoPlayerViewController () <PKVideoPlayerCoreDelegate, PKControlBarEventProtocol>
{
    BOOL _isPlayerCoreLoaded; //播放核加载
    BOOL _isContorlBarLoaded; //控制条加载
    BOOL _isProcessChangeing; //进度改变中
}

@property (weak, nonatomic) id <PKControlBarProtocol> controlBar;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation PKLightVideoPlayerViewController

- (void)dealloc
{
    [self unloadVideoControlBar];
    
    [self unloadVideoPlayerCore];
    
    [self.videoPlayerCore close];
    
    NSLog(@"页面释放.....");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //装载播放核
    [self loadVideoPlayerCore];
    
    //装载控制条
    [self loadVideoControlBar];
    
    //同步状态
    if (!_videoPlayerCore.isReadyForPlaying)
    {
        if ([_controlBar respondsToSelector:@selector(setControlBarPlayState:)])
        {
            [_controlBar setControlBarPlayState:kVideoControlBarBuffering];
        }
    }
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

#pragma mark -- 私有API
- (void)loadVideoControlBar
{
    if (!_isContorlBarLoaded)
    {
        [self.controlBar setControlBarDelegate:self];
        
        [self.view insertSubview:(UIView *)self.controlBar atIndex:1];
        
        [self addContraintsOnView:(UIView *)self.controlBar];
        
        _isContorlBarLoaded = YES;
    }
}

- (void)unloadVideoControlBar
{
    if (_isContorlBarLoaded)
    {
        [self.controlBar setControlBarDelegate:nil];
        
        [(UIView *)self.controlBar removeFromSuperview];
        
        _isContorlBarLoaded = NO;
    }
}

- (void)addContraintsOnView:(UIView *)view
{
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


#pragma mark -- 属性
- (id<PKControlBarProtocol>)controlBar
{
    if (!_controlBar)
    {
        _controlBar = [PKLightVideoControlBar nibInstance];
    }
    return _controlBar;
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
        [videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            if (executed) {
                [NSObject asyncTaskOnMainWithBlock:^{
                    if ([self.controlBar respondsToSelector:@selector(setControlBarPlayState:)])
                    {
                        [self.controlBar setControlBarPlayState:kVideoControlBarPause]; //播放时，换成暂停的图片
                    }
                    if ([self.controlBar respondsToSelector:@selector(setControlBarDurationTime:)])
                    {
                        [self.controlBar setControlBarDurationTime:videoInfo.videoDurationInMS / 1000]; //设置文件时长
                    }
                }];
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
    //播放完成可能需要另外一套UI,这里先重置，等需求
    if ([_controlBar respondsToSelector:@selector(resetControlBar)])
    {
        [_controlBar resetControlBar];
    }
    
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
        if ([_controlBar respondsToSelector:@selector(setControlBarPlayProcess:)])
        {
            [_controlBar setControlBarPlayProcess:process];
        }
        if ([_controlBar respondsToSelector:@selector(setControlBarPlayTime:)])
        {
            [_controlBar setControlBarPlayTime:timeInMS / 1000];
        }
    }];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferPositionUpdate:(NSInteger)timeInMS
{
    [NSObject asyncTaskOnMainWithBlock:^{
        NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
        CGFloat bufferProcess = (durationInMS == 0.0) ?: (CGFloat)timeInMS/durationInMS;
        if ([_controlBar respondsToSelector:@selector(setControlBarBufferProcess:)])
        {
            [_controlBar setControlBarBufferProcess:bufferProcess];
        }
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
        if ([_controlBar respondsToSelector:@selector(setControlBarPlayState:)])
        {
            [_controlBar setControlBarPlayState:state];
        }
    }];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
 seekCompletedWithError:(NSError *)error
{
    NSLog(@"轻量级播放器>>>>>>>>>>>>> seek完成");
    _isProcessChangeing = NO;
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
        [self.videoPlayerCore pauseWithExecutionHandler:^(BOOL executed) {
            if (executed)
            {
                [NSObject asyncTaskOnMainWithBlock:^{
                    if ([controlBar respondsToSelector:@selector(setControlBarPlayState:)])
                    {
                        [controlBar setControlBarPlayState:kVideoControlBarPlay]; //暂停后，换成播放的图片
                    }
                }];
            }
        }];
    }
    else
    {
        [self.videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            if (executed)
            {
                [NSObject asyncTaskOnMainWithBlock:^{
                    if ([controlBar respondsToSelector:@selector(setControlBarPlayState:)])
                    {
                        [controlBar setControlBarPlayState:kVideoControlBarPause]; //暂停后，换成播放的图片
                    }
                }];
            }
        }];
    }
}

//进度值改变完成
- (void)videoControlBar:(id<PKControlBarProtocol>)controlBar processValueChanged:(CGFloat)process
{
    //停止更新UI
    _isProcessChangeing = YES;
    
    //播放核执行操作
    [self.videoPlayerCore seekWithProgress:process];
}

//全屏按键点击事件
- (void)videoControlBarFullScreenBtnClicked:(id<PKControlBarProtocol>)controlBar
{
    
}

@end
