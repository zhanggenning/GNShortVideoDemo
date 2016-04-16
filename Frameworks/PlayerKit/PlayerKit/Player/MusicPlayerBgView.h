//
//  MusicPlayerBgView.h
//  iThunder
//
//  Created by omgder on 15/7/9.
//  Copyright (c) 2015年 xunlei.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayerBgView : UIView
@property(nonatomic, assign) CGFloat speed;



- (void)stop;
- (void)restart;
@end
