//
//  PKRecordSource.h
//  PlayerKit
//
//  Created by lucky.li on 15/3/20.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKRecordSource : NSObject

@property (copy, nonatomic) NSInteger (^lastPlayPositionBlock) (void);
@property (copy, nonatomic) void (^playCompletionBlock) (NSInteger playPositionInMS, BOOL finished);

@end
