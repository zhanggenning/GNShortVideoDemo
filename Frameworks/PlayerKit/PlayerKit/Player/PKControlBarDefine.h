//
//  PKControlBarDefine.h
//  PlayerKit
//
//  Created by zhanggenning on 16/4/19.
//  Copyright © 2016年 xunlei. All rights reserved.
//

#ifndef PKControlBarDefine_h
#define PKControlBarDefine_h

//播放按钮状态
typedef NS_ENUM(NSInteger, PKVideoControlBarPlayState)
{
    kVideoControlBarPlay = 0,  //播放图片
    kVideoControlBarPause,     //暂停图片
    kVideoControlBarBuffering  //缓冲图片
};

//常规按钮状态
typedef NS_ENUM(NSInteger, PKVideoControlFullScreenState) {
    
    kVideoControlBarFullScreen = 0,//全屏图片
    kVideoControlBarNormal         //正常图片
};

#endif /* PKControlBarDefine_h */
