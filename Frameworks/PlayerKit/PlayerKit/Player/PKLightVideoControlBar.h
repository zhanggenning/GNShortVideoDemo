//
//  PKLightVideoControlBar.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/19.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKControlBarProtocol.h"

@interface PKLightVideoControlBar : UIView <PKControlBarProtocol>

@property (nonatomic, weak) id<PKControlBarEventProtocol> delegate;

+ (id<PKControlBarProtocol>)nibInstance;

@end
