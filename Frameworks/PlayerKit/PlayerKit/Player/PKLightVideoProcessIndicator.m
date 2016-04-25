//
//  PKLightVideoProcessIndicator.m
//  PlayerKit
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import "PKLightVideoProcessIndicator.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"

@interface PKLightVideoProcessIndicator ()

@property (nonatomic, strong) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

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
    
    UIImage *bgImage = [UIImage imageInPKBundleWithName:@"pk_common_round_bg.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    self.bgView.image = bgImage;
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

#pragma mark -- 属性
- (void)setIsRewind:(BOOL)isRewind
{
    _isRewind = isRewind;
    
    UIImage *logoImage = nil;

    if (self.isRewind)
    {
        logoImage = [UIImage imageInPKBundleWithName:@"pk_rewind_logo.png"];
    }
    else
    {
        logoImage = [UIImage imageInPKBundleWithName:@"pk_fast_forward_logo.png"];
    }
    self.logoView.image = logoImage;
}

- (void)setDescriptionString:(NSString *)descriptionString
{
    _descriptionString = descriptionString;
    
    self.timeLab.text = self.descriptionString;
}

#pragma mark -- 公共
- (void)showWithDescription:(NSString *)descriptionString isRewind:(BOOL)isRewind
{
    self.descriptionString = descriptionString;
    self.isRewind = isRewind;
}

@end
