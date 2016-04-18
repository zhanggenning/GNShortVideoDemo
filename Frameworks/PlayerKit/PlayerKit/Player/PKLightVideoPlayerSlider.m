//
//  PKLightVideoPlayerSlider.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/18.
//  Copyright © 2016年 xunlei. All rights reserved.
//  进度条（轻量级播放器专用）

#import "PKLightVideoPlayerSlider.h"
#import "UIImage+pk.h"

static const CGFloat kSliderHeight = 4; //进度条宽度
static const CGFloat kSliderThumbHeight = 26; //正方形滑块边长

@interface PKLightVideoPlayerSlider ()
{
    CGRect _currentBounds;
}

@property (nonatomic, strong) UIView *sliderView; //进度条
@property (nonatomic, strong) CALayer *processLayer; //播放进度层
@property (nonatomic, strong) CALayer *bufferProcessLayer; //缓冲进度层
@property (nonatomic, strong) UIImageView *thumbView; //滑块

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
        //背景view
        self.sliderView.frame = CGRectMake(layer.bounds.origin.x + kSliderThumbHeight / 2,
                                           layer.bounds.size.height / 2 - kSliderHeight / 2,
                                           layer.bounds.size.width - kSliderThumbHeight,
                                           kSliderHeight);
        
        //进度layer
        self.processLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:_process];
        self.bufferProcessLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:_bufferProcess];
        
        //滑块
        self.thumbView.frame = CGRectMake(0, 0, kSliderThumbHeight, kSliderThumbHeight);
        self.thumbView.center = CGPointMake(self.sliderView.frame.origin.x, self.sliderView.center.y);
        
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
    
    //手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
}

- (CGRect)dstRectWithSrcRect:(CGRect)rect withProcess:(CGFloat)process
{
    CGRect tmp = rect;
    tmp.size.width = rect.size.width * process;
    return tmp;
}

#pragma mark -- 属性
- (UIView *)sliderView
{
    if (!_sliderView)
    {
        _sliderView = [[UIView alloc] init];
        _sliderView.backgroundColor = [UIColor blackColor];
    }
    return _sliderView;
}

- (CALayer *)processLayer
{
    if (!_processLayer)
    {
        _processLayer = [CALayer layer];
        _processLayer.backgroundColor = [UIColor blueColor].CGColor;
    }
    return _processLayer;
}

- (CALayer *)bufferProcessLayer
{
    if (!_bufferProcessLayer)
    {
        _bufferProcessLayer = [CALayer layer];
        _bufferProcessLayer.backgroundColor = [UIColor whiteColor].CGColor;
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
    _process = process;
    
    _thumbView.center = CGPointMake(_sliderView.bounds.size.width * process + kSliderThumbHeight/2, _thumbView.center.y);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _processLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:process];
    [CATransaction commit];
}

- (void)setBufferProcess:(CGFloat)bufferProcess
{
    _bufferProcess = bufferProcess;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _bufferProcessLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:bufferProcess];
    [CATransaction commit];
}

#pragma mark -- 事件
- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //手势开始
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self updateProgressWithGestureReconizer:pan];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"%f", _process);
            
            if (_valuedChangedBlock)
            {
                _valuedChangedBlock(_process);
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    CGPoint locationInSlider = [tap locationInView:self];
    
    if (locationInSlider.x < _sliderView.bounds.origin.x + kSliderThumbHeight/2)
    {
        locationInSlider.x = _sliderView.bounds.origin.x + kSliderThumbHeight/2;
    }
    else if (locationInSlider.x > _sliderView.bounds.origin.x + _sliderView.bounds.size.width + kSliderThumbHeight/2)
    {
        locationInSlider.x = (_sliderView.bounds.origin.x + _sliderView.bounds.size.width + kSliderThumbHeight/2);
    }
    
    self.process = (locationInSlider.x - kSliderThumbHeight/2) / _sliderView.bounds.size.width;
    
    if (_valuedChangedBlock)
    {
        _valuedChangedBlock(_process);
    }
}

- (void)updateProgressWithGestureReconizer:(UIGestureRecognizer *)gesture
{
    CGPoint locationInSlider =  [gesture locationInView:self];
  
    if (locationInSlider.x < _sliderView.bounds.origin.x + kSliderThumbHeight/2)
    {
        locationInSlider.x = _sliderView.bounds.origin.x + kSliderThumbHeight/2;
    }
    else if (locationInSlider.x > (_sliderView.bounds.origin.x + _sliderView.bounds.size.width + kSliderThumbHeight/2))
    {
        locationInSlider.x = _sliderView.bounds.origin.x + _sliderView.bounds.size.width + kSliderThumbHeight/2;
    }
    
    self.process = (locationInSlider.x - kSliderThumbHeight/2) / _sliderView.bounds.size.width;
}

@end
