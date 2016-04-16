//
//  PKStreamSlice.h
//  TDPlayerKit
//
//  Created by lucky.li on 14/12/25.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKStreamSlice : NSObject

@property (strong, nonatomic) NSString *urlString;
@property (assign, nonatomic) NSInteger durationInSeconds;

+ (PKStreamSlice *)sliceFromDictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionaryFromSlice;

@end
