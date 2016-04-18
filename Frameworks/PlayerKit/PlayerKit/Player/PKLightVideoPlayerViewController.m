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
#import "PKVideoPlayerCoreBase.h"
#import "PKVideoInfo.h"
#import "PKSourceManager.h"
#import "PKLightVideoPlayerSlider.h"

@interface PKLightVideoPlayerViewController () <PKVideoPlayerCoreDelegate>
{
    BOOL _isPlayerCoreLoaded; //播放核加载
    BOOL _isVideoLoaded; //视频加载
    PKVideoInfo *_videoInfo;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIView *controlWrapView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *playerSlider;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;

@end

@implementation PKLightVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self loadVideoPlayerCore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 私有API

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
        
        UIView *videoView = _videoPlayerCore.videoView;
        
        //添加videoView
        [self.view insertSubview:_videoPlayerCore.videoView belowSubview:_controlWrapView];
        
        NSArray *contraints1 = [NSLayoutConstraint  constraintsWithVisualFormat:@"H:|-0-[videoView]-0-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(videoView)];
        NSArray *contraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[videoView]-0-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(videoView)];
        [self.view addConstraints:contraints1];
        [self.view addConstraints:contraints2];
        
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
- (void)updatePlayBtnImage:(BOOL)isSwitchToPlayImage
{
    if (isSwitchToPlayImage) //切换成播放的图片
    {
        [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_play_btn_n.png"]
                                    forState:UIControlStateNormal];
        [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_play_btn_n.png"]
                                    forState:UIControlStateHighlighted];
    }
    else //切换成暂停的图片
    {
        [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_pause_btn_n.png"]
                                    forState:UIControlStateNormal];
        [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_pause_btn_n.png"]
                                    forState:UIControlStateHighlighted];
    }
}

//重置控制视图
- (void)resetControlView
{
    self.playerSlider.process = 0.0;
    self.playerSlider.bufferProcess = 0.0;
    self.playTimeLab.text = @"00:00";
    
    [self updatePlayBtnImage:YES];
}

//转换时间格式
- (NSString *)formatTimeWithSecond:(CGFloat)second
{
    static NSDateFormatter *dateFormatter = nil;
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if (second/3600 >= 1)
    {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    else
    {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:d];
    
    return showtimeNew;
}

#pragma mark -- 属性
- (PKLightVideoPlayerSlider *)playerSlider
{
    if (_playerSlider == nil)
    {
        return nil;
    }
    
    //值变化完成回调
    if (_playerSlider.valuedChangedBlock == nil)
    {
        __weak typeof(self) weakSelf = self;
        _playerSlider.valuedChangedBlock = ^(CGFloat process){
            __strong typeof(weakSelf) self = weakSelf;
            [self.videoPlayerCore seekWithProgress:process];
        };
    }
    return _playerSlider;
}

#pragma mark -- 动作
- (IBAction)playBtnAction:(UIButton *)sender
{
    if (!_videoPlayerCore.isPaused)
    {
        [self.videoPlayerCore pauseWithExecutionHandler:^(BOOL executed) {
            if (executed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updatePlayBtnImage:YES]; //暂停后，换成播放的图片
                });
            }
        }];
    }
    else
    {
        [self.videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            if (executed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updatePlayBtnImage:NO]; //暂停后，换成播放的图片
                });
            }
        }];
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
    
    _isVideoLoaded = YES;
    _videoInfo = videoInfo;
    
    [videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
        if (executed) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePlayBtnImage:NO]; //播放时，换成暂停的图片
                _durationLab.text = [self formatTimeWithSecond:videoInfo.videoDurationInMS / 1000]; //设置文件时长
            });
        }
    }];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
 seekCompletedWithError:(NSError *)error
{
    NSLog(@"轻量级播放器>>>>>>>>>>>>> seek完成");
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
  playCompletedWithType:(PKVideoPlayCompletionType)type
                  error:(NSError *)error
{
    switch (type)
    {
        case kVideoPlayCompletionTypeEOF:
        case kVideoPlayCompletionTypeClosed:
        case kVideoPlayCompletionTypeError:
            break;
        default:
            break;
    }
    
    //播放完成可能需要另外一套UI,这里先重置，等需求
    [self resetControlView];
    
    NSLog(@"轻量级播放器>>>>>>>>>>>>> 播放完成");
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
     playPositionUpdate:(NSInteger)timeInMS
{
    if (_isVideoLoaded)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _playTimeLab.text = [self formatTimeWithSecond:timeInMS / 1000];
            self.playerSlider.process = (CGFloat)timeInMS / _videoInfo.videoDurationInMS;
        });
    }
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferProgressUpdate:(CGFloat)progressInPercent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playerSlider.bufferProcess = progressInPercent;
    });
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
    downloadSpeedUpdate:(long long)downloadSpeedInBytes
{

}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferPositionUpdate:(NSInteger)timeInMS
{
    
}


@end
