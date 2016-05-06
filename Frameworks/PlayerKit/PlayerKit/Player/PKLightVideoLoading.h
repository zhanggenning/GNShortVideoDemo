//
//  PKLightVideoLoading.h
//  PlayerKit
//
//  Created by zhanggenning on 16/5/6.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKLightVideoLoading : UIView

@property(nonatomic, assign) BOOL hidesWhenStopped; //default: YES

- (void)startAnimating;

- (void)stopAnimating;

- (BOOL)isAnimating;

@end
