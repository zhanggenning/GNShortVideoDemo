//
//  PKProgressDescriptionView.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/15.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKProgressDescriptionView.h"
#import "NSBundle+pk.h"

#pragma mark -
@interface PKProgressDescriptionView ()

@property (assign, nonatomic) BOOL isShowing;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)delayHide;

@end

#pragma mark -
@implementation PKProgressDescriptionView

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKProgressDescriptionView *pdv = [[bundle loadNibNamed:NSStringFromClass([self class])
                                                     owner:nil
                                                   options:nil] firstObject];
    return pdv;
}

- (void)showDescription:(NSString *)description withCenter:(CGPoint)center autoHide:(BOOL)autoHide {
    if (self.isShowing) {
        [self.class cancelPreviousPerformRequestsWithTarget:self];
        [self.layer removeAllAnimations];
    }
    
    self.descriptionLabel.text = description;
    self.center = center;
    self.isShowing = YES;
    self.alpha = 1.0;
    
    if (autoHide) {
        [self performSelector:@selector(delayHide) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - Private

- (void)delayHide {
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
