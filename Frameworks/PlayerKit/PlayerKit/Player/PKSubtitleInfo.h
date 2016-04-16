//
//  PKSubtitleInfo.h
//  PlayerKit
//
//  Created by lucky.li on 15/4/13.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

/// 字幕类型
typedef NS_ENUM(NSInteger, PKSubtitleType) {
    kSubtitleTypeNone=0,    // 无字幕
    kSubtitleTypeEmbedded,  // 内嵌字幕
    kSubtitleTypeExternal,  // 外挂字幕
};

#pragma mark -
@interface PKSubtitleInfo : NSObject

@property (assign, nonatomic) PKSubtitleType type;
@property (assign, nonatomic) NSInteger embeddedSubtitleIndex;
@property (copy, nonatomic) NSString *externalSubtitlePath;

@end
