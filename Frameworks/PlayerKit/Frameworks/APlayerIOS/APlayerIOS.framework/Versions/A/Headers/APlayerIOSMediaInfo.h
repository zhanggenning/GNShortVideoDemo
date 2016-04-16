//
//  APlayerIOSMediaInfo.h
//  APlayerIOS
//
//  Created by xlxmp on 15/3/6.
//  Copyright (c) 2015年 APlayerIOS XunLei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APlayerIOSMediaInfo : NSObject

+ (APlayerIOSMediaInfo *) mediaInfoWithFile: (NSString *)path;

- (uint64_t) getDuration;

@end
