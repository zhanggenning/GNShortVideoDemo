//
//  PKLightVideoProcessIndicator.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PKLightVideoIndicatorType)
{
    kLightVideoIndicatorTime  = 0,  //时间
    kLightVideoIndicatorVolume,     //音量
    kLightVideoIndicatorBrightness  //亮度
};

@interface PKLightVideoProcessIndicator : UIView


//userInfo定义:
//时间key: "timeStr"（时间）, "isRewind"（是否是快进）;
//音量key: nil
//亮度: nil
- (void)showWithIndicatorType:(PKLightVideoIndicatorType)type
                      process:(CGFloat)process
                     userInfo:(NSDictionary *)userInfo;

@end
