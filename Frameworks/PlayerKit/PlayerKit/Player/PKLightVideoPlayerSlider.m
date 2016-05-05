//
//  PKLightVideoPlayerSlider.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//  进度条（轻量级播放器专用）

#import "PKLightVideoPlayerSlider.h"
#import "UIImage+pk.h"
#import "UIColor+pk.h"

static const CGFloat kSliderHeight = 4; //进度条宽度
static const CGFloat kSliderThumbHeight = 26; //正方形滑块边长

typedef NS_ENUM(NSInteger, PKLightVideoSliderDirection)
{
    kVideoSliderLandscapeRight = 0, //横向向右
    kVideoSliderVertaicalDown, //竖向向下
    kVideoSliderVertaicalUp,   //竖向向上
};

@interface PKLightVideoPlayerSlider ()
{
    CGRect _currentBounds;
}
@property (nonatomic, strong) UIView *sliderView; //进度条
@property (nonatomic, strong) CALayer *processLayer; //播放进度层
@property (nonatomic, strong) CALayer *bufferProcessLayer; //缓冲进度层
@property (nonatomic, strong) UIImageView *thumbView; //滑块

@property (nonatomic, assign) PKLightVideoSliderDirection sliderDirection; //布局方向

@end

@implementation PKLightVideoPlayerSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    if (!CGRectEqualToRect(_currentBounds, layer.bounds))
    {
        if (layer.bounds.size.width >= layer.bounds.size.height) //宽大于等于高：横向布局
        {
            [self layoutSubviewsOnLandscapeRight];
        }
        else //宽小于高：竖向向下
        {
            [self layoutSubviewsOnVerticalUp];
        }
        [self layoutWithSliderDirection: self.sliderDirection];
        _currentBounds = layer.bounds;
    }
}

#pragma mark -- 私有 API
- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    
    //进度条
    [self.sliderView.layer addSublayer:self.bufferProcessLayer];
    [self.sliderView.layer addSublayer:self.processLayer];
    [self addSubview:self.sliderView];
    
    //滑块
    [self addSubview:self.thumbView];
    self.thumbView.frame = CGRectMake(0, 0, kSliderThumbHeight, kSliderThumbHeight);
    
    //手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
}

- (void)layoutWithSliderDirection:(PKLightVideoSliderDirection)direction
{
    switch (direction) {
        case kVideoSliderLandscapeRight:
        {
            [self layoutSubviewsOnLandscapeRight];
            break;
        }
        case kVideoSliderVertaicalDown:
        {
            [self layoutSubviewsOnVerticalDown];
            break;
        }
        case kVideoSliderVertaicalUp:
        {
            [self layoutSubviewsOnVerticalUp];
            break;
        }
        default:
            break;
    }

}

- (void)layoutSubviewsOnLandscapeRight
{
    CGRect tempRect = CGRectZero;
    
    //背景view
    if (_thumbHidden)
    {
        self.sliderView.frame = self.bounds;
    }
    else
    {
        self.sliderView.frame = CGRectMake(self.bounds.origin.x + kSliderThumbHeight / 2,
                                           self.bounds.size.height / 2 - kSliderHeight / 2,
                                           self.bounds.size.width - kSliderThumbHeight,
                                           kSliderHeight);
    }
    
    tempRect = self.sliderView.bounds;
    tempRect.size.width = _process * _sliderView.bounds.size.width;
    self.processLayer.frame = tempRect;
    
    tempRect = self.sliderView.bounds;
    tempRect.size.width = _process * _sliderView.bounds.size.width;
    self.bufferProcessLayer.frame = tempRect;
    
    self.thumbView.center = CGPointMake(self.sliderView.bounds.size.width * _process + kSliderThumbHeight/2,
                                        self.sliderView.center.y);
}

- (void)layoutSubviewsOnVerticalDown
{
    CGRect tempRect = CGRectZero;
    
    //背景view
    if (_thumbHidden)
    {
        self.sliderView.frame = self.bounds;
    }
    else
    {
        self.sliderView.frame = CGRectMake(self.bounds.size.width / 2 - kSliderHeight / 2,
                                           self.bounds.origin.y + kSliderThumbHeight / 2,
                                           kSliderHeight,
                                           self.bounds.size.height - kSliderThumbHeight);
    }
    
    tempRect = self.sliderView.bounds;
    tempRect.size.height = _process * _sliderView.bounds.size.height;
    self.processLayer.frame = tempRect;
    
    tempRect = self.sliderView.bounds;
    tempRect.size.height = _bufferProcess * _sliderView.bounds.size.height;
    self.bufferProcessLayer.frame = tempRect;
    
    self.thumbView.center = CGPointMake(self.sliderView.center.x,
                                        self.sliderView.bounds.size.height * _process + kSliderThumbHeight/2);
}

- (void)layoutSubviewsOnVerticalUp
{
    CGRect tempRect = CGRectZero;
    
    //背景view
    if (_thumbHidden)
    {
        self.sliderView.frame = self.bounds;
    }
    else
    {
        self.sliderView.frame = CGRectMake(self.bounds.size.width / 2 - kSliderHeight / 2,
                                           self.bounds.origin.y + kSliderThumbHeight / 2,
                                           kSliderHeight,
                                           self.bounds.size.height - kSliderThumbHeight);
    }
    
    tempRect = self.sliderView.bounds;
    tempRect.size.height = _process * _sliderView.bounds.size.height;
    tempRect.origin.y = _sliderView.bounds.size.height - tempRect.size.height;
    self.processLayer.frame = tempRect;
    
    tempRect = self.sliderView.bounds;
    tempRect.size.height = _bufferProcess * _sliderView.bounds.size.height;
    tempRect.origin.y = _sliderView.bounds.size.height - tempRect.size.height;
    self.bufferProcessLayer.frame = tempRect;
    
    self.thumbView.center = CGPointMake(_sliderView.center.x,
                                        _sliderView.frame.origin.y + _sliderView.frame.size.height - _sliderView.frame.size.height * _process);
}

#pragma mark -- 属性
- (UIView *)sliderView
{
    if (!_sliderView)
    {
        _sliderView = [[UIView alloc] init];
        _sliderView.backgroundColor = [UIColor colorWithHexValue:0x000000 alpha:0.6];
    }
    return _sliderView;
}

- (CALayer *)processLayer
{
    if (!_processLayer)
    {
        _processLayer = [CALayer layer];
        _processLayer.backgroundColor = [UIColor colorWithHexValue:0x1294f6 alpha:1.0].CGColor;
    }
    return _processLayer;
}

- (CALayer *)bufferProcessLayer
{
    if (!_bufferProcessLayer)
    {
        _bufferProcessLayer = [CALayer layer];
        _bufferProcessLayer.backgroundColor = [UIColor colorWithHexValue:0xdddddd alpha:1.0].CGColor;
    }
    return _bufferProcessLayer;
}

- (UIImageView *)thumbView
{
    if (!_thumbView)
    {
        UIImage *thumbImg = [UIImage imageInPKBundleWithName:@"pk_slider_thumb_btn_n.png"];
        _thumbView = [[UIImageView alloc] initWithImage:thumbImg];
        _thumbView.userInteractionEnabled = YES;
    }
    return _thumbView;
}

- (void)setProcess:(CGFloat)process
{
    process = (process < 1.0 ? process : 1.0);
    process = (process > 0.0 ? process : 0.0);
    CGRect tempRect = CGRectZero;
    
    NSLog(@"%f, %f", _process, process);
    
    switch (_sliderDirection)
    {
        case kVideoSliderLandscapeRight:
        {
            _thumbView.center = CGPointMake(_sliderView.bounds.size.width * process + kSliderThumbHeight/2,
                                            _sliderView.center.y);
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            tempRect = self.sliderView.bounds;
            tempRect.size.width = process * _sliderView.bounds.size.width;
            _processLayer.frame = tempRect;
            [CATransaction commit];
            break;
        }
        case kVideoSliderVertaicalDown:
        {
            _thumbView.center = CGPointMake(_sliderView.center.x,
                                            _sliderView.bounds.size.height * process + kSliderThumbHeight/2);
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            tempRect = self.sliderView.bounds;
            tempRect.size.height = process * _sliderView.bounds.size.height;
            _processLayer.frame = tempRect;
            [CATransaction commit];
            break;
        }
        case kVideoSliderVertaicalUp:
        {
            _thumbView.center = CGPointMake(_sliderView.center.x,
                                            _sliderView.frame.origin.y + _sliderView.frame.size.height - _sliderView.frame.size.height * process);
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            tempRect = self.sliderView.bounds;
            tempRect.size.height = process * _sliderView.bounds.size.height;
            tempRect.origin.y = _sliderView.bounds.size.height - tempRect.size.height;
            _processLayer.frame = tempRect;
            [CATransaction commit];
        }
            
        default:
            break;
    }
    
    _process = process;
}

- (void)setBufferProcess:(CGFloat)bufferProcess
{
    bufferProcess = (bufferProcess < 1.0 ? bufferProcess : 1.0);
    bufferProcess = (bufferProcess > 0.0 ? bufferProcess : 0.0);
    CGRect tempRect = CGRectZero;
    
    switch (_sliderDirection)
    {
        case kVideoSliderLandscapeRight:
        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            tempRect = self.sliderView.bounds;
            tempRect.size.width = bufferProcess * _sliderView.bounds.size.width;
            _bufferProcessLayer.frame = tempRect;
            [CATransaction commit];
            break;
        }
        case kVideoSliderVertaicalDown:
        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            tempRect = self.sliderView.bounds;
            tempRect.size.height = bufferProcess * _sliderView.bounds.size.height;
            _bufferProcessLayer.frame = tempRect;
            [CATransaction commit];
            break;
        }
        case kVideoSliderVertaicalUp:
        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            tempRect = self.sliderView.bounds;
            tempRect.size.height = bufferProcess * _sliderView.bounds.size.height;
            tempRect.origin.y = _sliderView.bounds.size.height - tempRect.size.height;
            _bufferProcessLayer.frame = tempRect;
            [CATransaction commit];
            break;
        }
        default:
            break;
    }
    
    _bufferProcess = bufferProcess;
}

- (void)setThumbHidden:(CGFloat)thumbHidden
{
    _thumbHidden = thumbHidden;
    
    self.thumbView.hidden = thumbHidden;
    self.userInteractionEnabled = !thumbHidden;
    
    [self layoutWithSliderDirection: self.sliderDirection];
}

#pragma mark -- 事件
- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(PKLightPlayerSlider:progressWillChange:)])
            {
                [_delegate PKLightPlayerSlider:self progressWillChange:_process];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            self.process = [self processWithGestureReconizer:pan];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(PKLightPlayerSlider:progressDidChange:)])
            {
                [_delegate PKLightPlayerSlider:self progressDidChange:_process];
            }
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    self.process = [self processWithGestureReconizer:tap];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PKLightPlayerSlider:progressDidChange:)])
    {
        [_delegate PKLightPlayerSlider:self progressDidChange:_process];
    }
}

- (CGFloat)processWithGestureReconizer:(UIGestureRecognizer *)gesture
{
    CGFloat process = 0.0;
    
    CGPoint locationInSlider = [gesture locationInView:self];
    
    switch (_sliderDirection)
    {
        case kVideoSliderLandscapeRight:
        {
            if (locationInSlider.x < _sliderView.bounds.origin.x + kSliderThumbHeight/2)
            {
                locationInSlider.x = _sliderView.bounds.origin.x + kSliderThumbHeight/2;
            }
            else if (locationInSlider.x > _sliderView.bounds.origin.x + _sliderView.bounds.size.width + kSliderThumbHeight/2)
            {
                locationInSlider.x = (_sliderView.bounds.origin.x + _sliderView.bounds.size.width + kSliderThumbHeight/2);
            }
            process = (locationInSlider.x - kSliderThumbHeight/2) / _sliderView.bounds.size.width;
            break;
        }
        case kVideoSliderVertaicalDown:
        {
            if (locationInSlider.y < _sliderView.bounds.origin.y + kSliderThumbHeight/2)
            {
                locationInSlider.y = _sliderView.bounds.origin.y + kSliderThumbHeight/2;
            }
            else if (locationInSlider.y > _sliderView.bounds.origin.y + _sliderView.bounds.size.height + kSliderThumbHeight/2)
            {
                locationInSlider.y = (_sliderView.bounds.origin.y + _sliderView.bounds.size.height + kSliderThumbHeight/2);
            }
            process = (locationInSlider.y - kSliderThumbHeight/2) / _sliderView.bounds.size.height;
            
            break;
        }
        case kVideoSliderVertaicalUp:
        {
            if (locationInSlider.y < _sliderView.bounds.origin.y + kSliderThumbHeight/2)
            {
                locationInSlider.y = _sliderView.bounds.origin.y + kSliderThumbHeight/2;
            }
            else if (locationInSlider.y > _sliderView.bounds.origin.y + _sliderView.bounds.size.height + kSliderThumbHeight/2)
            {
                locationInSlider.y = (_sliderView.bounds.origin.y + _sliderView.bounds.size.height + kSliderThumbHeight/2);
            }
            
            process = 1 - (locationInSlider.y - kSliderThumbHeight/2) / _sliderView.bounds.size.height;
            break;
        }
        default:
            break;
    }
    
    return process;
}

@end
