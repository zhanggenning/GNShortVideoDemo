//
//  PKLightVideoFullScreenControlBar.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/21.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoFullScreenControlBar.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"
#import "UIScreen+pk.h"
#import "PKLightVideoPlayerSlider.h"
#import "PKProgressIndicator.h"
#import "TWeakTimer.h"
#import "NSObject+pk.h"

typedef NS_ENUM(NSInteger,  LightVideoPanMoveDirection) {
    kLightVideoPanMoveNone,
    kLightVideoPanMoveHorizontal,     //水平方向滑动
    kLightVideoPanMoveVerticalLeft,   //左侧垂直方向滑动
    kLightVideoPanMoveVerticalRight,  //右侧垂直方向滑动
};

/// 进度条最小变化步长
static const CGFloat kLeftSliderMinStep = 0.02;
static const CGFloat kRightSliderMinStep = 0.02;

/// 手势相关
static const CGFloat kMaxYDistanceForVPanGesture = 200.0;
static const CGFloat kMaxXDistanceForVPanGesture = 15.0; //手势垂直方向滑动时，水平方向的最大有效偏移
static const CGFloat kMaxYDistanceForHPanGesture = 15.0; //手势水平方向滑动时，垂直方向的最大有效偏移

/// 左右移动seek
static const CGFloat kMaxTimeForHSeekingInSec = 60*5;
static const CGFloat kMinTimeForHSeekingInSec = 0.5;

@interface PKLightVideoFullScreenControlBar () <PKLightVideoPlayerSliderProtocol, UIGestureRecognizerDelegate>
{
    CGPoint _preLocationForPanGesture;
    NSInteger _playTime;
    NSInteger _durationTime;
}

@property (strong, nonatomic) TWeakTimer *autoHideControlTimer;

@property (weak, nonatomic) IBOutlet UIView *controlBarWrapView;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLab;   //主标题控件
@property (weak, nonatomic) IBOutlet UILabel *playTimeLab;    //播放时间控件
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLab; //文件时长控件
@property (weak, nonatomic) IBOutlet UIButton *playBtn;        //播放按钮
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView; //缓冲状态控件
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *processSlider; //播放进度控件
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *bottomProcessSlider; //缓冲进度控件
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *leftProcessSlider;   //声音进度控件
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *rightProcessSlider;  //亮度进度控件
@property (weak, nonatomic) PKProgressIndicator *progressIndicatorView; //手势快进显示控件
@property (weak, nonatomic) IBOutlet UIView *progressIndicatorWrapView;

@end

@implementation PKLightVideoFullScreenControlBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _controlBarWrapView.backgroundColor = [UIColor clearColor];
    _processSlider.delegate = self;
    _bottomProcessSlider.thumbHidden = YES;
    
    //点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

#pragma mark -- 私有
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

//转换时间格式
- (NSString *)formatTimeWithSecond:(NSInteger)second
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

//手势方向
- (LightVideoPanMoveDirection)directionWithTranslation:(CGPoint)translation
{
    if (translation.x > translation.y)
    {
        // 左右移动手势
        return kLightVideoPanMoveHorizontal;
    }
    else
    {
        // 上下移动手势
        if (_preLocationForPanGesture.x < ([UIScreen landscapeScreenBounds].size.width/2))
        {
            return  kLightVideoPanMoveVerticalLeft;
        }
        else
        {
            return  kLightVideoPanMoveVerticalRight;
        }
    }
}

//自动隐藏
- (void)startAutoHideControlTimer
{
    [NSObject asyncTaskOnMainWithBlock:^{
        self.autoHideControlTimer =
        [[TWeakTimer alloc] initWithTimeInterval:2.0
                                          target:self
                                        selector:@selector(autoHiddenAction:)
                                        userInfo:nil
                                         repeats:NO];
    }];
}

- (void)stopAutoHideControlTimer
{
    self.autoHideControlTimer = nil;
}

//左侧进度条改变
- (void)changeLeftSliderProcess:(BOOL)isIncrease
{
    //显示
    self.leftProcessSlider.hidden = NO;
    self.rightProcessSlider.hidden = YES;
    self.progressIndicatorWrapView.hidden = YES;
    
    //进度
    if (isIncrease)
    {
        self.leftProcessSlider.process += kLeftSliderMinStep;
    }
    else
    {
        self.leftProcessSlider.process -= kLeftSliderMinStep;
    }
}

//右侧进度条改变
- (void)changeRightSliderProcess:(BOOL)isIncrease
{
    //显示
    self.leftProcessSlider.hidden = YES;
    self.rightProcessSlider.hidden = NO;
    self.progressIndicatorWrapView.hidden = YES;
    
    //进度
    if (isIncrease)
    {
        self.rightProcessSlider.process += kRightSliderMinStep;
        [UIScreen mainScreen].brightness += kRightSliderMinStep;
    }
    else
    {
        self.rightProcessSlider.process -= kRightSliderMinStep;
        [UIScreen mainScreen].brightness -= kRightSliderMinStep;
    }
}

//进度显示改变
- (void)changeDisplayProgress:(BOOL)isIncrement multiplier:(NSInteger)multiplier
{
    NSInteger displayProgressInSec = self.processSlider.process * _durationTime;
    
    self.leftProcessSlider.hidden = YES;
    self.rightProcessSlider.hidden = YES;
    self.progressIndicatorWrapView.hidden = NO;
    
    if (isIncrement)
    {
        displayProgressInSec += kMinTimeForHSeekingInSec*multiplier;
        displayProgressInSec = (displayProgressInSec > _durationTime) ? _durationTime : displayProgressInSec;
    }
    else
    {
        displayProgressInSec -= kMinTimeForHSeekingInSec*multiplier;
        displayProgressInSec = (displayProgressInSec < 0) ? 0 : displayProgressInSec;
    }

    NSString *timeString = [NSString stringWithFormat:@"%@/%@",
                            [self formatTimeWithSecond:displayProgressInSec],
                            self.durationTimeLab.text];
    
    //停止菊花
    [self.indicatorView stopAnimating];
    
    //显示浮层
    [self.progressIndicatorView showWithDescription:timeString isRewind:!isIncrement];
    
    //同步主控制栏
    self.processSlider.process = (displayProgressInSec == 0) ? 0.0 : (double)displayProgressInSec / _durationTime;
    self.playTimeLab.text = [self formatTimeWithSecond:displayProgressInSec];
}

#pragma mark -- 属性
- (PKProgressIndicator *)progressIndicatorView
{
    if (!_progressIndicatorView)
    {
        _progressIndicatorView = [PKProgressIndicator nibInstance];
        _progressIndicatorWrapView.backgroundColor = [UIColor clearColor];
        [_progressIndicatorWrapView addSubview:_progressIndicatorView];
        [self addContraintsOnView:_progressIndicatorView];
    }
    return _progressIndicatorView;
}

#pragma mark -- 事件
- (IBAction)playBtnAction:(id)sender
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

- (IBAction)backBtnAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarFullScreenBtnClicked:)]) {
        [_delegate videoControlBarFullScreenBtnClicked:self];
    }
}

- (void)autoHiddenAction:(TWeakTimer *)timer
{
    if (!self.leftProcessSlider.isHidden) {
        self.leftProcessSlider.hidden = YES;
    }
    if (!self.rightProcessSlider.isHidden) {
        self.rightProcessSlider.hidden = YES;
    }
    if (!self.progressIndicatorWrapView.isHidden) {
        self.progressIndicatorWrapView.hidden = YES;
    }
}

- (void)tapAction:(UIGestureRecognizer *)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarTapClicked:)]) {
        [_delegate videoControlBarTapClicked:self];
    }
    
    //隐藏附加控制条
    if (self.controlBarWrapView.isHidden)
    {
        if (!self.leftProcessSlider.isHidden)
        {
            self.leftProcessSlider.hidden = YES;
        }
        else if (!self.rightProcessSlider.isHidden)
        {
            self.rightProcessSlider.hidden = YES;
        }
        else if (!self.progressIndicatorWrapView.isHidden)
        {
            self.progressIndicatorWrapView.hidden = YES;
        }
        [self stopAutoHideControlTimer];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)sender
{
    static BOOL valueWillChange;
    static LightVideoPanMoveDirection panMoveDirection;
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _preLocationForPanGesture = [sender locationInView:self];
            panMoveDirection = kLightVideoPanMoveNone;
            valueWillChange = YES;
            [self stopAutoHideControlTimer];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [sender locationInView:self];
            CGFloat xDistance = fabs(location.x - _preLocationForPanGesture.x);
            CGFloat yDistance = fabs(location.y - _preLocationForPanGesture.y);
            
            //判断方向
            if (panMoveDirection == kLightVideoPanMoveNone)
            {
                panMoveDirection = [self directionWithTranslation:CGPointMake(xDistance, yDistance)];
            }

            if (panMoveDirection == kLightVideoPanMoveHorizontal)  /// 左右移动手势
            {
                if (yDistance > kMaxYDistanceForHPanGesture)
                {
                    sender.enabled = NO;
                }
                else
                {
                    if (valueWillChange) //进度即将改变
                    {
                        if (_delegate && [_delegate respondsToSelector:@selector(videoControlBarProcessWillChange:)])
                        {
                            [_delegate videoControlBarProcessWillChange:self];
                        }
                        valueWillChange = NO;
                    }

                    CGFloat screenWidth = [UIScreen landscapeScreenBounds].size.width;
                    if (xDistance >= screenWidth*kMinTimeForHSeekingInSec/kMaxTimeForHSeekingInSec)
                    {
                        NSInteger multiplier = xDistance * kMaxTimeForHSeekingInSec/(screenWidth*kMinTimeForHSeekingInSec);
                        [self changeDisplayProgress:(location.x > _preLocationForPanGesture.x) multiplier:multiplier];
                        _preLocationForPanGesture = location;
                    }
                }
            }
            else if (panMoveDirection == kLightVideoPanMoveVerticalLeft)  /// 亮度调节手势
            {
                if (xDistance > kMaxXDistanceForVPanGesture)
                {
                    sender.enabled = NO;
                }
                else
                {
                    if (yDistance >= kMaxYDistanceForVPanGesture * kRightSliderMinStep)
                    {
                        [self changeRightSliderProcess:(location.y < _preLocationForPanGesture.y)];
                        _preLocationForPanGesture = location;
                    }
                }
            }
            else if (panMoveDirection == kLightVideoPanMoveVerticalRight) /// 声音调节手势
            {
                if (xDistance > kMaxXDistanceForVPanGesture)
                {
                    sender.enabled = NO;
                }
                else
                {
                    if (yDistance >= kMaxYDistanceForVPanGesture * kLeftSliderMinStep)
                    {
                        [self changeLeftSliderProcess:(location.y < _preLocationForPanGesture.y)];
                        _preLocationForPanGesture = location;
                    }
                }
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            
            //进度调节完毕
            if (panMoveDirection == kLightVideoPanMoveHorizontal)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(videoControlBar:processValueDidChange:)])
                {
                    [_delegate videoControlBar:self processValueDidChange:self.processSlider.process];
                }
            }
            
            //重置相关信息
            _preLocationForPanGesture = CGPointZero;
            panMoveDirection = kLightVideoPanMoveNone;
            sender.enabled = YES;
            [self startAutoHideControlTimer];
            break;
        }
        default:
            break;
    }
}


#pragma mark -- 协议
#pragma mark ---- <PKControlBarProtocol>
+ (id<PKControlBarProtocol>)nibInstance
{
    NSBundle *bundle = [NSBundle pkBundle];
    
    PKLightVideoFullScreenControlBar *controlBar = [[bundle loadNibNamed:NSStringFromClass([self class])
                                                         owner:nil
                                                       options:nil] firstObject];
    
    return controlBar;
}

- (void)setControlBarDelegate: (id)vc
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
    _playTime = time;
}

- (void)setControlBarDurationTime:(NSInteger)time
{
    self.durationTimeLab.text = [self formatTimeWithSecond:time];
    _durationTime = time;
}

- (void)setControlBarMainTitle:(NSString *)title
{
    self.mainTitleLab.text = title ?: @"";
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
