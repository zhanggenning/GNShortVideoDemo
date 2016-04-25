//
//  MainViewController.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/16.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "MainViewController.h"
#import "PlayerKit.h"

static NSString * const kTestUrl1 = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";
static NSString * const kTestUrl2 = @"http://v4.pstatp.com/525d7a128d00488a0f2efc28ca491a75/571db85c/origin/7605/1526846847";
static NSString * const kTestUrl3 = @"http://v7.pstatp.com/165206dc5d61a5477a9d6f2f6abaa769/571db8bc/origin/15793/486638799";
static NSString * const kTestUrl4 = @"http://v4.pstatp.com/1728e034de89476b50e0d0dae67b2209/571db8f0/origin/9306/3704849961";

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(UIButton *)sender
{
//    [[PKPlayerManager sharedManager] playWithContentURLString:urlString];
    
    [PKPlayerManager sharedManager].lightVideoPlayerVC.view.frame = CGRectMake(0, 0, 300, 200);
    [PKPlayerManager sharedManager].lightVideoPlayerVC.view.center = self.view.center;
    [self.view addSubview:[PKPlayerManager sharedManager].lightVideoPlayerVC.view];
    [self addChildViewController:[PKPlayerManager sharedManager].lightVideoPlayerVC];
    
    [PKPlayerManager sharedManager].videoUrl = kTestUrl2;
}
- (IBAction)removeAction:(id)sender
{
    [[PKPlayerManager sharedManager].lightVideoPlayerVC removeFromParentViewController];
    
    [[PKPlayerManager sharedManager].lightVideoPlayerVC.view removeFromSuperview];
    
    [PKPlayerManager sharedManager].lightVideoPlayerVC = nil;
}

@end
