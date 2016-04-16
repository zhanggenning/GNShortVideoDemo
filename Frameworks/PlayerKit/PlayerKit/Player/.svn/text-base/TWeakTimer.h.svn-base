//
//  TWeakTimer.h
//  TestModels
//
//  Created by luckyli on 14/11/17.
//  Copyright (c) 2014年 luckyli. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - TTimerContainer

@interface TTimerContainer : NSObject

/// init
+ (TTimerContainer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                             target:(id)aTarget
                                           selector:(SEL)aSelector
                                           userInfo:(id)userInfo
                                            repeats:(BOOL)yesOrNo;

/// remove
- (void)removeTimer;

@end

#pragma mark - TWeakTimer

/********************************************************************************
 *  ##### 重要提示 #####
 *  TWeakTimer在实例被释放的时候移除Timer
 *  TWeakTimer会使多线程的runloop一直运行，释放TWeakTimer后才能结束runloop，但是runloop
 *  结束之后才能释放autoreleasepool，所以在多线程不要轻易把TWeakTimer加到autoreleasepool，
 *  多线程使用TWeakTimer必须确保[runloop run]调用的时候TWeakTimer不在autoreleasepool
 *******************************************************************************/

@interface TWeakTimer : NSObject

/// init
- (instancetype)initWithTimeInterval:(NSTimeInterval)ti
                              target:(id)aTarget
                            selector:(SEL)aSelector
                            userInfo:(id)userInfo
                             repeats:(BOOL)yesOrNo;

@end
