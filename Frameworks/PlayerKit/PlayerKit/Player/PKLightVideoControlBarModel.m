//
//  PKLightVideoControlBarModel.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/20.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoControlBarModel.h"

@interface PKLightVideoControlBarModel ()

@property (nonatomic, weak) id<PKControlBarProtocol>controlBar;

@end

@implementation PKLightVideoControlBarModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userInteractive = YES;
    }
    return self;
}

#pragma mark -- 私有API
/**
 *  根据控制栏样式，获取相应的view的class字符串
 *
 *  @param controlBarStyle 控制栏样式
 */
- (NSString *)viewClassStrByStyle:(PKVideoControlBarStyle)controlBarStyle
{
    NSString *viewClassStr = @"";
    
    switch (controlBarStyle)
    {
        case kVideoControlBarBase:
        {
            viewClassStr = @"PKLightVideoControlBar";
            break;
        }
        case kVideoControlBarFull:
        {
            viewClassStr = @"PKLightVideoFullScreenControlBar";
            break;
        }
        default:
            break;
    }
    
    return viewClassStr;
}


/**
 *  切换控制栏样式时同步当前状态
 */
- (void)syncControlBarInfo
{
    self.delegate = _delegate;
    self.playState = _playState;
    self.playProcess = _playProcess;
    self.bufferProcess = _bufferProcess;
    self.playTime = _playTime;
    self.durationTime = _durationTime;
    self.mainTitle = _mainTitle;
    self.volume = _volume;
    self.brightness = _brightness;
    self.userInteractive = _userInteractive;
}

#pragma mark -- 属性
-(id<PKControlBarProtocol>)controlBar
{
    if (!_controlBar)
    {
        NSString *viewClassStr = [self viewClassStrByStyle:_controlBarStyle];
        
        Class class = NSClassFromString(viewClassStr);
        
        NSAssert(class != nil, @"Class 必须存在");
        
        if ([class conformsToProtocol:@protocol(PKControlBarProtocol)])
        {
            _controlBar = [class nibInstance];
            
            //同步信息
            [self syncControlBarInfo];
        }
        else
        {
            NSAssert(NO, @"class [%@] 必须遵循 <PKControlBarProtocol> 协议", NSStringFromClass(class));
        }
    }
    return _controlBar;
}

//controlBar
- (UIView *)controlBarView
{
    return (UIView *)self.controlBar;
}

//代理
- (void)setDelegate:(id<PKControlBarEventProtocol>)delegate
{
    _delegate = delegate;
    
    //设置到相应的congtrol bar
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarDelegate:)])
    {
        [self.controlBar setControlBarDelegate:delegate];
    }
}

//风格
- (void)setControlBarStyle:(PKVideoControlBarStyle)controlBarStyle
{
    _controlBarStyle = controlBarStyle;
    
    if (self.controlBarView.superview)
    {
        [self.controlBarView removeFromSuperview];
    }
    self.controlBar = nil;
}

//隐藏
- (void)setControlBarHidden:(BOOL)controlBarHidden
{
    _controlBarHidden = controlBarHidden;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarHidden:)])
    {
        [self.controlBar setControlBarHidden:controlBarHidden];
    }
}

//播放图片
- (void)setPlayState:(PKVideoControlBarPlayState)playState
{
    _playState = playState;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarPlayState:)])
    {
        [self.controlBar setControlBarPlayState:kVideoControlBarBuffering];
    }
}

//播放进度
- (void)setPlayProcess:(CGFloat)playProcess
{
    _playProcess = playProcess;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarPlayProcess:)])
    {
        [self.controlBar setControlBarPlayProcess:playProcess];
    }
}

//缓冲进度
- (void)setBufferProcess:(CGFloat)bufferProcess
{
    _bufferProcess = bufferProcess;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarBufferProcess:)])
    {
        [self.controlBar setControlBarBufferProcess:bufferProcess];
    }
}

//播放时间
- (void)setPlayTime:(CGFloat)playTime
{
    _playTime = playTime;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarPlayTime:)])
    {
        [self.controlBar setControlBarPlayTime:playTime];
    }
}

//文件时长
- (void)setDurationTime:(CGFloat)durationTime
{
    _durationTime = durationTime;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarDurationTime:)])
    {
        [self.controlBar setControlBarDurationTime:durationTime];
    }
}

//主标题
- (void)setMainTitle:(NSString *)mainTitle
{
    _mainTitle = mainTitle;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarMainTitle:)])
    {
        [self.controlBar setControlBarMainTitle:mainTitle];
    }
}

//主标题隐藏
- (void)setMainTitleHidden:(BOOL)mainTitleHidden
{
    _mainTitleHidden = mainTitleHidden;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarMainTitleHidden:)])
    {
        [self.controlBar setControlBarMainTitleHidden:mainTitleHidden];
    }
}

//音量
- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarVolumeProcess:)]) {
        [self.controlBar setControlBarVolumeProcess:volume];
    }
}

//亮度
- (void)setBrightness:(CGFloat)brightness
{
    _brightness = brightness;
    
    if (self.controlBar && [self.controlBar respondsToSelector:@selector(setControlBarBrightnessProcess:)]) {
        [self.controlBar setControlBarBrightnessProcess:brightness];
    }
}

- (void)setUserInteractive:(BOOL)userInteractive
{
    if (self.controlBar && [self.controlBar isKindOfClass:[UIView class]])
    {
        ((UIView *)self.controlBar).userInteractionEnabled = userInteractive;
    }
    
    _userInteractive = userInteractive;
}

@end
