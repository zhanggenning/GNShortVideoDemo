//
//  PKLightVideoFullScreenControlBar.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/21.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKControlBarProtocol.h"

@interface PKLightVideoFullScreenControlBar : UIView <PKControlBarProtocol>

@property (nonatomic, weak) id<PKControlBarEventProtocol> delegate;

@end
