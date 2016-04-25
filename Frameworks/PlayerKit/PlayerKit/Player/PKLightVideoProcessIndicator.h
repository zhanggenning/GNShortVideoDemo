//
//  PKLightVideoProcessIndicator.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKLightVideoProcessIndicator : UIView

@property (assign, nonatomic) BOOL isRewind;
@property (strong, nonatomic) NSString *descriptionString;

- (void)showWithDescription:(NSString *)descriptionString
                   isRewind:(BOOL)isRewind;

@end
