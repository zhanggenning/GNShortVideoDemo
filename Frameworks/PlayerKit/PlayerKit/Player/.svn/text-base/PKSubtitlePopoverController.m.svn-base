//
//  PKSubtitlePopoverController.m
//  PlayerKit
//
//  Created by lucky.li on 15/4/3.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKSubtitlePopoverController.h"

#pragma mark -
@interface PKSubtitlePopoverController ()

/// 初始化Popover默认属性
- (void)initDefaultPopoverProperties;

@end

#pragma mark -
@implementation PKSubtitlePopoverController

- (id)initWithContentViewController:(UIViewController *)theContentViewController {
    if (self=[super initWithContentViewController:theContentViewController]) {
        [self initDefaultPopoverProperties];
    }
    return self;
}

#pragma mark - Private

- (void)initDefaultPopoverProperties {
    WEPopoverContainerViewProperties *properties = [WEPopoverController defaultContainerViewProperties];
    properties.upArrowImageName = @"pk_subtitle_popover_up_arrow.png";
    properties.downArrowImageName = nil;
    properties.arrowMargin = 0;
    properties.bgImageName = @"pk_subtitle_popover_background.png";
    properties.leftBgCapSize = 0;
    properties.topBgCapSize = 0;
    properties.leftBgMargin = 0;
    properties.rightBgMargin = 2;
    properties.topBgMargin = 0;
    properties.bottomBgMargin = 0;
    properties.leftContentMargin = 2;
    properties.rightContentMargin = 2-2;
    properties.topContentMargin = 2;
    properties.bottomContentMargin = 2;
    self.containerViewProperties = properties;
}

@end