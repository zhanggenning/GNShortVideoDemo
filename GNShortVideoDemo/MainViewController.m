//
//  MainViewController.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/16.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "MainViewController.h"
#import "PlayerKit.h"
#import "PKPlayerStatusSource.h"
#import "PKSourceManager.h"

static NSString * const kTestUrl1 = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";
static NSString * const kTestUrl2 = @"http://flv2.bn.netease.com/videolib3/1604/27/gkYRt8042/SD/gkYRt8042-mobile.mp4";

@interface MainViewController ()

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) CGRect initFrame;
@property (nonatomic, strong) UIViewController *player;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (!_player) {
        [self initPlayStateSource];
        _player = [[PKPlayerManager sharedManager] lightPlayerWithVideoUrl:kTestUrl2 completeView:nil errorView:nil backView:nil];
     
    }

    _player.view.frame = CGRectMake(0, 0, 300, 200);
    _player.view.center = self.view.center;
    [self addChildViewController:_player];
    [self.view addSubview:_player.view];
}
- (IBAction)removeAction:(id)sender
{
    if (_player) {
        [_player removeFromParentViewController];
        [_player.view removeFromSuperview];
        _player = nil;
    }
}

- (void)initPlayStateSource
{
    PKPlayerStatusSource *playerStateSource = [[PKPlayerStatusSource alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [playerStateSource setScreenSizeSwitchBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self.isFullScreen) //全屏 -> 普通
        {
            [UIView animateWithDuration:0.3 animations:^{
                _player.view.transform = CGAffineTransformIdentity;
                _player.view.frame = _initFrame;
            } completion:^(BOOL finished) {
                [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarBase];
                self.isFullScreen = NO;
            }];
        }
        else //普通 -> 全屏
        {
            self.initFrame = self.player.view.frame;
            
            [UIView animateWithDuration:0.3 animations:^{
                _player.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                _player.view.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                [[PKPlayerManager sharedManager] lightPlayerSwithchControlBar:kVideoControlBarFull];;
                self.isFullScreen = YES;
            }];
        }
    }];
    
    PKSourceManager *sourceManager = [[PKPlayerManager sharedManager] currentSourceManager];
    sourceManager.playerStatusSource = playerStateSource;
}

@end
