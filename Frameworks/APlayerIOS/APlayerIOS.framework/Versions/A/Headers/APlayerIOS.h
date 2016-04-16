//
//  APlayerIOS.h
//  APlayerIOS
//
//  Created by LiuHb on 14-2-24.
//  Copyright (c) 2014年 APlayerIOS XunLei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APlayerIOS;


#pragma mark - APlayerIOS Delegate
@protocol APlayerIOSDelegate <NSObject>

@optional

- (void) player:(APlayerIOS *)player OnStateChanged:(NSInteger)nOldState nNewState:(NSInteger)nNewState;

- (void) OnOpenSucceeded:(APlayerIOS *)player;

- (void) player:(APlayerIOS *)player OnSeekCompleted:(NSInteger)nPosition;

- (void) player:(APlayerIOS *)player OnBufferProgress:(CGFloat)nProgress;

- (void) player:(APlayerIOS *)player OnEvent:(NSInteger)nEventCode nEventParam:(NSInteger)nEventParam;

@end


#pragma mark - APlayerIOS Interface
@interface APlayerIOS: NSObject

@property (weak, nonatomic) id<APlayerIOSDelegate> delegate;

- (APlayerIOS *) Init: (UIView *)APlayerView;

- (void) SetView: (UIView *)videoView;

- (NSInteger) Open: (NSString *)strURL;

- (NSInteger) Close;

- (NSInteger) Play;

- (NSInteger) Pause;

- (NSString *) GetVersion;

- (NSInteger) GetState;

- (NSInteger) GetDuration;

- (NSInteger) GetPosition;
- (NSInteger) SetPosition: (NSInteger)nPosition;  //ms

- (NSInteger) GetVideoWidth;
- (NSInteger) GetVideoHeight;

- (BOOL) IsSeeking;

- (NSInteger) GetBufferProgress;

- (NSString *) GetConfig: (NSInteger)nConfigId;

- (NSInteger) SetConfig: (NSInteger)nConfigId
               strValue: (NSString *)strValue;

@end


#pragma mark - APlayerIOS ConfigID
//----------------------------------------------------------------------------------------------------------------------------------------------
//   ConfigID                               Type        Read/Write      Description
//----------------------------------------------------------------------------------------------------------------------------------------------

#define CONFIGID_CURRENTURL          4      //str,         R,          //Media URL when current play
#define CONFIGID_FILESIZE            5      //int64,       R,          //Media file size

#define CONFIGID_PLAYRESULT          7      //int,         R,          //Play Result, 0-play complete, 1-manual close,
                                            //error code:0x8xxxxxxx    error code:(0x80000001:OpenFileError),(0x80000002:OpeningError),(0x80000003:NotReachable断网)

#define CONFIGID_READSIZE            29     //int,         R,          //Read Size, unit:byte

#define CONFIGID_READPOSITION        31     //int,         R,          //Read Position, unit:ms

#define CONFIGID_MEDIAINFO           34     //str,         R,          //Media info,

#define CONFIGID_SPEEDUPENABLE       209    //int,         R,W,        //video speedup, 1-enable, 0-disable
#define CONFIGID_SPEEDUPSTATUS       211    //int,         R,          //query staus, 1-okay, 0-none
#define CONFIGID_SPEEDUPQUERY        212    //str,         R,          //query speedup mode that current used, return "system", if no speedup, return ""

#define CONFIGID_VIEWMODE            251    //str,         R,W,        //View Content Mode, 0-UIViewContentModeScaleAspectFit,
                                            //                         //                   1-UIViewContentModeScaleAspectFill,

#define CONFIGID_AUDIOPROCESSUSABLE  401    //int,         R,          //audio function usable, 1-usable
#define CONFIGID_AUDIOTRACKLIST      402    //int,         R,          //Audio track list, split by";", example:"chinese;english"
#define CONFIGID_AUDIOTRACKCURRENT   403    //int,         R,W,        //Current selected audio track index, select 0, ..., count - 1


#define CONFIGID_SUBTITLEUSABLE      501    //int,         R           //Query subtitle function is usable, 1-usable
#define CONFIGID_SUBTITLEEXTNAMELIST 502    //str,         R           //Subtitle extname list that supported, example:"srt;ass"
#define CONFIGID_SUBTITLEFILENAME    503    //str,         R,W,        //Subtitle filename, example:"/var/mobile/.../subtitle.srt"
#define CONFIGID_SUBTITLESHOW        504    //int,         R,W,        //Subtitle visible, 1-show, 0-hide, default:1
#define CONFIGID_SUBTITLELIST        505    //str,         R           //Subtitle list, split by";", example:"chinese;english"
#define CONFIGID_SUBTITLESELECTED    506    //int,         R,W,        //Subtitle selected, select -1, 0, ..., count - 1, count(external subtitle)

#define CONFIGID_NETWORK_BUFFERLEAVE 1002   //int,         R,W,        //Network buffer leave, prebuffer packets size to leave buffering, default:0.5MB
#define CONFIGID_NETWORK_NOBUFFERDRY 1003   //int,         R,W,        //Network bobuffer dry, drying packets size when no buffer, default:5MB

#define CONFIGID_VALID_AUDIOVIDEO    1199   //int,         R,          //audio: 1; video: 2




