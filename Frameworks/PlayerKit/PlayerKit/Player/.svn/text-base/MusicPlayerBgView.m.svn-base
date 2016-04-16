//
//  MusicPlayerBgView.m
//  iThunder
//
//  Created by omgder on 15/7/9.
//  Copyright (c) 2015年 xunlei.com. All rights reserved.
//

#import "MusicPlayerBgView.h"
#import "UIImage+pk.h"

@implementation MusicPlayerBgView

{
    double _angleEarth;
    double _angle;
    //  UIImageView *_imageView;
    UIImageView *_imageViewCircle;
    NSMutableArray *_imageArray;
    NSInteger _value;
    BOOL _isPause;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _speed=1.0;
        _value=1;
        self.backgroundColor=[UIColor clearColor];
        _imageArray = [[NSMutableArray alloc]init];
        
        
        _imageViewCircle = [[UIImageView alloc]initWithFrame:CGRectMake(0 , 0, 125, 125)];
        _imageViewCircle.image=[UIImage imageInPKBundleWithName:@"pk_music_paly_bg"];
        [self addSubview:_imageViewCircle];
        
        [self startAnimation];
        
    }
    return self;
}



- (void)startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    if(!_isPause)
    {
        [UIView setAnimationDidStopSelector:@selector(endAnimation)];
    }
    _imageViewCircle.transform = CGAffineTransformMakeRotation(_angleEarth * (M_PI / -180.0f));
    // imageViewEarth.layer.anchorPoint=CGPointMake(2.2, 2.2);
    [UIView commitAnimations];
}
- (void)endAnimation
{
    _angleEarth += 5*_speed;
    [self startAnimation];
}

- (void)stop
{
    _isPause = YES;
}

- (void)restart
{
    _isPause = NO;
    [self startAnimation];
}


@end
