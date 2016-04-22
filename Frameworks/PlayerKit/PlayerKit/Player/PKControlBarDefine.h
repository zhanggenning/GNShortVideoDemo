//
//  PKControlBarDefine.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/19.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#ifndef PKControlBarDefine_h
#define PKControlBarDefine_h

//控制栏的类型
typedef NS_ENUM(NSInteger, PKVideoControlBarStyle)
{
    kVideoControlBarBase = 0, //基本类型
    kVideoControlBarFull,     //全功能类型
};

//播放按钮状态
typedef NS_ENUM(NSInteger, PKVideoControlBarPlayState)
{
    kVideoControlBarPlay = 0,  //播放图片
    kVideoControlBarPause,     //暂停图片
    kVideoControlBarBuffering  //缓冲图片
};

#endif /* PKControlBarDefine_h */
