//
//  PKProgressDescriptionView.h
//  PlayerKit
//
//  Created by lucky.li on 15/1/15.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKProgressDescriptionView : UIView

/// init: 根据xib初始化
+ (instancetype)nibInstance;

/**
 *  显示描述语
 *
 *  @param description 描述语
 *  @param center      中心位置
 *  @param autoHide    是否在显示一小段时间后自动隐藏
 */
- (void)showDescription:(NSString *)description withCenter:(CGPoint)center autoHide:(BOOL)autoHide;

@end
