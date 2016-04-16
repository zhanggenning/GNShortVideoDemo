//
//  NSString+pk.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/16.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (pk)

/// 根据subPath返回程序Document目录下该subPath的路径: ~/Document/subPath
+ (NSString *)docPathWithSubPath:(NSString *)subPath;

/// 根据subPath返回程序缓存目录下该subPath的路径: ~/Libraty/Caches/subPath
+ (NSString *)cachePathWithSubPath:(NSString *)subPath;

/// 根据subPath返回程序tmp目录下该subPath的路径: ~/tmp/subPath
+ (NSString *)tmpPathWithSubPath:(NSString *)subPath;

/// 是否是在线路径
- (BOOL)isOnlinePath;

- (id)jsonFormat;

@end
