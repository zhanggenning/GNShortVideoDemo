//
//  PKLightVideoProcessIndicator.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoProcessIndicator.h"
#import "PKLightVideoPlayerSlider.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"

@interface PKLightVideoProcessIndicator ()

@property (nonatomic, assign) PKLightVideoIndicatorType type;
@property (nonatomic, assign) CGFloat process;
@property (nonatomic, assign) BOOL isRewind;
@property (nonatomic, assign) BOOL isNoVolume;

@property (nonatomic, strong) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet PKLightVideoPlayerSlider *processSlider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_bgViewH;

@end

@implementation PKLightVideoProcessIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
        
        [self initUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
        
        [self initUI];
    }
    return self;
}

#pragma mark -- 私有
- (void)commonInit
{
    if (!_contentView)
    {
        _contentView = [[[NSBundle pkBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        if (!_contentView) {
            return;
        }
        
        [self addSubview:_contentView];
        [self addContraintsOnView:_contentView];
    }
}

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    _contentView.backgroundColor = [UIColor clearColor];
    
    _bgView.layer.cornerRadius = 5.0;
    _processSlider.thumbHidden = YES;
    _processSlider.layer.cornerRadius = 2.0;
    [_processSlider processHexColor:0xffffff alpha:1.0];
    [_processSlider backHexColor:0xffffff alpha:0.5];
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

- (void)configUserInfo:(NSDictionary *)userInfo type:(PKLightVideoIndicatorType)type
{
    if (!userInfo) {
        return;
    }
    
    switch (_type)
    {
        case kLightVideoIndicatorTime:
        {
            //设置时间字符串
            if (userInfo[@"timeStr"])
            {
                NSString *timeStr = [NSString stringWithFormat:@"%@", userInfo[@"timeStr"]];
                _timeLab.text = timeStr;
            }
            
            //设置图片
            if (userInfo[@"isRewind"])
            {
                self.isRewind = [userInfo[@"isRewind"] boolValue];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark -- 属性
- (void)setIsRewind:(BOOL)isRewind
{
    _isRewind = isRewind;
    
    if (self.isRewind)
    {
        self.logoView.image = [UIImage imageInPKBundleWithName:@"pk_LightVideo_rewind.png"];
    }
    else
    {
        self.logoView.image = [UIImage imageInPKBundleWithName:@"pk_LightVideo_forward.png"];
    }
}

- (void)setIsNoVolume:(BOOL)isNoVolume
{
    _isNoVolume = isNoVolume;
    
    if (isNoVolume)
    {
        self.logoView.image = [UIImage imageInPKBundleWithName:@"pk_LightVideo_novolume.png"];
    }
    else
    {
        self.logoView.image = [UIImage imageInPKBundleWithName:@"pk_LightVideo_volume.png"];
    }
}

- (void)setType:(PKLightVideoIndicatorType)type
{
    if (_type == type) {
        return;
    }
    
    switch (type)
    {
        case kLightVideoIndicatorTime:
        {
            _timeLab.hidden = NO;
            _constraint_bgViewH.constant = 116.0;
            self.isRewind = _isRewind;
            break;
        }
        case kLightVideoIndicatorVolume:
        {
            _timeLab.hidden = YES;
            _constraint_bgViewH.constant = 88.0;
            self.isNoVolume = _isNoVolume;
            break;
        }
        case kLightVideoIndicatorBrightness:
        {
            _timeLab.hidden = YES;
            _constraint_bgViewH.constant = 88.0;
            self.logoView.image = [UIImage imageInPKBundleWithName:@"pk_LightVideo_brightness.png"];
            
            break;
        }
        default:
            break;
    }
    
    _type = type;
}

- (void)setProcess:(CGFloat)process
{
    _process = process;
    
    _processSlider.process = process;
    
    //同步音量图片
    if (_type == kLightVideoIndicatorVolume)
    {
        if (process <= 0)
        {
            if (!_isNoVolume) {
                _isNoVolume = YES;
            }
        }
        else
        {
            if (_isNoVolume) {
                self.isNoVolume = NO;
            }
        }
    }
}


#pragma mark -- 公共
- (void)showWithIndicatorType:(PKLightVideoIndicatorType)type
                      process:(CGFloat)process
                     userInfo:(NSDictionary *)userInfo
{
    //设置类型
    self.type = type;

    //设置进度
    self.process = process;
    
    //设置用户信息
    [self configUserInfo:userInfo type:type];

}

@end
