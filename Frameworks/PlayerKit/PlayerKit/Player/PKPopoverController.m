//
//  PKPopoverController.m
//  PlayerKit
//
//  Created by lucky.li on 15/3/24.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKPopoverController.h"

#pragma mark -
@interface PKPopoverController ()

/// 初始化Popover默认属性
- (void)initDefaultPopoverProperties;

@end

#pragma mark -
@implementation PKPopoverController

- (id)initWithContentViewController:(UIViewController *)theContentViewController {
    if (self=[super initWithContentViewController:theContentViewController]) {
        [self initDefaultPopoverProperties];
    }
    return self;
}

#pragma mark - Private

- (void)initDefaultPopoverProperties {
    WEPopoverContainerViewProperties *properties = [WEPopoverController defaultContainerViewProperties];
    properties.upArrowImageName = nil;
    properties.downArrowImageName = @"pk_popover_down_arrow.png";
    properties.arrowMargin = 0;
    properties.bgImageName = @"pk_popover_background.png";
    properties.leftBgCapSize = 0;
    properties.topBgCapSize = 3;
    properties.leftBgMargin = 0;
    properties.rightBgMargin = 0;
    properties.topBgMargin = 1;
    properties.bottomBgMargin = 1;
    properties.leftContentMargin = 2;
    properties.rightContentMargin = 2;
    properties.topContentMargin = 2;
    properties.bottomContentMargin = 2;
    self.containerViewProperties = properties;
}

@end
