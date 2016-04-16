//
//  TWeakTimer.m
//  TestModels
//
//  Created by luckyli on 14/11/17.
//  Copyright (c) 2014年 luckyli. All rights reserved.
//

#import "TWeakTimer.h"

#pragma mark - TTimerContainer

#pragma mark -
@interface TTimerContainer ()

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) id timerTarget;
@property (nonatomic, assign) SEL timerSelector;

- (void)timerAction:(id)sender;

@end

#pragma mark -
@implementation TTimerContainer

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Public

+ (TTimerContainer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                             target:(id)aTarget
                                           selector:(SEL)aSelector
                                           userInfo:(id)userInfo
                                            repeats:(BOOL)yesOrNo {
    TTimerContainer *container = [[TTimerContainer alloc] init];
    container.timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                       target:container
                                                     selector:@selector(timerAction:)
                                                     userInfo:userInfo
                                                      repeats:yesOrNo];
    container.timerTarget = aTarget;
    container.timerSelector = aSelector;
    return container;
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Private

- (void)timerAction:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    /// 忽略ARC编译warning
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
    if (self.timerTarget && [self.timerTarget respondsToSelector:self.timerSelector]) {
        [self.timerTarget performSelector:self.timerSelector withObject:sender];
    }
    _Pragma("clang diagnostic pop")
}

@end

#pragma mark - TWeakTimer

#pragma mark -
@interface TWeakTimer ()

@property (nonatomic, weak) TTimerContainer *timerContainer;

/// remove
- (void)removeWeakTimer;

@end

#pragma mark -
@implementation TWeakTimer

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
    [self removeWeakTimer];
}

#pragma mark - Public

/// init
- (instancetype)initWithTimeInterval:(NSTimeInterval)ti
                              target:(id)aTarget
                            selector:(SEL)aSelector
                            userInfo:(id)userInfo
                             repeats:(BOOL)yesOrNo {
    self = [super init];
    if (self) {
        self.timerContainer =
        [TTimerContainer scheduledTimerWithTimeInterval:ti
                                                 target:aTarget
                                               selector:aSelector
                                               userInfo:userInfo
                                                repeats:yesOrNo];
    }
    return self;
}

#pragma mark - Private

- (void)removeWeakTimer {
    if (self.timerContainer) {
        [self.timerContainer removeTimer];
        self.timerContainer = nil;
    }
}

@end
