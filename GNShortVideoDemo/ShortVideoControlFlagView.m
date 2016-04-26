//
//  ShortVideoControlFlagView.m
//  ShortVideoFeedTest
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShortVideoControlFlagView.h"

@interface ShortVideoControlFlagView ()
{
    NSInteger _increment;
    NSInteger _curValue;
}

@property (nonatomic, strong) UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *describeLab;

@property (nonatomic, strong) UILabel *animationLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_imgLeft;

@end

@implementation ShortVideoControlFlagView

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

- (void)commonInit
{
    if (!_contentView)
    {
        _contentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        [self addSubview:_contentView];
        
        [self addContraintsOnView:_contentView];
    }
}

- (void)initUI
{
    [self configImgWithFlag:NO];
    
    _describeLab.text = @"0";
    
    _curValue = 0;
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

- (void)configImgWithFlag:(BOOL)isFlag
{
    NSString *imgName = @"";
    
    if (_controlStyle == ShortVideoControlFlagFun)
    {
        imgName = (isFlag ? @"fun_favor_hover" : @"fun_favor_normal");
    }
    else if (_controlStyle == ShortVideoControlFlagComment)
    {
        imgName = (isFlag ? @"fun_comment_hover" : @"fun_comment_normal");
    }
    else if (_controlStyle == ShortVideoControlFlagShare)
    {
        imgName = (isFlag ? @"fun_share_hover" : @"fun_share_normal");
    }
    
    _imgView.image = [UIImage imageNamed:imgName];
}

- (NSString *)incrementStrByCount:(NSInteger)count
{
    NSInteger increment = 0;
    NSString *incrementStr = @"0";

    increment = count - _curValue;
    
    if (increment > 0)
    {
        incrementStr = [NSString stringWithFormat:@"%+zi", increment];
    }
    else if (increment < 0)
    {
        incrementStr = [NSString stringWithFormat:@"%-zi", -increment];
    }
    
    _curValue = count;
    
    return incrementStr;
}

#pragma mark -- 属性
- (void)setControlStyle:(ShortVideoContorlFlagStyle)controlStyle
{
    _controlStyle = controlStyle;
    
    switch (controlStyle)
    {
        case ShortVideoControlFlagFun:
        {
            [self configImgWithFlag:NO];
    
            break;
        }
        case ShortVideoControlFlagComment:
        {
            [self configImgWithFlag:NO];
            
            break;
        }
        case ShortVideoControlFlagShare:
        {
            [self configImgWithFlag:NO];
            
            _describeLab.hidden = YES;
            _constraint_imgLeft.constant *= 2;
            
            break;
        }
        default:
            break;
    }
}

-(UILabel *)animationLab
{
    if (!_animationLab)
    {
        _animationLab = [[UILabel alloc] init];
        _animationLab.textColor = [UIColor redColor];
        _animationLab.font = [UIFont systemFontOfSize:14.0];
    }
    return _animationLab;
}

#pragma mark -- 公共API
- (void)setFlag:(BOOL)isFlag count:(NSInteger)count animation:(BOOL)isAnimation
{
    _isFlag = isFlag;
   
    //计算增量
    NSString *incrementStr = [self incrementStrByCount:count];
    self.animationLab.text = incrementStr;
    
    //图片
    [self configImgWithFlag:isFlag];
    
    //数字
    if (!_describeLab.isHidden)
    {
        _describeLab.text = [NSString stringWithFormat:@"%zi", count];
    }
    
    //动画
    if (isAnimation && ![incrementStr isEqualToString:@"0"])
    {
        self.animationLab.frame = CGRectMake(_describeLab.frame.origin.x,
                                             _describeLab.bounds.origin.y,
                                             self.bounds.size.width - _describeLab.frame.origin.x,
                                             self.bounds.size.height);
        [self addSubview:self.animationLab];
        [self insertSubview:self.animationLab belowSubview:_describeLab];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.animationLab.frame;
            rect.origin.y -= (rect.size.height / 2);
            self.animationLab.frame = rect;
            
            self.animationLab.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            [self.animationLab removeFromSuperview];
            self.animationLab.alpha = 1.0;
        }];
    }
}

@end
