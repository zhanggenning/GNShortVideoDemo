//
//  PKGuideViewController.m
//  PlayerKit
//
//  Created by lucky.li on 15/5/25.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKGuideViewController.h"
#import "UIDevice+pk.h"
#import "UIImage+pk.h"
#import "NSBundle+pk.h"

@interface PKGuideViewController ()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *guideView;

- (IBAction)dismissBtnAction:(id)sender;

@end

@implementation PKGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *suffix = nil;
    if ([UIDevice isIPad]) {
        suffix = @"ipad";
    } else if ([UIDevice isIphone_480]) {
        suffix = @"i4";
    } else if ([UIDevice isIphone_568]) {
        suffix = @"i5";
    } else if ([UIDevice isIphone_667]) {
        suffix = @"i6";
    } else if ([UIDevice isIphone_736]) {
        suffix = @"i6p";
    }
    NSString *imageName = [NSString stringWithFormat:@"pk_guide_%@.png", suffix];
    UIImage *guideImage = [UIImage imageInPKBundleWithName:imageName];
    self.guideView.image = guideImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKGuideViewController *vc =
    [[PKGuideViewController alloc] initWithNibName:NSStringFromClass([self class])
                                            bundle:bundle];
    return vc;
}

#pragma mark - Private

- (IBAction)dismissBtnAction:(id)sender {
    if (self.dismissHandler) {
        self.dismissHandler();
    }
}

@end
