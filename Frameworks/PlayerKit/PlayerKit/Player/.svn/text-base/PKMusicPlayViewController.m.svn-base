//
//  PKMusicPlayViewController.m
//  PlayerKit
//
//  Created by omgder on 15/7/9.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKMusicPlayViewController.h"
#import "MusicPlayerBgView.h"
#import "NSBundle+pk.h"
//正方形
#define kHalfImageWidth 63
#define kFullImageWidth 126

@interface PKMusicPlayViewController ()
@property (strong, nonatomic) MusicPlayerBgView *bgView;
@end

@implementation PKMusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self animationInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animationInit
{
    _bgView = [[MusicPlayerBgView alloc] init];
    _bgView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - kHalfImageWidth, [UIScreen mainScreen].bounds.size.height/2 - kHalfImageWidth, kFullImageWidth, kFullImageWidth);
    [self.view addSubview:_bgView];
    self.view.backgroundColor  = [UIColor blackColor];
}



- (void)stopAnimation
{
    [_bgView stop];
}
- (void)startAnimation
{
    [_bgView restart];
}


+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKMusicPlayViewController *vc =
    [[PKMusicPlayViewController alloc] initWithNibName:NSStringFromClass([self class])
                                            bundle:bundle];
    return vc;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
