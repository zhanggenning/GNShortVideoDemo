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

static NSString * const kTestUrl2 = @"http://7xnusr.com1.z0.glb.clouddn.com/3039c761468b857649a9f70a28a5f266e9d4fdee?e=1461487828&token=8e4YkwOPAwrhUijy7FMfODl6WpNWmF9LiYknl5WH:RbgjAoUaGaOocOqqZGlhewTb8tk=";

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
