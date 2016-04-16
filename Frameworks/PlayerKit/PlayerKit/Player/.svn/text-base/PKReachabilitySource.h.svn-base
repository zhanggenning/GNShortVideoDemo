//
//  PKReachabilitySource.h
//  PlayerKit
//
//  Created by lucky.li on 15/5/11.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

/// 网络状况类型
typedef NS_ENUM(NSInteger, PKNetworkStatus) {
    KNetworkStatusNotReachable=0,       // 未连接
    KNetworkStatusReachableViaWiFi,     // wifi
    KNetworkStatusReachableViaWWAN,     // wwan
};

/// 网络状况改变回调
typedef void (^reachabilityChangedCallbackBlock) (PKNetworkStatus status);

#pragma mark -
@interface PKReachabilitySource : NSObject

@property (copy, nonatomic) void (^reachabilityChangedBlock) (reachabilityChangedCallbackBlock callbackBlock);
@property (copy, nonatomic) PKNetworkStatus (^currentNetworkStatus) ();

@end
