//
//  PKProgressIndicator.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/9.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKProgressIndicator.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"
#import "UIDevice+pk.h"

#pragma mark -
@interface PKProgressIndicator ()

@property (assign, nonatomic) BOOL isShowing;

@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)doInit;

- (void)delayHide;

@end


#pragma mark -
@implementation PKProgressIndicator

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self doInit];
}

- (void)setIsRewind:(BOOL)isRewind {
    _isRewind = isRewind;
    
    UIImage *logoImage = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        if (self.isRewind) {
            logoImage = [UIImage imageInPKBundleWithName:@"pk_rewind_logo_i5.png"];
        } else {
            logoImage = [UIImage imageInPKBundleWithName:@"pk_fast_forward_logo_i5.png"];
        }
    } else {
        if (self.isRewind) {
            logoImage = [UIImage imageInPKBundleWithName:@"pk_rewind_logo.png"];
        } else {
            logoImage = [UIImage imageInPKBundleWithName:@"pk_fast_forward_logo.png"];
        }
    }
    self.logoView.image = logoImage;
}

- (void)setDescriptionString:(NSString *)descriptionString {
    _descriptionString = descriptionString;
    
    self.descriptionLabel.text = self.descriptionString;
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKProgressIndicator *instance = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        NSString *nibName = [NSString stringWithFormat:@"%@_i5", NSStringFromClass([self class])];
        instance = [[bundle loadNibNamed:nibName
                                   owner:nil
                                 options:nil] firstObject];
    } else {
        instance = [[bundle loadNibNamed:NSStringFromClass([self class])
                                   owner:nil
                                 options:nil] firstObject];
    }
    return instance;
}

- (void)showWithDescription:(NSString *)descriptionString
                   isRewind:(BOOL)isRewind {
    self.descriptionString = descriptionString;
    self.isRewind = isRewind;
    
    if (self.isShowing) {
        self.isShowing = YES;
        self.alpha = 1.0;
        if (self.enableAutoHide) {
            [self.class cancelPreviousPerformRequestsWithTarget:self];
            [self.layer removeAllAnimations];
            [self performSelector:@selector(delayHide) withObject:nil afterDelay:2];
        }
    } else {
        self.isShowing = YES;
        self.alpha = 0.0;
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             if (self.enableAutoHide) {
                                 [self performSelector:@selector(delayHide) withObject:nil afterDelay:2];
                             }
                         }];
    }
}

- (void)hide {
    if (!self.isShowing) {
        return;
    }
    
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.isShowing = NO;
                         self.alpha = 0.0;
                     }];
}

#pragma mark - Private

- (void)doInit {
    UIImage *bgImage = [UIImage imageInPKBundleWithName:@"pk_common_round_bg.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    self.bgView.image = bgImage;
}

- (void)delayHide {
    if (!self.enableAutoHide) {
        return;
    }
    
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.isShowing = NO;
                     }];
}

@end
