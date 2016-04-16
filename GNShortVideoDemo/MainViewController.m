//
//  MainViewController.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/16.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "MainViewController.h"
#import "PlayerKit.h"

@interface MainViewController ()

@end

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
    NSString *urlString = @"http://7xnusr.com1.z0.glb.clouddn.com/f65fbcaeb1f2e46d86b3ea9b5608208cbacb93eb?e=1461053078&token=8e4YkwOPAwrhUijy7FMfODl6WpNWmF9LiYknl5WH:gVyiXiJzdnxtZTkfO3nzqqR0yRw=";
    [[PKPlayerManager sharedManager] playWithContentURLString:urlString];
}

@end
