//
//  NSString+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/16.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "NSString+pk.h"

@implementation NSString (pk)

+ (NSString *)docPathWithSubPath:(NSString *)subPath {
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [docPath stringByAppendingPathComponent:subPath];
    return path;
}

+ (NSString *)cachePathWithSubPath:(NSString *)subPath {
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path=[cachePath stringByAppendingPathComponent:subPath];
    return path;
}

+ (NSString *)tmpPathWithSubPath:(NSString *)subPath {
	NSString *tmpPath = NSTemporaryDirectory();
    NSString *path = [tmpPath stringByAppendingPathComponent:subPath];
    return path;
}

- (BOOL)isOnlinePath {
    NSRange range = [self rangeOfString:@":"];
    if (range.location == NSNotFound) {
        return NO;
    }
    
    if ([self hasPrefix:@"file://"]) {
        return NO;
    }
    
    return YES;
}

- (id)jsonFormat {
    NSError* error = nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingAllowFragments
                                                  error:&error];
    if (error) {
        NSLog(@"[ERROR]: String: %@\nJson error: %@\n%s", self, error, __FUNCTION__);
    }
    return result;
}

@end
