//
//  PKResolutionSource.h
//  PlayerKit
//
//  Created by lucky.li on 15/3/24.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKEnum.h"

#pragma mark -
@interface PKResolutionSource : NSObject

@property (copy, nonatomic) PKDisplayMode (^resolutionDisplayModeBlock) (void);
@property (copy, nonatomic) NSInteger (^currentResolutionIndexBlock) (void);
@property (copy, nonatomic) NSArray * (^availableResolutionTitleArrayBlock) (void);
@property (copy, nonatomic) void (^resolutionIndexChangedBlock) (NSInteger newResolutionIndex);
@property (copy, nonatomic) NSInteger (^nextResolutionIndexForAutoSwitchBlock) (void);

@end
