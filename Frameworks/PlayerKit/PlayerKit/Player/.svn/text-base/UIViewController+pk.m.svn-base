//
//  UIViewController+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/3/9.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "UIViewController+pk.h"

@implementation UIViewController (pk)

+ (UIViewController *)topPresentedViewController {
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (top.presentedViewController != nil) {
        top = top.presentedViewController;
    }
    return top;
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated: (BOOL)flag
                   completion:(void (^)(void))completion {
    UIViewController *top = [UIViewController topPresentedViewController];
    [top presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
