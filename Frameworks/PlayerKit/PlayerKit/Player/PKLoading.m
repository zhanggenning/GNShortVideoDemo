//
//  PKLoading.m
//  PlayerKit
//
//  Created by lucky.li on 15/5/8.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKLoading.h"
#import "NSBundle+pk.h"
#import "UIImage+pk.h"
#import "UIDevice+pk.h"

#pragma mark -
@interface PKLoading ()

@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)doInit;

@end

#pragma mark -
@implementation PKLoading

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self doInit];
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKLoading *instance = nil;
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

- (BOOL)isShowing {
    return (self.alpha > 0.0);
}

- (void)showWithDescription:(NSString *)descriptionString {
    self.descriptionLabel.text = descriptionString;
    [UIView animateWithDuration:.3
                     animations:^{
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hide {
    if (self.alpha == 0.0) {
        return;
    }
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Private

- (void)doInit {
    UIImage *bgImage = [UIImage imageInPKBundleWithName:@"pk_common_round_bg.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    self.bgView.image = bgImage;
    
    self.alpha = 0.0;
    [self.activityIndicator startAnimating];
}

@end
