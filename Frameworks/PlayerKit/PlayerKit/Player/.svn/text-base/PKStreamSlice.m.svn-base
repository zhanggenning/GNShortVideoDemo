//
//  PKStreamSlice.m
//  TDPlayerKit
//
//  Created by lucky.li on 14/12/25.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKStreamSlice.h"

#pragma mark -

static NSString *const kDurationKey = @"duration_in_seconds_key";
static NSString *const kUrlKey = @"url_key";

#pragma mark -
@implementation PKStreamSlice

+ (PKStreamSlice *)sliceFromDictionary:(NSDictionary *)dic {
    PKStreamSlice *slice = [[PKStreamSlice alloc] init];
    slice.durationInSeconds = [dic[kDurationKey] integerValue];
    slice.urlString = dic[kUrlKey];
    return slice;
}

- (NSDictionary *)dictionaryFromSlice {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @(self.durationInSeconds), kDurationKey,
            (self.urlString.length==0)?@"":self.urlString, kUrlKey,
            nil];
}

@end
