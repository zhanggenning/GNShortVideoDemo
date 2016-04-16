//
//  PKSlider.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/5.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKSlider.h"
#import "NSBundle+pk.h"

#pragma mark -
@interface PKSlider ()

@property (weak, nonatomic) IBOutlet UIImageView *trackView;
@property (weak, nonatomic) IBOutlet UIImageView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *thumbBtn;

@property (assign, nonatomic) BOOL isUserInteracting;

- (void)doInit;

- (void)panGestureAction:(UIPanGestureRecognizer *)pan;
- (void)tapGestureAction:(UITapGestureRecognizer *)tap;

- (void)updateProgressWithGestureReconizer:(UIGestureRecognizer *)gesture;

@end

#pragma mark -
@implementation PKSlider

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.progressInPercent = self.progressInPercent;
    self.bufferProgressInPercent = self.bufferProgressInPercent;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self doInit];
}

- (void)setProgressInPercent:(CGFloat)progress {
    if (progress < 0.0 || progress > 1.0) {
        return;
    }
    
    _progressInPercent = progress;
    
    if (!self.isUserInteracting) {
        CGFloat xLocationInTrack = _progressInPercent*self.trackView.bounds.size.width;
        xLocationInTrack = round(xLocationInTrack*2)/2;
        CGRect frame = self.progressView.frame;
        if (fabs(xLocationInTrack-frame.size.width) > DBL_EPSILON) {
            CGRect newFrame = CGRectMake(frame.origin.x,
                                         frame.origin.y,
                                         xLocationInTrack,
                                         frame.size.height);
            NSLog(@"play: %@", NSStringFromCGRect(newFrame));
            self.progressView.frame = newFrame;
            
            CGPoint locationInTrack = CGPointMake(xLocationInTrack, 0);
            CGPoint locationInSlider = [self convertPoint:locationInTrack fromView:self.trackView];
            self.thumbBtn.center = CGPointMake(locationInSlider.x, self.thumbBtn.center.y);
        }
    }
}

- (void)setBufferProgressInPercent:(CGFloat)bufferProgress {
    if (bufferProgress < 0.0 || bufferProgress > 1.0) {
        return;
    }
    
    _bufferProgressInPercent = bufferProgress;
    
    CGFloat xLocationInTrack = _bufferProgressInPercent*self.trackView.bounds.size.width;
    xLocationInTrack = round(xLocationInTrack*2)/2;
    CGRect frame = self.bufferProgressView.frame;
    if (fabs(xLocationInTrack-frame.size.width) > DBL_EPSILON) {
        CGRect newFrame = CGRectMake(frame.origin.x,
                                     frame.origin.y,
                                     xLocationInTrack,
                                     frame.size.height);
        NSLog(@"buffer: %@", NSStringFromCGRect(newFrame));
        self.bufferProgressView.frame = newFrame;
    }
}

- (void)setShowBufferProgress:(BOOL)showBufferProgress {
    _showBufferProgress = showBufferProgress;
    
    self.bufferProgressView.hidden = !_showBufferProgress;
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKSlider *slider = [[bundle loadNibNamed:NSStringFromClass([self class])
                                       owner:nil
                                     options:nil] firstObject];
    return slider;
}

- (CGPoint)thumbBtnCenterInSlider {
    return self.thumbBtn.center;
}

#pragma mark - Private

- (void)doInit {
    self.isUserInteracting = NO;
    self.progressInPercent = 0;
    self.bufferProgressInPercent = 0;
    self.showBufferProgress = YES;
    
    /// pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(panGestureAction:)];
    [self.thumbBtn addGestureRecognizer:pan];
    
    /// tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
    
    self.trackView.image = [self.trackView.image stretchableImageWithLeftCapWidth:2
                                                                     topCapHeight:0];
    self.bufferProgressView.image = [self.bufferProgressView.image stretchableImageWithLeftCapWidth:2
                                                                                       topCapHeight:0];
    self.progressView.image = [self.progressView.image stretchableImageWithLeftCapWidth:2
                                                                           topCapHeight:0];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"began:\n");
            self.isUserInteracting = YES;
            [self updateProgressWithGestureReconizer:pan];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            NSLog(@"changed:\n");
            [self updateProgressWithGestureReconizer:pan];
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderProgressValueChanged:)]) {
                [self.delegate sliderProgressValueChanged:self];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            NSLog(@"done:\n");
            self.isUserInteracting = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderProgressValueChanged:)]) {
                [self.delegate sliderProgressValueChanged:self];
            }
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"tap:\n");
        self.isUserInteracting = YES;
        [self updateProgressWithGestureReconizer:tap];
        self.isUserInteracting = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(sliderProgressValueChanged:)]) {
            [self.delegate sliderProgressValueChanged:self];
        }
    }
}

- (void)updateProgressWithGestureReconizer:(UIGestureRecognizer *)gesture {
    CGPoint locationInSlider =  [gesture locationInView:self];
    if (locationInSlider.x < self.trackView.frame.origin.x) {
        locationInSlider.x = self.trackView.frame.origin.x;
    } else if (locationInSlider.x > (self.trackView.frame.origin.x+self.trackView.frame.size.width)) {
        locationInSlider.x = self.trackView.frame.origin.x+self.trackView.frame.size.width;
    }
    self.thumbBtn.center = CGPointMake(locationInSlider.x, self.thumbBtn.center.y);
    NSLog(@"locationInSlider: %@", NSStringFromCGPoint(locationInSlider));
    
    CGPoint locationInTrack = [gesture locationInView:self.trackView];
    if (locationInTrack.x < 0) {
        locationInTrack.x = 0;
    } else if (locationInTrack.x > self.trackView.bounds.size.width) {
        locationInTrack.x = self.trackView.bounds.size.width;
    }
    self.progressView.frame = CGRectMake(self.progressView.frame.origin.x,
                                         self.progressView.frame.origin.y,
                                         locationInTrack.x,
                                         self.progressView.frame.size.height);
    
    self.progressInPercent = locationInTrack.x/self.trackView.frame.size.width;
}

@end
