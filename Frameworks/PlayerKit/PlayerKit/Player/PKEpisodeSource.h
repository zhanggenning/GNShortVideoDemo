//
//  PKEpisodeSource.h
//  PlayerKit
//
//  Created by lucky.li on 15/3/30.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKEnum.h"

#pragma mark -

/// 选集cell类型
typedef NS_ENUM(NSInteger, PKEpisodeCellType) {
    kEpisodeCellTypeMutilEpisode=0,     // 一行多集显示
    kEpisodeCellTypeSingleEpisode,      // 一行单集显示
};

#pragma mark -
@interface PKEpisodeSource : NSObject

@property (copy, nonatomic) PKDisplayMode (^episodeDisplayModeBlock) (void);
@property (copy, nonatomic) PKEpisodeCellType (^episodeCellTypeBlock) (void);
@property (copy, nonatomic) NSString * (^episodeTitleBlock) (void);
@property (copy, nonatomic) NSInteger (^currentEpisodeIndexBlock) (void);
@property (copy, nonatomic) NSArray * (^availableEpisodeTitleArrayBlock) (void);
@property (copy, nonatomic) void (^episodeIndexChangedBlock) (NSInteger newEpisodeIndex);
@property (copy, nonatomic) NSInteger (^nextEpisodeIndexForAutoSwitchBlock) (void);

@end
