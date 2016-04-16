//
//  PKSubtitleSource.h
//  PlayerKit
//
//  Created by lucky.li on 15/4/3.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKEnum.h"
#import "PKSubtitleInfo.h"

#pragma mark -

/// 加载字幕列表完成回调
typedef void (^loadSubtitleListCompletionBlock) (NSArray *subtitleList);

/// 加载字幕路径完成回调
typedef void (^loadSubtitlePathCompletionBlock) (PKSubtitleInfo *subtitleInfo);

#pragma mark -
@interface PKSubtitleSource : NSObject

@property (copy, nonatomic) PKDisplayMode (^subtitleDisplayModeBlock) (void);
@property (copy, nonatomic) NSInteger (^currentSubtitleIndexBlock) (NSInteger embeddedSubtitleIndex);
@property (copy, nonatomic) void (^loadSubtitleListBlock) (NSArray *embeddedSubtitles,
loadSubtitleListCompletionBlock completionBlock);
@property (copy, nonatomic) void (^subtitleIndexChangedBlock) (NSInteger newSubtitleIndex);
@property (copy, nonatomic)void (^loadSubtitleInfoBlock) (NSInteger subtitleIndex,
NSArray *embeddedSubtitles,
loadSubtitlePathCompletionBlock completionBlock);

@end
