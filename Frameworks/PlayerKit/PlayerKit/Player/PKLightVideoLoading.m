//
//  PKLightVideoLoading.m
//  PlayerKit
//
//  Created by zhanggenning on 16/5/6.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoLoading.h"
#import "UIImage+pk.h"

@interface PKLightVideoLoading()
{
    CGRect _currentRect;
    CGFloat _angle;
    BOOL _isAnimating;
}
@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) CABasicAnimation* rotationAnimation;

@end

@implementation PKLightVideoLoading

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _isAnimating = NO;
    _hidesWhenStopped = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.img];
}

#pragma mark -- 私有
- (void)beginAnimation
{
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    _rotationAnimation.duration = 0.8;
    _rotationAnimation.cumulative = YES;
    _rotationAnimation.repeatCount = HUGE_VALF;
    _rotationAnimation.removedOnCompletion = NO;
    [_img.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];
}

- (void)endAnimation
{
    [_img.layer removeAllAnimations];
}

- (void)layoutSubviews
{
    if (!CGRectEqualToRect(_img.frame, self.bounds)) {
        _img.frame = self.bounds;
    }
}

#pragma mark -- 属性
- (UIImageView *)img
{
    if (!_img) {
        _img = [[UIImageView alloc] init];
        _img.image = [UIImage imageInPKBundleWithName:@"pk_LightVideo_loading.png"];
        _img.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _img;
}

#pragma mark -- 公共API
-(void) startAnimating
{
    if (!_isAnimating)
    {
        _isAnimating = YES;
    
        if (self.hidesWhenStopped && self.isHidden)
        {
            self.hidden = NO;
        }
        
        [self beginAnimation];
    }
}

- (void)stopAnimating
{
    _isAnimating = NO;
    
    [self endAnimation];
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

@end
