//
//  NSObject+pk.m
//  PlayerKit
//
//  Created by lucky.li on 15/1/19.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "NSObject+pk.h"

@implementation NSObject (pk)

+ (void)asyncTaskWithBlock:(dispatch_block_t)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

+ (void)asyncTaskWithBlock:(dispatch_block_t)block delay:(NSTimeInterval)delayInSeconds {
    dispatch_time_t delayInNS = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNS, queue, block);
}

+ (void)asyncTaskOnMainWithBlock:(dispatch_block_t)block {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, block);
}

+ (void)asyncTaskOnMainWithBlock:(dispatch_block_t)block delay:(NSTimeInterval)delayInSeconds {
    dispatch_time_t delayInNS = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_after(delayInNS, queue, block);
}

+ (void)syncTaskOnMainWithBlock:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_sync(queue, block);
    }
}

@end
