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
@interface PKLightVideoControlBar() <PKLightVideoPlayerSliderProtocol>

@property (nonatomic, strong) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLab;
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *processSlider;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end


@implementation PKLightVideoControlBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.processSlider.delegate = self;
}

#pragma mark -- 公共
+ (id<PKControlBarProtocol>)nibInstance
{
    NSBundle *bundle = [NSBundle pkBundle];
    
    PKLightVideoControlBar *controlBar = [[bundle loadNibNamed:NSStringFromClass([self class])
                                                         owner:nil
                                                       options:nil] firstObject];
    controlBar.backgroundColor = [UIColor clearColor];
    
    return controlBar;
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

#pragma mark -- 协议
#pragma mark ---- <PKControlBarProtocol>
- (void)setControlBarDelegate:(id)vc
{
    self.delegate = vc;
}

- (void)resetControlBar
{
    [self setControlBarPlayState:kVideoControlBarPlay];
    self.playTimeLab.text = @"00:00";
    self.processSlider.process = 0.0;
    self.processSlider.bufferProcess = 0.0;
    self.durationTimeLab.text = @"00:00";
    [self setControlBarFullState:kVideoControlBarFullScreen];
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
}

- (void)setControlBarBufferProcess:(CGFloat)bufferProcess
{
    self.processSlider.bufferProcess = bufferProcess;
}

- (void)setControlBarPlayTime:(NSInteger)time
{
    self.playTimeLab.text = [self formatTimeWithSecond:time];
}

- (void)setControlBarDurationTime:(NSInteger)time
{
    self.durationTimeLab.text = [self formatTimeWithSecond:time];
}

- (void)setControlBarFullState:(PKVideoControlFullScreenState)state
{
    switch (state)
    {
        case kVideoControlBarFullScreen:
        {
            [_fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
            break;
        }
        case kVideoControlBarNormal:
        {
            [_fullScreenBtn setTitle:@"普通" forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

#pragma mark -- <PKLightVideoPlayerSliderProtocol>
- (void)PKLightPlayerSlider:(PKLightVideoPlayerSlider *)slider progressChanged:(CGFloat)process
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBar:processValueChanged:)])
    {
        [_delegate videoControlBar:self processValueChanged:process];
    }
}

@end
