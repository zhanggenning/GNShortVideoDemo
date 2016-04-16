//
//  PKVideoInfo.m
//  TDPlayerKit
//
//  Created by lucky.li on 14/12/26.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKVideoInfo.h"
#import "PKStreamSlice.h"
#import "NSString+pk.h"

#pragma mark -

/// M3U8缓存目录路径
static NSString *const kM3U8CacheDirSubPath = @"PKCaches/M3U8";

/// M3U8缓存文件名
static NSString *const kM3U8CacheFileName = @"Temp.m3u8";

#pragma mark -
@interface PKVideoInfo ()

@property (assign, nonatomic) PKVideoContentType contentType;

- (NSString *)cacheIntoFileWithM3U8String:(NSString *)m3u8String;

@end

#pragma mark -
@implementation PKVideoInfo

- (void)setContentURLString:(NSString *)contentURLString {
    _contentURLString = contentURLString;
    
    if (self.contentURLString.isOnlinePath) {
        self.contentType = kVideoContentTypeOnlineURLString;
    } else {
        self.contentType = kVideoContentTypeLocalURLString;
    }
}

- (void)setContentStreamSlices:(NSArray *)contentStreamSlices {
    _contentStreamSlices = contentStreamSlices;
    
    PKStreamSlice *slice0 = self.contentStreamSlices.firstObject;
    if (slice0.urlString.isOnlinePath) {
        self.contentType = kVideoContentTypeOnlineStreamSlices;
    } else {
        self.contentType = kVideoContentTypeLocalStreamSlices;
    }
}

#pragma mark - Public

+ (NSString *)m3u8StringForStreamSlices:(NSArray *)streamSlices {
    NSInteger durationInSeconds = 0;
    NSMutableString *content = [NSMutableString string];
    
    for (PKStreamSlice *slice in streamSlices) {
        durationInSeconds += slice.durationInSeconds;
        [content appendFormat:@"\n#EXTINF:%ld,\n%@", (long)slice.durationInSeconds, slice.urlString];
    }
    
    NSString *m3u8String = [NSString stringWithFormat:@"%@\n%@%@\n%@",
                            @"#EXTM3U",
                            [NSString stringWithFormat:@"#EXT-X-TARGETDURATION:%ld", (long)durationInSeconds],
                            content,
                            @"#EXT-X-ENDLIST"];
    
    return m3u8String;
}

- (NSString *)playContentURLString {
    if (self.contentType == kVideoContentTypeLocalURLString ||
        self.contentType == kVideoContentTypeOnlineURLString) {
        return self.contentURLString;
    } else if (self.contentType == kVideoContentTypeLocalStreamSlices ||
               self.contentType == kVideoContentTypeOnlineStreamSlices) {
        NSString *m3u8String = [self.class m3u8StringForStreamSlices:self.contentStreamSlices];
        NSString *path = [self cacheIntoFileWithM3U8String:m3u8String];
        return path;
    } else {
        return nil;
    }
}

- (BOOL)isOnlineVideo {
    if (self.contentType == kVideoContentTypeOnlineURLString ||
        self.contentType == kVideoContentTypeOnlineStreamSlices) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasVideo {
    return (self.videoFormatInfoArray.count > 0);
}

#pragma mark - Private

- (NSString *)cacheIntoFileWithM3U8String:(NSString *)m3u8String {
    NSString *cacheDirPath = [NSString cachePathWithSubPath:kM3U8CacheDirSubPath];
    NSString *cacheFilePath = [cacheDirPath stringByAppendingPathComponent:kM3U8CacheFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = NO;
    BOOL exist = [fileManager fileExistsAtPath:cacheDirPath isDirectory:&isDir];
    if (exist && !isDir) {
        BOOL result = [fileManager removeItemAtPath:cacheDirPath error:&error];
        if (!result) {
            NSAssert(NO, @"[ERROR]: Delete cache file error!\n%@", error);
            return nil;
        }
        exist = NO;
    }
    if (!exist) {
        BOOL result = [fileManager createDirectoryAtPath:cacheDirPath
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
        if (!result) {
            NSAssert(NO, @"[ERROR]: Create cache dir error!\n%@", error);
            return nil;
        }
    }
    
    BOOL result = [m3u8String writeToFile:cacheFilePath
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
    if (!result) {
        NSAssert(NO, @"[ERROR]: Write cache file error!\n%@", error);
        return nil;
    }
    
    return cacheFilePath;
}

@end
