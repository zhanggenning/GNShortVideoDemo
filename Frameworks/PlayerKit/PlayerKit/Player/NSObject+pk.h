//
//  NSObject+pk.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/19.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (pk)

+ (void)asyncTaskWithBlock:(dispatch_block_t)block;

+ (void)asyncTaskWithBlock:(dispatch_block_t)block delay:(NSTimeInterval)delayInSeconds;

+ (void)asyncTaskOnMainWithBlock:(dispatch_block_t)block;

+ (void)asyncTaskOnMainWithBlock:(dispatch_block_t)block delay:(NSTimeInterval)delayInSeconds;

+ (void)syncTaskOnMainWithBlock:(dispatch_block_t)block;

@end
