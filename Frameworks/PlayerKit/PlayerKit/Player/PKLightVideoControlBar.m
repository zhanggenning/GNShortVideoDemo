//
//  PKLightVideoControlBar.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/19.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoControlBar.h"
#import "PKLightVideoPlayerSlider.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"
#import "TWeakTimer.h"

@interface PKLightVideoControlBar() <PKLightVideoPlayerSliderProtocol, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *controlBarWrapView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLab;
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *processSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *bottomProcessSlider;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;

@end


@implementation PKLightVideoControlBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.controlBarWrapView.backgroundColor = [UIColor clearColor];
    self.processSlider.delegate = self;
    self.bottomProcessSlider.thumbHidden = YES;
    
    //点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

#pragma mark -- 私有
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

#pragma mark -- 事件
- (IBAction)playBtnAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarPlayBtnClicked:)]) {
        [_delegate videoControlBarPlayBtnClicked:self];
    }
}

- (IBAction)fullScreenBtnAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarFullScreenBtnClicked:)]) {
        [_delegate videoControlBarFullScreenBtnClicked:self];
    }
}

- (void)tapAction:(UIGestureRecognizer *)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarTapClicked:)]) {
        [_delegate videoControlBarTapClicked:self];
    }
}

#pragma mark -- 协议
#pragma mark ---- <PKControlBarProtocol>
+ (id<PKControlBarProtocol>)nibInstance
{
    NSBundle *bundle = [NSBundle pkBundle];
    
    PKLightVideoControlBar *controlBar = [[bundle loadNibNamed:NSStringFromClass([self class])
                                                         owner:nil
                                                       options:nil] firstObject];

    return controlBar;
}

- (void)setControlBarDelegate:(id)vc
{
    self.delegate = vc;
}

- (void)setControlBarHidden:(BOOL)isHidden
{
    if (isHidden)
    {
        self.controlBarWrapView.hidden = YES;
        self.bottomProcessSlider.hidden = NO;
    }
    else
    {
        self.controlBarWrapView.hidden = NO;
        self.bottomProcessSlider.hidden = YES;
    }
}

- (void)setControlBarPlayState:(PKVideoControlBarPlayState)state
{
    switch (state)
    {
        case kVideoControlBarPlay:
        {
            self.playBtn.hidden = NO;
            [_indicatorView stopAnimating];
            
            [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_play_btn_n.png"]
                                    forState:UIControlStateNormal];
            [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_play_btn_n.png"]
                                    forState:UIControlStateHighlighted];

            break;
        }
        case kVideoControlBarPause:
        {
            self.playBtn.hidden = NO;
            [_indicatorView stopAnimating];
            
            [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_pause_btn_n.png"]
                                    forState:UIControlStateNormal];
            [self.playBtn setBackgroundImage:[UIImage imageInPKBundleWithName:@"pk_pause_btn_n.png"]
                                    forState:UIControlStateHighlighted];

            break;
        }
        case kVideoControlBarBuffering:
        {
            self.playBtn.hidden = YES;
            [_indicatorView startAnimating];

            break;
        }
            
        default:
            break;
    }
}

- (void)setControlBarPlayProcess:(CGFloat)process
{
    self.processSlider.process = process;
    self.bottomProcessSlider.process = process;
}

- (void)setControlBarBufferProcess:(CGFloat)bufferProcess
{
    self.processSlider.bufferProcess = bufferProcess;
    self.bottomProcessSlider.bufferProcess = bufferProcess;
}

- (void)setControlBarPlayTime:(NSInteger)time
{
    self.playTimeLab.text = [self formatTimeWithSecond:time];
}

- (void)setControlBarDurationTime:(NSInteger)time
{
    self.durationTimeLab.text = [self formatTimeWithSecond:time];
}

- (void)setControlBarMainTitle:(NSString *)title
{
    self.mainTitle.text = title ?: @"";
}

#pragma mark -- <PKLightVideoPlayerSliderProtocol>
- (void)PKLightPlayerSlider:(PKLightVideoPlayerSlider *)slider progressWillChange:(CGFloat)process
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarProcessWillChange:)])
    {
        [_delegate videoControlBarProcessWillChange:self];
    }
}

- (void)PKLightPlayerSlider:(PKLightVideoPlayerSlider *)slider progressDidChange:(CGFloat)process
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBar:processValueDidChange:)])
    {
        [_delegate videoControlBar:self processValueDidChange:process];
    }
}

#pragma mark -- <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self.controlBarWrapView && touch.view != self)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
