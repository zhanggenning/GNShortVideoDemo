//
//  PKVideoPlayerViewController.m
//  TDPlayerDemo
//
//  Created by lucky.li on 14/12/22.
//  Copyright (c) 2014年 xunlei. All rights reserved.
//

#import "PKVideoPlayerViewController.h"
#import "PKVideoPlayerCoreBase.h"
#import "NSBundle+pk.h"
#import "PKSlider.h"
#import "PKVideoInfo.h"
#import "MBProgressHUD.h"
#import "UIDevice+pk.h"
#import "TWeakTimer.h"
#import "PKProgressDescriptionView.h"
#import "NSObject+pk.h"
#import "UIImage+pk.h"
#import "UIScreen+pk.h"
#import "PKPopoverController.h"
#import "PKResolutionViewController.h"
#import "PKMutilEpisodeCell.h"
#import "PKSingleEpisodeCell.h"
#import "UIColor+pk.h"
#import "PKAudioTrackViewController.h"
#import "PKSubtitleViewController.h"
#import "PKSubtitleInfo.h"
#import "PKGuideViewController.h"

#import "PKSourceManager.h"
#import "PKRecordSource.h"
#import "PKTitleSource.h"
#import "PKResolutionSource.h"
#import "PKEpisodeSource.h"
#import "PKSubtitleSource.h"
#import "PKPlayerStatusSource.h"
#import "PKStatisticSource.h"
#import "PKReachabilitySource.h"
#import "PKDLNASource.h"

#import "PKLoading.h"
#import "PKProgressIndicator.h"
#import "PKTip.h"


#import "PKVideoPlayerViewController.h"
#import "PKMusicPlayViewController.h"

#pragma mark -

/// 开始播放通知
NSString *const kPKPlayerStartPlayingNotification = @"pk_player_start_playing_notification";

/// 结束播放通知
NSString *const kPKPlayerFinishPlayingNotification = @"pk_player_finish_playing_notification";

/// （开始／结束）播放通知视频信息数据的key
NSString *const kPKPlayerNotificationVideoInfoKey = @"video_info_key";

/// 错误提示框tag
static const NSInteger kErrorAlertTag = 0xff00ff00;

/// 移动网络提示框tag
static const NSInteger kWWANAlertTag = 0xff00ff01;

/// 上下移动
static const CGFloat kMaxYDistanceForVPanGesture = 300.0;
static const CGFloat kMinPercentForLeftVPanGesture = 0.01;
static const CGFloat kMinPercentForRightVPanGesture = 0.05;
static const CGFloat kMaxXDistanceForVPanGesture = 15.0;

/// 左右移动
static const CGFloat kMaxYDistanceForHPanGesture = 15.0;

/// 左右移动seek
static const NSInteger kMaxTimeForHSeekingInMS = 1000*60*5;
static const NSInteger kMinTimeForHSeekingInMS = 1000*0.5;

static NSString *const kMutilEpisodeCellIdentifier = @"mutil_episode_cell_identifier";
static NSString *const kSingleEpisodeCellIdentifier = @"single_episode_cell_identifier";

/// 显示引导页key
static NSString *const kGuideKey = @"pk_guide_key";

/// 播放器界面显示模式
typedef NS_ENUM(NSInteger, PKPlayerViewDisplayMode) {
    kPlayerViewDisplayModeShowControlOnly=0,        // 只显示控制界面
    kPlayerViewDisplayModeShowEpisodeOnly,          // 只显示选集界面
    kPlayerViewDisplayModeShowSubtitleOnly,         // 只显示字幕界面
    kPlayerViewDisplayModeShowAudioTrackOnly,       // 只显示音轨界面
    kPlayerViewDisplayModeShowHeaderControlOnly,    // 只显示顶部控制界面
    kPlayerViewDisplayModeHideAll,                  // 全部隐藏
};

#pragma mark -
@interface PKVideoPlayerViewController () <PKVideoPlayerCoreDelegate, PKSliderDelegate, UIAlertViewDelegate, WEPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, PKMutilEpisodeCellDelegate>

@property (assign, nonatomic) BOOL isVideoViewLoaded;
@property (assign, nonatomic) BOOL isInitPlayDone;
@property (copy, nonatomic) void (^showErrorCompletionBlock) ();
@property (copy, nonatomic) void (^showWWANAlertCompletionBlock) (BOOL cancel);
@property (assign, nonatomic) BOOL needResumePlayWhenActive;
@property (assign, nonatomic) PKPlayerViewDisplayMode currentPlayerViewDisplayMode;
@property (assign, nonatomic) BOOL isChangingPlayerViewDisplayMode;
@property (assign, nonatomic) BOOL isStatusBarHidden;
@property (assign, nonatomic) UIStatusBarAnimation statusBarUpdateAnimation;
@property (strong, nonatomic) TWeakTimer *autoHideControlTimer;
@property (assign, nonatomic) CGPoint preLocationForPanGesture;
@property (assign, nonatomic) BOOL isHPanGestureRecognized;
@property (assign, nonatomic) BOOL isLeftVPanGestureRecognized;
@property (assign, nonatomic) BOOL isRightVPanGestureRecognized;
@property (assign, nonatomic) BOOL isShowingLoading;
@property (strong, nonatomic) PKPopoverController *resolutionPController;
@property (strong, nonatomic) PKAudioTrackViewController *audioTrackVC;
@property (strong, nonatomic) PKSubtitleViewController *subtitleVC;
@property (assign, nonatomic) BOOL bufferHasBeenFull;
@property (strong, nonatomic) UIImage *volumeImage;
@property (strong, nonatomic) UIImage *muteImage;
@property (strong, nonatomic) PKGuideViewController *guideVC;
@property (assign, nonatomic) BOOL isDLNAPlaying;
@property (strong, nonatomic) UIViewController *dlnaDeviceVC;
@property (strong, nonatomic) UIViewController *dlnaPlayingTipVC;
@property (assign, nonatomic) BOOL needResumePlayAfterDLNA;
@property (assign, nonatomic) NSInteger displayProgressInMS;
@property (strong, nonatomic) PKMusicPlayViewController *musicBgVc;

@property (weak, nonatomic) IBOutlet UIView *holder;
@property (weak, nonatomic) IBOutlet UIView *gestureHolder;
@property (weak, nonatomic) IBOutlet UIView *loadingHolder;
@property (weak, nonatomic) IBOutlet UIView *progressIndicatorHolder;
@property (weak, nonatomic) IBOutlet UIView *tipHolder;
@property (weak, nonatomic) IBOutlet UIView *headerHolder;
@property (weak, nonatomic) IBOutlet UIView *bottomHolder;
@property (weak, nonatomic) IBOutlet UIView *brightnessHolder;
@property (weak, nonatomic) IBOutlet UIView *volumeHolder;
@property (weak, nonatomic) IBOutlet UIView *progressSliderHolder;
@property (weak, nonatomic) IBOutlet UIView *landscapeBrightnessSliderHolder;
@property (weak, nonatomic) IBOutlet UIView *landscapeVolumeSliderHolder;
@property (weak, nonatomic) IBOutlet UIView *episodeHolder;
@property (weak, nonatomic) IBOutlet UIView *subtitleHolder;
@property (weak, nonatomic) IBOutlet UIView *audioTrackHolder;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *audioTrackBtn;
@property (weak, nonatomic) IBOutlet UIButton *dlnaBtn;
@property (weak, nonatomic) IBOutlet UIButton *subtitleBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *resolutionBtn;
@property (weak, nonatomic) IBOutlet UIButton *episodeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *brightnessBgView;
@property (weak, nonatomic) IBOutlet UIImageView *volumeBgView;
@property (weak, nonatomic) IBOutlet UILabel *episodeTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *episodeTableView;
@property (weak, nonatomic) IBOutlet UIImageView *volumeLogoView;

@property (weak, nonatomic) PKSlider *progressSlider;
@property (weak, nonatomic) PKSlider *landscapeBrightnessSlider;
@property (weak, nonatomic) PKSlider *landscapeVolumeSlider;
@property (weak, nonatomic) PKProgressDescriptionView *progressDescriptionView;
@property (weak, nonatomic) PKLoading *loadingView;
@property (weak, nonatomic) PKProgressIndicator *progressIndicatorView;
@property (weak, nonatomic) PKTip *tipView;

- (IBAction)quitBtnAction:(id)sender;
- (IBAction)audioTrackBtnAction:(id)sender;
- (IBAction)dlnaBtnAction:(id)sender;
- (IBAction)subtitleBtnAction:(id)sender;
- (IBAction)playBtnAction:(id)sender;
- (IBAction)nextBtnAction:(id)sender;
- (IBAction)resolutionBtnAction:(id)sender;
- (IBAction)episodeBtnAction:(id)sender;

- (void)initNotifications;
- (void)removeNotifications;
- (void)initLoadView;
- (void)initVideoView;
- (void)initPlay;
- (void)initGestures;
- (void)doInit;
- (void)resetInit;
- (void)initTitle;
- (void)initResolution;
- (void)initEpisode;
- (void)initSubtitle;
- (void)initDefaultSubtitleSource;
- (void)initReachability;
- (void)initDLNA;
- (void)initAudioTrack;
- (void)initAudioView;
- (void)hideAudioView;

- (void)tapGestureAction:(UITapGestureRecognizer *)sender;
- (void)doubleTapGestureAction:(UITapGestureRecognizer *)sender;
- (void)doubleTouchTapGestureAction:(UITapGestureRecognizer *)sender;
- (void)swipeGestureAction:(UISwipeGestureRecognizer *)sender;
- (void)panGestureAction:(UIPanGestureRecognizer *)sender;
- (void)longPressGestureAction:(UILongPressGestureRecognizer *)sender;

- (void)resignActiveNotification:(NSNotification *)notification;
- (void)becomeActiveNotification:(NSNotification *)notification;
- (void)switchToPausedStatus:(BOOL)switchToPaused;
- (void)doQuit;
- (void)doRewind;
- (void)doFastForward;
- (void)switchWithResolutionIndex:(NSInteger)resolutionIndex;
- (BOOL)switchToNextResolutionIfNeeded;
- (void)switchWithEpisodeIndex:(NSInteger)episodeIndex;
- (BOOL)switchToNextEpisodeIfNeeded;
- (void)switchToFillDisplayMode:(BOOL)switchToFill;
- (void)displayWithHeaderControlHidden:(BOOL)headerControlHidden
                    otherControlHidden:(BOOL)otherControlHidden
                         episodeHidden:(BOOL)episodeHidden
                        subtitleHidden:(BOOL)subtitleHidden
                      audioTrackHidden:(BOOL)audioTrackhidden;
- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;
- (void)startAutoHideControlTimer;
- (void)stopAutoHideControlTimer;
- (void)autoHideControlTimerAction:(TWeakTimer *)timer;
- (CGFloat)changeBrightnessAndUpdateSlider:(BOOL)isIncrement;
- (CGFloat)changeVolumeAndUpdateSlider:(BOOL)isIncrement;
- (void)changeDisplayProgressAndUpdateViews:(BOOL)isIncrement multiplier:(NSInteger)multiplier;
- (void)changeVolume:(CGFloat)volumeInPercent;
- (void)enableControl:(BOOL)enable;
- (void)saveRecordForPlayCompletionWithType:(PKVideoPlayCompletionType)type;
- (void)initAudioTrackVCWithDataSourceArray:(NSArray *)dataSourceArray
                               currentIndex:(NSInteger)currentIndex;
- (void)initSubtitleVCWithDataSourceArray:(NSArray *)dataSourceArray
                             currentIndex:(NSInteger)currentIndex;
- (void)updateVolumeImageWithVolume:(CGFloat)volumeInPercent;
- (void)postStartPlayingNotification;
- (void)postFinishPlayingNotification;
- (NSString *)stringForTimeInMS:(NSInteger)timeInMS;
- (NSString *)stringForDownloadSpeedInBytes:(long long)downloadSpeedInBytes;
- (BOOL)isShowingLoading;
- (void)showLoadingWithBufferProgress:(CGFloat)progressInPercent
                        downloadSpeed:(long long)downloadSpeedInBytes;
- (void)showLoadingWithDescription:(NSString *)descriptionString;
- (void)hideLoading;
- (BOOL)isShowingProgressIndicator;
- (void)showProgressIndicatorWithDescription:(NSString *)descriptionString isRewind:(BOOL)isRewind;
- (void)hideProgressIndicator;
- (BOOL)isShowingTip;
- (void)showTipWithType:(PKPlayerTipType)type;
- (void)hideTipWithType:(PKPlayerTipType)type;
- (void)showError:(NSError *)error withCompletionHandler:(void (^) ())completionBlock;
- (void)showWWANAlertWithCompletionHandler:(void (^) (BOOL cancel))completionBlock;
- (void)updatePlayBtnImage:(BOOL)isPlayImage;
- (BOOL)needShowWWANAlert;
- (void)showGuide;
- (BOOL)needShowGuide;
- (void)hideGuide;
- (void)notifyOpenCompleted;
- (void)notifyPlayCompleted;
- (void)switchToDLNAPlaying;
- (void)switchBackFromDLNAPlaying;
- (void)syncSystemInfo;
- (void)disableControlAndButton;
- (void)seekForDisplayProgressAndUpdateViews:(NSInteger)progressInMS;
- (void)showVideoInfo;

- (void)doStartPlayingStatistic;
- (void)doStopPlayingStatistic : (PKEndType)endType withError:(NSError *)error;
- (void)doSeekStatisticWithType:(BOOL)isGesture isRewind:(BOOL)isRewind;
- (void)doEpisodeBtnClickStatistic;
- (void)doSubtitleBtnClickStatistic;
- (void)doDisplaymodeChangedStatistic;
- (void)doDisplayPlayerViewStatistic;
- (void)doDLNABtnClickStatistic;
- (void)doUserPauseStatistic : (BOOL)isPauseMode;
- (void)doAudioTrackBtnClickStatistic;
- (void)doAudioTrackInfoStatistic;
- (void)donextBtnClickStatistic;

@end

#pragma mark -
@implementation PKVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self postStartPlayingNotification];
    [self doDisplayPlayerViewStatistic];
    [self initNotifications];
    [self initGestures];
    [self initLoadView];
    [self initVideoView];
    [self doInit];
    [self showGuide];
    
    if (self.videoPlayerCore.isReadyForPlaying) {/// 已经打开成功
        [self initPlay];
    } else {/// 打开中
        [self disableControlAndButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [self removeNotifications];
    [self postFinishPlayingNotification];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.videoPlayerCore setVolumeChangedBlock:NULL];
    [self hideLoading];
    
    if ([self.videoPlayerCore canClose]) {
        [self notifyPlayCompleted];
        
        //手动退出统计
        [self doStopPlayingStatistic:kPlayEndByUser withError:nil];
        
        [self saveRecordForPlayCompletionWithType:kVideoPlayCompletionTypeClosed];
        [self.videoPlayerCore close];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.videoPlayerCore.isBufferReadyForPlaying) {
        [self showLoadingWithBufferProgress:0.0 downloadSpeed:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideLoading];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    } else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

/// < iOS8
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"%s", __FUNCTION__);
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.videoPlayerCore setVideoViewSize:[UIScreen landscapeScreenBounds].size];
    } else {
        [self.videoPlayerCore setVideoViewSize:[UIScreen portraitScreenBounds].size];
    }
}

/// < iOS8
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"%s", __FUNCTION__);
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

/// >= iOS8
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"%s", __FUNCTION__);
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [UIView animateWithDuration:.3
                          delay:.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.videoPlayerCore setVideoViewSize:size];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.statusBarUpdateAnimation;
}

- (void)setVideoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore {
    _videoPlayerCore = videoPlayerCore;
    self.videoPlayerCore.delegate = self;
    self.isVideoViewLoaded = NO;
    [self initVideoView];
}

- (void)setCurrentPlayerViewDisplayMode:(PKPlayerViewDisplayMode)currentPlayerViewDisplayMode {
    if (currentPlayerViewDisplayMode != _currentPlayerViewDisplayMode) {
        _currentPlayerViewDisplayMode = currentPlayerViewDisplayMode;
        if (_currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowControlOnly) {
            [self displayWithHeaderControlHidden:NO
                              otherControlHidden:NO
                                   episodeHidden:YES
                                  subtitleHidden:YES
                                audioTrackHidden:YES];
        } else if (_currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowEpisodeOnly) {
            [self displayWithHeaderControlHidden:YES
                              otherControlHidden:YES
                                   episodeHidden:NO
                                  subtitleHidden:YES
                                audioTrackHidden:YES];
        } else if (_currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowSubtitleOnly) {
            [self displayWithHeaderControlHidden:YES
                              otherControlHidden:YES
                                   episodeHidden:YES
                                  subtitleHidden:NO
                                audioTrackHidden:YES];
        } else if (_currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowAudioTrackOnly) {
            [self displayWithHeaderControlHidden:YES
                              otherControlHidden:YES
                                   episodeHidden:YES
                                  subtitleHidden:YES
                                audioTrackHidden:NO];
        } else if (_currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowHeaderControlOnly) {
            [self displayWithHeaderControlHidden:NO
                              otherControlHidden:YES
                                   episodeHidden:YES
                                  subtitleHidden:YES
                                audioTrackHidden:YES];
        } else if (_currentPlayerViewDisplayMode == kPlayerViewDisplayModeHideAll) {
            [self displayWithHeaderControlHidden:YES
                              otherControlHidden:YES
                                   episodeHidden:YES
                                  subtitleHidden:YES
                                audioTrackHidden:YES];
        }
    }
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKVideoPlayerViewController *instance = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        NSString *nibName = [NSString stringWithFormat:@"%@_i5", NSStringFromClass([self class])];
        instance = [[PKVideoPlayerViewController alloc]
                    initWithNibName:nibName
                    bundle:bundle];
    } else {
        instance = [[PKVideoPlayerViewController alloc]
                    initWithNibName:NSStringFromClass([PKVideoPlayerViewController class])
                    bundle:bundle];
    }
    return instance;
}

- (void)switchWithContentURLString:(NSString *)contentURLString {
    [self.videoPlayerCore switchVideoWithContentURLString:contentURLString];
    if (!self.videoPlayerCore.isBufferReadyForPlaying) {
        [self showLoadingWithBufferProgress:0.0 downloadSpeed:0];
    }
}

- (void)switchWithContentStreamSlices:(NSArray *)contentStreamSlices {
    [self.videoPlayerCore switchVideoWithContentStreamSlices:contentStreamSlices];
    if (!self.videoPlayerCore.isBufferReadyForPlaying) {
        [self showLoadingWithBufferProgress:0.0 downloadSpeed:0];
    }
}

- (void)pause {
    [self switchToPausedStatus:YES];
}

- (void)resumePlaying {
    [self switchToPausedStatus:NO];
}

- (void)close {
    [self doQuit];
}

#pragma mark - Private

- (IBAction)quitBtnAction:(id)sender {
    [self doQuit];
}

- (IBAction)audioTrackBtnAction:(id)sender {
    [self doAudioTrackBtnClickStatistic];
    
    NSArray *audioTracks = self.videoPlayerCore.audioTracks;
    NSInteger currentIndex = self.videoPlayerCore.currentAudioTrackIndex;
    if (audioTracks.count < 2) {
        return;
    }
    
    [self stopAutoHideControlTimer];
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowAudioTrackOnly;
    
    [self initAudioTrackVCWithDataSourceArray:audioTracks currentIndex:currentIndex];
}

- (IBAction)dlnaBtnAction:(id)sender {
    [self doDLNABtnClickStatistic];
    
    if (self.dlnaDeviceVC || self.dlnaPlayingTipVC) {
        return;
    }
    
    PKDLNASource *dlnaSource = self.sourceManager.dlnaSource;
    if (!dlnaSource || !dlnaSource.dlnaDeviceViewBlock || !dlnaSource.dlnaPlayingTipViewBlock) {
        return;
    }
    
    self.needResumePlayAfterDLNA = !self.videoPlayerCore.isPaused;
    [self switchToPausedStatus:YES];
    [self stopAutoHideControlTimer];
    [self saveRecordForPlayCompletionWithType:kVideoPlayCompletionTypeClosed];
    
    __weak typeof(self) weakSelf = self;
    UIViewController *deviceVC = dlnaSource.dlnaDeviceViewBlock(self.videoPlayerCore.videoInfo, ^(BOOL isCanceled){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.dlnaDeviceVC.view removeFromSuperview];
        [strongSelf.dlnaDeviceVC removeFromParentViewController];
        strongSelf.dlnaDeviceVC = nil;
        if (isCanceled) {
            [strongSelf startAutoHideControlTimer];
            if (strongSelf.needResumePlayAfterDLNA) {
                [strongSelf switchToPausedStatus:NO];
            }
        } else {
            [strongSelf switchToDLNAPlaying];
        }
    });
    self.dlnaDeviceVC = deviceVC;
    self.dlnaDeviceVC.view.frame = self.holder.bounds;
    [self.holder addSubview:self.dlnaDeviceVC.view];
    [self addChildViewController:self.dlnaDeviceVC];
}

- (IBAction)subtitleBtnAction:(id)sender {
    [self doSubtitleBtnClickStatistic];
    
    [self stopAutoHideControlTimer];
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowSubtitleOnly;

    PKSubtitleSource *subtitleSource = self.sourceManager.subtitleSource;
    if (subtitleSource.currentSubtitleIndexBlock && subtitleSource.loadSubtitleListBlock) {
        NSArray *embeddedSubtitles = self.videoPlayerCore.embeddedSubtitles;
        __weak typeof(self) weakSelf = self;
        subtitleSource.loadSubtitleListBlock(embeddedSubtitles, ^(NSArray *subtitleList) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            PKSubtitleInfo *info = strongSelf.videoPlayerCore.currentSubtitleInfo;
            NSInteger embeddedIndex = -1;
            if (info.type == kSubtitleTypeEmbedded) {
                embeddedIndex = info.embeddedSubtitleIndex;
            }
            NSInteger currentIndex = subtitleSource.currentSubtitleIndexBlock(embeddedIndex);
            
            [strongSelf initSubtitleVCWithDataSourceArray:subtitleList
                                             currentIndex:currentIndex];
        });
    }
}

- (IBAction)playBtnAction:(id)sender {
    
    [self doUserPauseStatistic:!self.videoPlayerCore.isPaused];
    
    [self startAutoHideControlTimer];
    [self switchToPausedStatus:!self.videoPlayerCore.isPaused];
}

- (IBAction)nextBtnAction:(id)sender {
    [self donextBtnClickStatistic];
    
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    if (!episodeSource) {
        return;
    }
    
    NSInteger nextIndex = -1;
    if (episodeSource.nextEpisodeIndexForAutoSwitchBlock) {
        nextIndex = episodeSource.nextEpisodeIndexForAutoSwitchBlock();
    }
    
    if (nextIndex >= 0) {
        [self switchWithEpisodeIndex:nextIndex];
    }
}

- (IBAction)resolutionBtnAction:(id)sender {
    PKResolutionSource *resolutionSource = self.sourceManager.resolutionSource;
    if (!resolutionSource || !resolutionSource.currentResolutionIndexBlock ||
        !resolutionSource.availableResolutionTitleArrayBlock) {
        return;
    }
    
    [self stopAutoHideControlTimer];
    self.resolutionBtn.selected = YES;
    
    NSInteger currentIndex = resolutionSource.currentResolutionIndexBlock();
    NSArray *dataSourceArray = resolutionSource.availableResolutionTitleArrayBlock();
    
    PKResolutionViewController *vc = [PKResolutionViewController nibInstance];
    self.resolutionPController = [[PKPopoverController alloc] initWithContentViewController:vc];
    self.resolutionPController.parentView = self.view;
    self.resolutionPController.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [vc setSelectionChangeHandler:^(NSInteger newIndex) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf switchWithResolutionIndex:newIndex];
        
        [strongSelf.resolutionPController dismissPopoverAnimated:YES];
        [strongSelf popoverControllerDidDismissPopover:strongSelf.resolutionPController];
    }];
    
    [vc setDataSourceArray:dataSourceArray currentIndex:currentIndex];
    
    CGRect btnRect = [self.resolutionBtn convertRect:self.resolutionBtn.bounds toView:self.view];
    CGFloat offsetY = 12;
    if ([UIDevice isIPad]) {
        offsetY = 12;
    }
    btnRect.origin.y -= offsetY;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        btnRect.origin.x -= 12;
    }
    [self.resolutionPController presentPopoverFromRect:btnRect
                                      inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionDown
                                    animated:YES];
}

- (IBAction)episodeBtnAction:(id)sender {
    [self doEpisodeBtnClickStatistic];
    
    [self stopAutoHideControlTimer];
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowEpisodeOnly;
}

- (void)initNotifications {
    [self removeNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initLoadView {
    if (!self.isViewLoaded) {
        return;
    }
    
    if (!self.progressSlider) {
        self.progressSlider = [PKSlider nibInstance];
        self.progressSlider.delegate = self;
        self.progressSlider.frame = self.progressSliderHolder.bounds;
        [self.progressSliderHolder addSubview:self.progressSlider];
        self.progressSlider.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    if (!self.progressDescriptionView) {
        self.progressDescriptionView = [PKProgressDescriptionView nibInstance];
        self.progressDescriptionView.frame =
        CGRectMake(0,
                   0-self.progressDescriptionView.frame.size.height,
                   self.progressDescriptionView.frame.size.width,
                   self.progressDescriptionView.frame.size.height);
        [self.progressSlider addSubview:self.progressDescriptionView];
    }
    
    if (!self.landscapeVolumeSlider || !self.landscapeBrightnessSlider) {
        UIImage *bgImage = nil;
        if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
            bgImage = [UIImage imageInPKBundleWithName:@"pk_volume_bg_i5.png"];
        } else {
            bgImage = [UIImage imageInPKBundleWithName:@"pk_volume_bg.png"];
        }
        bgImage = [bgImage stretchableImageWithLeftCapWidth:0 topCapHeight:30];
        self.brightnessBgView.image = bgImage;
        self.volumeBgView.image = bgImage;

        self.landscapeVolumeSlider = [PKSlider nibInstance];
        self.landscapeVolumeSlider.delegate = self;
        self.landscapeVolumeSlider.frame = self.landscapeVolumeSliderHolder.bounds;
        [self.landscapeVolumeSliderHolder addSubview:self.landscapeVolumeSlider];
        self.landscapeVolumeSlider.progressInPercent = self.videoPlayerCore.volume;
        [self updateVolumeImageWithVolume:self.videoPlayerCore.volume];
        
        self.landscapeBrightnessSlider = [PKSlider nibInstance];
        self.landscapeBrightnessSlider.delegate = self;
        self.landscapeBrightnessSlider.frame = self.landscapeBrightnessSliderHolder.bounds;
        [self.landscapeBrightnessSliderHolder addSubview:self.landscapeBrightnessSlider];
        self.landscapeBrightnessSlider.progressInPercent = [UIScreen mainScreen].brightness;
        
        self.landscapeVolumeSliderHolder.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
        self.landscapeBrightnessSliderHolder.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
    }
    
    __weak typeof(self) weakSelf = self;
    [self.videoPlayerCore setVolumeChangedBlock:^(CGFloat newVolume) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.landscapeVolumeSlider.progressInPercent = newVolume;
                [strongSelf updateVolumeImageWithVolume:newVolume];
            });
            
        }
    }];
    
    NSBundle *bundle = [NSBundle pkBundle];
    UINib *mutilEpisodeCellNib = nil;
    UINib *singleEpisodeCellNib = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        mutilEpisodeCellNib = [UINib nibWithNibName:@"PKMutilEpisodeCell_i5" bundle:bundle];
        singleEpisodeCellNib = [UINib nibWithNibName:@"PKSingleEpisodeCell_i5" bundle:bundle];
    } else {
        mutilEpisodeCellNib = [UINib nibWithNibName:NSStringFromClass([PKMutilEpisodeCell class]) bundle:bundle];
        singleEpisodeCellNib = [UINib nibWithNibName:NSStringFromClass([PKSingleEpisodeCell class]) bundle:bundle];
    }
    [self.episodeTableView registerNib:mutilEpisodeCellNib
                forCellReuseIdentifier:kMutilEpisodeCellIdentifier];
    [self.episodeTableView registerNib:singleEpisodeCellNib
                forCellReuseIdentifier:kSingleEpisodeCellIdentifier];
    
    /// init sources
    [self initTitle];
    [self initResolution];
    [self initEpisode];
    [self initSubtitle];
    [self initDLNA];
    [self initAudioTrack];
}

- (void)initVideoView {
    if (self.isViewLoaded && !self.isVideoViewLoaded && self.videoPlayerCore) {
        self.isVideoViewLoaded = YES;
        
        // xib初始化的时候，view还没有自动适配，暂时直接使用屏幕的大小
        self.videoPlayerCore.videoView.translatesAutoresizingMaskIntoConstraints = YES;
        [self.videoPlayerCore setVideoViewSize:[UIScreen landscapeScreenBounds].size];
        
        if (self.videoPlayerCore.videoView.superview) {
            [self.videoPlayerCore.videoView removeFromSuperview];
        }
        
        [self.videoView addSubview:self.videoPlayerCore.videoView];
    }
}

- (void)initPlay {
    if (!self.isInitPlayDone && self.isVideoViewLoaded && self.videoPlayerCore.isReadyForPlaying) {
        self.isInitPlayDone = YES;
        
        if (self.sourceManager.recordSource.lastPlayPositionBlock) {
            NSInteger lastPositionInMS = self.sourceManager.recordSource.lastPlayPositionBlock();
            if (lastPositionInMS > 0) {
                /// 播放记录自动seek，不需要seek统计
                [self.videoPlayerCore seekWithTimeInMS:lastPositionInMS];
            }
        }
        
        if ([self needShowWWANAlert]) {
            [self showWWANAlertWithCompletionHandler:^(BOOL cancel) {
                if (cancel) {
                    [self updatePlayBtnImage:YES];
                } else {
                    [self switchToPausedStatus:NO];
                }
            }];
        } else {
            [self switchToPausedStatus:NO];
        }

        /// init sources
        [self initTitle];
        [self initResolution];
        [self initEpisode];
        [self initSubtitle];
        [self initDLNA];
        [self initAudioTrack];
        [self initAudioView];
        
        self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowControlOnly;
        [self enableControl:YES];
        
        if (!self.videoPlayerCore.videoInfo.isOnlineVideo) {
            [self startAutoHideControlTimer];
        }
        
        if (self.videoPlayerCore.isBufferReadyForPlaying) {
            [self hideLoading];
        }
    }
}

- (void)initGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapGestureAction:)];
    [self.gestureHolder addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(doubleTapGestureAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.gestureHolder addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UITapGestureRecognizer *doubleTouchTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTouchTapGestureAction:)];
    doubleTouchTapGestureRecognizer.numberOfTouchesRequired = 2;
    doubleTouchTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.gestureHolder addGestureRecognizer:doubleTouchTapGestureRecognizer];
    
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
//                                           initWithTarget:self
//                                           action:@selector(swipeGestureAction:)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.gestureHolder addGestureRecognizer:swipeLeft];
//    
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
//                                            initWithTarget:self
//                                            action:@selector(swipeGestureAction:)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.gestureHolder addGestureRecognizer:swipeRight];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panGestureAction:)];
    [self.gestureHolder addGestureRecognizer:pan];
//    [pan requireGestureRecognizerToFail:swipeLeft];
//    [pan requireGestureRecognizerToFail:swipeRight];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureAction:)];
    longPress.minimumPressDuration = 3.0;
    [self.gestureHolder addGestureRecognizer:longPress];
}

- (void)doInit {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self initReachability];
}

- (void)resetInit {
    [self disableControlAndButton];
    self.isInitPlayDone = NO;
    self.bufferHasBeenFull = NO;
}

- (void)initTitle {
    PKTitleSource *titleSource = self.sourceManager.titleSource;
    NSString *title = nil;
    NSString *detailTitle = nil;
    if (titleSource.titleBlock) {
        title = titleSource.titleBlock();
    }
    if (titleSource.detailTitleBlock) {
        detailTitle = titleSource.detailTitleBlock();
    }
#ifdef DEBUG
    if (self.videoPlayerCore.isUsingHardwareSpeedup) {
        title = [NSString stringWithFormat:@"[Speedup] %@", (title.length == 0)?@"":title];
    }
#endif
    [NSObject asyncTaskOnMainWithBlock:^{
        self.titleLable.text = title;
        self.detailTitleLabel.text = detailTitle;
    }];
}

- (void)initResolution {
    PKResolutionSource *resolutionSource = self.sourceManager.resolutionSource;
    if (!resolutionSource) {
        return;
    }
    
    PKDisplayMode mode = kDisplayModeInvisible;
    if (resolutionSource.resolutionDisplayModeBlock) {
        mode = resolutionSource.resolutionDisplayModeBlock();
    }
    [NSObject asyncTaskOnMainWithBlock:^{
        if (mode == kDisplayModeInvisible) {
            self.resolutionBtn.hidden = YES;
        } else if (mode == kDisplayModeDisable) {
            self.resolutionBtn.hidden = NO;
            self.resolutionBtn.enabled = NO;
        } else if (mode == kDisplayModeEnable) {
            self.resolutionBtn.hidden = NO;
            self.resolutionBtn.enabled = YES;
        }
    }];
    
    if (resolutionSource.currentResolutionIndexBlock && resolutionSource.availableResolutionTitleArrayBlock) {
        NSInteger currentIndex = resolutionSource.currentResolutionIndexBlock();
        NSArray *dataSourceArray = resolutionSource.availableResolutionTitleArrayBlock();
        if (currentIndex >=0 && currentIndex < dataSourceArray.count) {
            NSString *title = dataSourceArray[currentIndex];
            [NSObject asyncTaskOnMainWithBlock:^{
                [self.resolutionBtn setTitle:title forState:UIControlStateNormal];
            }];
        }
    }
}

- (void)initEpisode {
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    
    PKDisplayMode mode = kDisplayModeInvisible;
    if (episodeSource.episodeDisplayModeBlock) {
        mode = episodeSource.episodeDisplayModeBlock();
    }
    [NSObject asyncTaskOnMainWithBlock:^{
        if (mode == kDisplayModeInvisible) {
            self.episodeBtn.hidden = YES;
            self.nextBtn.hidden = YES;
            if (![UIDevice isIPad]) {
                if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
                    self.progressSliderHolder.frame =
                    CGRectMake(65,
                               self.progressSliderHolder.frame.origin.y,
                               self.bottomHolder.frame.size.width-65-70,
                               self.progressSliderHolder.frame.size.height);
                } else {
                    self.progressSliderHolder.frame =
                    CGRectMake(75,
                               self.progressSliderHolder.frame.origin.y,
                               self.bottomHolder.frame.size.width-75-95,
                               self.progressSliderHolder.frame.size.height);
                }
                self.timeLabel.frame =
                CGRectMake(self.progressSliderHolder.frame.origin.x+self.progressSliderHolder.frame.size.width-self.timeLabel.frame.size.width-11,
                           self.timeLabel.frame.origin.y,
                           self.timeLabel.frame.size.width,
                           self.timeLabel.frame.size.height);
            }
        } else {
            if (mode == kDisplayModeDisable) {
                self.episodeBtn.hidden = NO;
                self.episodeBtn.enabled = NO;
            } else if (mode == kDisplayModeEnable) {
                self.episodeBtn.hidden = NO;
                self.episodeBtn.enabled = YES;
            }
            self.nextBtn.hidden = NO;
            if (![UIDevice isIPad]) {
                if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
                    self.progressSliderHolder.frame =
                    CGRectMake(110,
                               self.progressSliderHolder.frame.origin.y,
                               self.bottomHolder.frame.size.width-110-135,
                               self.progressSliderHolder.frame.size.height);
                } else {
                    self.progressSliderHolder.frame =
                    CGRectMake(120,
                               self.progressSliderHolder.frame.origin.y,
                               self.bottomHolder.frame.size.width-120-167,
                               self.progressSliderHolder.frame.size.height);
                }
                self.timeLabel.frame =
                CGRectMake(self.progressSliderHolder.frame.origin.x+self.progressSliderHolder.frame.size.width-self.timeLabel.frame.size.width-11,
                           self.timeLabel.frame.origin.y,
                           self.timeLabel.frame.size.width,
                           self.timeLabel.frame.size.height);
            }
        }
    }];
    
    if (!episodeSource) {
        return;
    }
    
    NSArray *availableEpisodeTitleArray = nil;
    if (episodeSource.availableEpisodeTitleArrayBlock) {
        availableEpisodeTitleArray = episodeSource.availableEpisodeTitleArrayBlock();
    }
    NSInteger currentEpisodeIndex = -1;
    if (episodeSource.currentEpisodeIndexBlock) {
        currentEpisodeIndex = episodeSource.currentEpisodeIndexBlock();
    }
    
    NSInteger nextIndex = -1;
    if (episodeSource.nextEpisodeIndexForAutoSwitchBlock) {
        nextIndex = episodeSource.nextEpisodeIndexForAutoSwitchBlock();
    }

    [NSObject asyncTaskOnMainWithBlock:^{
        if (nextIndex < 0) {
            self.nextBtn.enabled = NO;
        } else {
            self.nextBtn.enabled = YES;
        }
    }];
    
    NSString *title = nil;
    if (episodeSource.episodeTitleBlock) {
        title = episodeSource.episodeTitleBlock();
    }
    [NSObject asyncTaskOnMainWithBlock:^{
        self.episodeTitleLabel.text = title;
    }];
    
    PKEpisodeCellType type = kEpisodeCellTypeMutilEpisode;
    if (episodeSource.episodeCellTypeBlock) {
        type = episodeSource.episodeCellTypeBlock();
    }
    if (type == kEpisodeCellTypeMutilEpisode) {
        self.episodeTableView.allowsSelection = NO;
    } else {
        self.episodeTableView.allowsSelection = YES;
        
        if (currentEpisodeIndex >=0 && currentEpisodeIndex < availableEpisodeTitleArray.count) {
            [NSObject asyncTaskOnMainWithBlock:^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentEpisodeIndex inSection:0];
                [self.episodeTableView selectRowAtIndexPath:indexPath
                                                   animated:NO
                                             scrollPosition:UITableViewScrollPositionNone];
            }];
        }
    }
}

- (void)initSubtitle {
    PKSubtitleSource *subtitleSource = self.sourceManager.subtitleSource;
    NSArray *embeddedSubtitles = self.videoPlayerCore.embeddedSubtitles;
    if (!subtitleSource && embeddedSubtitles.count > 0) {
        [self initDefaultSubtitleSource];
        subtitleSource = self.sourceManager.subtitleSource;
    }
    
    PKDisplayMode mode = kDisplayModeDisable;
    if (subtitleSource.subtitleDisplayModeBlock) {
        mode = subtitleSource.subtitleDisplayModeBlock();
    }
    [NSObject asyncTaskOnMainWithBlock:^{
        if (mode == kDisplayModeInvisible) {
            self.subtitleBtn.hidden = YES;
        } else if (mode == kDisplayModeDisable) {
            self.subtitleBtn.hidden = NO;
            self.subtitleBtn.enabled = NO;
        } else if (mode == kDisplayModeEnable) {
            self.subtitleBtn.hidden = NO;
            self.subtitleBtn.enabled = YES;
            if (!self.videoPlayerCore.isReadyForPlaying) {
                self.subtitleBtn.enabled = NO;
            }
        }
    }];
    
    if (subtitleSource.currentSubtitleIndexBlock && subtitleSource.loadSubtitleInfoBlock) {
        PKSubtitleInfo *info = self.videoPlayerCore.currentSubtitleInfo;
        NSInteger embeddedIndex = -1;
        if (info.type == kSubtitleTypeEmbedded) {
            embeddedIndex = info.embeddedSubtitleIndex;
        }
        NSInteger currentIndex = subtitleSource.currentSubtitleIndexBlock(embeddedIndex);
        
        __weak typeof(self) weakSelf = self;
        subtitleSource.loadSubtitleInfoBlock(currentIndex, embeddedSubtitles, ^(PKSubtitleInfo *subtitleInfo){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (subtitleInfo) {
                [strongSelf.videoPlayerCore setSubtitleWithInfo:subtitleInfo];
            }
        });
        
    }
    
}

- (void)initDefaultSubtitleSource {
    /// 外部没有设置字幕源，但是视频本身有内嵌字幕，在此处设置内嵌字幕的默认字幕源
    
    if (self.videoPlayerCore.embeddedSubtitles.count <= 0) {
        return;
    }
    
    static NSString *const kNoSubtitleText = @"不显示";
    
    PKSubtitleSource *subtitleSource = [[PKSubtitleSource alloc] init];
    __block NSArray *availableSubtitleTitleArray = nil;
    [subtitleSource setSubtitleDisplayModeBlock:^PKDisplayMode{
        return kDisplayModeEnable;
    }];
    __block NSInteger currentSubtitleIndex = -1;
    [subtitleSource setCurrentSubtitleIndexBlock:^NSInteger (NSInteger embeddedSubtitleIndex){
        if (currentSubtitleIndex < 0) {
            currentSubtitleIndex = MAX(0, embeddedSubtitleIndex+1);
        }
        return currentSubtitleIndex;
    }];
    [subtitleSource setLoadSubtitleListBlock:
     ^(NSArray *embeddedSubtitles, loadSubtitleListCompletionBlock completionBlock) {
         if (!availableSubtitleTitleArray) {
             NSMutableArray *array = [NSMutableArray arrayWithArray:embeddedSubtitles];
             [array insertObject:kNoSubtitleText atIndex:0];
             availableSubtitleTitleArray = [array copy];
         }
         if (completionBlock) {
             completionBlock(availableSubtitleTitleArray);
         }
     }];
    [subtitleSource setSubtitleIndexChangedBlock:^(NSInteger newIndex) {
        currentSubtitleIndex = newIndex;
    }];
    [subtitleSource setLoadSubtitleInfoBlock:
     ^(NSInteger subtitleIndex, NSArray *embeddedSubtitles, loadSubtitlePathCompletionBlock completionBlock) {
         PKSubtitleInfo *info = [[PKSubtitleInfo alloc] init];
         if (subtitleIndex == 0) {/// 不显示
             info.type = kSubtitleTypeNone;
             if (completionBlock) {
                 completionBlock(info);
             }
         } else if (subtitleIndex > 0 && subtitleIndex <= embeddedSubtitles.count){/// 内嵌字幕
             info.type = kSubtitleTypeEmbedded;
             info.embeddedSubtitleIndex = subtitleIndex - 1;
             if (completionBlock) {
                 completionBlock(info);
             }
         } else {/// ERROR
             if (completionBlock) {
                 completionBlock(nil);
             }
         }
     }];
    
    if (!self.sourceManager) {
        self.sourceManager = [[PKSourceManager alloc] init];
    }
    
    self.sourceManager.subtitleSource = subtitleSource;
}

- (void)initReachability {
    if (self.videoPlayerCore.videoInfo.isOnlineVideo) {
        if (self.sourceManager.reachabilitySource.reachabilityChangedBlock) {
            __weak typeof(self) weakSelf = self;
            self.sourceManager.reachabilitySource.reachabilityChangedBlock(^(PKNetworkStatus status) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (status == KNetworkStatusNotReachable) {
                    [strongSelf showTipWithType:kPlayerTipTypeNoNetwork];
                } else {
                    [strongSelf hideTipWithType:kPlayerTipTypeNoNetwork];
                    if (status == KNetworkStatusReachableViaWWAN && !strongSelf.videoPlayerCore.isPaused) {
                        [strongSelf switchToPausedStatus:YES];
                        [strongSelf showWWANAlertWithCompletionHandler:^(BOOL cancel) {
                            if (!cancel) {
                                [strongSelf switchToPausedStatus:NO];
                            }
                        }];
                    }
                }
            });
        }
    }
}

- (void)initDLNA {
    PKDLNASource *dlnaSource = self.sourceManager.dlnaSource;
    if (!dlnaSource) {
        return;
    }
    
    PKDisplayMode mode = kDisplayModeInvisible;
    if (dlnaSource.dlnaDisplayModeBlock) {
        mode = dlnaSource.dlnaDisplayModeBlock();
    }
    [NSObject asyncTaskOnMainWithBlock:^{
        if (mode == kDisplayModeInvisible) {
            self.dlnaBtn.hidden = YES;
        } else if (mode == kDisplayModeDisable) {
            self.dlnaBtn.hidden = NO;
            self.dlnaBtn.enabled = NO;
        } else if (mode == kDisplayModeEnable) {
            self.dlnaBtn.hidden = NO;
            self.dlnaBtn.enabled = YES;
            if (!self.videoPlayerCore.isReadyForPlaying) {
                self.dlnaBtn.enabled = NO;
            }
        }
    }];
}

- (void)initAudioTrack {
    PKDisplayMode mode = kDisplayModeInvisible;
    if (self.videoPlayerCore.audioTracks.count > 1) {
        mode = kDisplayModeEnable;
    }
    [NSObject asyncTaskOnMainWithBlock:^{
        if (mode == kDisplayModeInvisible) {
            self.audioTrackBtn.hidden = YES;
        } else if (mode == kDisplayModeDisable) {
            self.audioTrackBtn.hidden = NO;
            self.audioTrackBtn.enabled = NO;
        } else if (mode == kDisplayModeEnable) {
            self.audioTrackBtn.hidden = NO;
            self.audioTrackBtn.enabled = YES;
            if (!self.videoPlayerCore.isReadyForPlaying) {
                self.audioTrackBtn.enabled = NO;
            }
        }
    }];
}

- (void)initAudioView {
    [NSObject asyncTaskOnMainWithBlock:^{
        if(self.videoPlayerCore.videoInfo.isAudio && !self.videoPlayerCore.videoInfo.hasVideo)
        {
            self.musicBgVc = [PKMusicPlayViewController nibInstance];
            self.musicBgVc.view.frame = [UIScreen mainScreen].bounds;
            [self.gestureHolder addSubview:self.musicBgVc.view];
            [self addChildViewController:self.musicBgVc];
        }
        else
        {
            [self hideAudioView];
        }
    }];
}

- (void)hideAudioView
{
    if(self.musicBgVc)
    {
        [self.musicBgVc.view removeFromSuperview];
        [self.musicBgVc removeFromParentViewController];
        self.musicBgVc = nil;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)sender {
    if (self.currentPlayerViewDisplayMode != kPlayerViewDisplayModeHideAll) {
        self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeHideAll;
    } else {
        self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowControlOnly;
        [self startAutoHideControlTimer];
    }
}

- (void)doubleTapGestureAction:(UITapGestureRecognizer *)sender {
    [self switchToFillDisplayMode:(self.videoPlayerCore.videoViewDisplayMode == kVideoViewDisplayModeScaleAspectFit)];
    
    [self doDisplaymodeChangedStatistic];
}

- (void)doubleTouchTapGestureAction:(UITapGestureRecognizer *)sender {
    [self playBtnAction:nil];
}

- (void)swipeGestureAction:(UISwipeGestureRecognizer *)sender {
    if (!self.videoPlayerCore.isReadyForPlaying) {
        return;
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self doRewind];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self doFastForward];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"began:\n");
            CGPoint location = [sender locationInView:self.gestureHolder];
            self.preLocationForPanGesture = location;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            NSLog(@"changed:\n");
            CGPoint location = [sender locationInView:self.gestureHolder];
            CGFloat xDistance = fabs(location.x - self.preLocationForPanGesture.x);
            CGFloat yDistance = fabs(location.y - self.preLocationForPanGesture.y);
            NSLog(@"y: %f\nminLeftY: %f\nminRightY: %f",
                  yDistance,
                  kMaxYDistanceForVPanGesture*kMinPercentForLeftVPanGesture,
                  kMaxYDistanceForVPanGesture*kMinPercentForRightVPanGesture);
            if (!self.isLeftVPanGestureRecognized &&
                !self.isRightVPanGestureRecognized &&
                !self.isHPanGestureRecognized) {
                if (xDistance > yDistance) {
                    /// 左右移动手势
                    self.isHPanGestureRecognized = YES;
                    self.displayProgressInMS =
                    self.progressSlider.progressInPercent*self.videoPlayerCore.videoInfo.videoDurationInMS;
                    [self stopAutoHideControlTimer];
                } else {
                    /// 上下移动手势
                    if (self.preLocationForPanGesture.x < ([UIScreen landscapeScreenBounds].size.width/2)) {
                        self.isLeftVPanGestureRecognized = YES;
                    } else {
                        self.isRightVPanGestureRecognized = YES;
                    }
                }
            }
            if (self.isHPanGestureRecognized) {
                /// 左右移动手势
                if (yDistance > kMaxYDistanceForHPanGesture) {
                    sender.enabled = NO;
                } else {
                    CGFloat screenWidth = [UIScreen landscapeScreenBounds].size.width;
                    if (xDistance >= screenWidth*kMinTimeForHSeekingInMS/kMaxTimeForHSeekingInMS) {
                        NSInteger multiplier = xDistance*kMaxTimeForHSeekingInMS/(screenWidth*kMinTimeForHSeekingInMS);
                        [self changeDisplayProgressAndUpdateViews:(location.x > self.preLocationForPanGesture.x) multiplier:multiplier];
                        self.preLocationForPanGesture = location;
                    }
                }
            } else if (self.isLeftVPanGestureRecognized) {
                /// 亮度调节手势
                if (xDistance > kMaxXDistanceForVPanGesture) {
                    sender.enabled = NO;
                } else {
                    if (yDistance >= kMaxYDistanceForVPanGesture*kMinPercentForLeftVPanGesture) {
                        [self changeBrightnessAndUpdateSlider:(location.y < self.preLocationForPanGesture.y)];
                        self.preLocationForPanGesture = location;
                    }
                }
            } else if (self.isRightVPanGestureRecognized) {
                /// 声音调节手势
                if (xDistance > kMaxXDistanceForVPanGesture) {
                    sender.enabled = NO;
                } else {
                    if (yDistance >= kMaxYDistanceForVPanGesture*kMinPercentForRightVPanGesture) {
                        [self changeVolumeAndUpdateSlider:(location.y < self.preLocationForPanGesture.y)];
                        self.preLocationForPanGesture = location;
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            NSLog(@"done:\n");
            self.preLocationForPanGesture = CGPointZero;
            self.isLeftVPanGestureRecognized = NO;
            self.isRightVPanGestureRecognized = NO;
            if (self.isHPanGestureRecognized) {
                self.isHPanGestureRecognized = NO;
                [self seekForDisplayProgressAndUpdateViews:self.displayProgressInMS];
                if (self.currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowControlOnly) {
                    [self startAutoHideControlTimer];
                }
            }
            self.displayProgressInMS = 0;
            sender.enabled = YES;
            break;
        }
        default:
            break;
    }
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showVideoInfo];
    }
}

- (void)resignActiveNotification:(NSNotification *)notification {
    if (self.videoPlayerCore.videoInfo.isAudio) {
        return;
    }
    
    if (!self.videoPlayerCore.isPaused) {
        self.needResumePlayWhenActive = YES;
        [self switchToPausedStatus:YES];
    }
}

- (void)becomeActiveNotification:(NSNotification *)notification {
    [self syncSystemInfo];
    if ([self needShowWWANAlert]) {
        [self showWWANAlertWithCompletionHandler:^(BOOL cancel) {
            if (!cancel) {
                [self switchToPausedStatus:NO];
            }
        }];
    } else {
        if (self.needResumePlayWhenActive) {
            self.needResumePlayWhenActive = NO;
            BOOL needResume = YES;
            if (self.sourceManager.playerStatusSource.needResumePlayingBlock) {
                needResume = self.sourceManager.playerStatusSource.needResumePlayingBlock();
            }
            if (needResume) {
                [self switchToPausedStatus:NO];
            }
        }
    }
}

- (void)switchToPausedStatus:(BOOL)switchToPaused {
    if (switchToPaused) {
        [self.videoPlayerCore pauseWithExecutionHandler:^(BOOL executed) {
            if (executed) {
                [self updatePlayBtnImage:YES];
            }
        }];
    } else {
        [self.videoPlayerCore playWithExecutionHandler:^(BOOL executed) {
            if (executed) {
                [self updatePlayBtnImage:NO];
            }
        }];
    }
}

- (void)doQuit {
    [NSObject asyncTaskOnMainWithBlock:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)doRewind {
    /// seek统计
    [self doSeekStatisticWithType:YES isRewind:YES];
    
    NSInteger positionInMS = [self.videoPlayerCore rewind];
    NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
    NSString *timeString = [NSString stringWithFormat:@"%@/%@",
                            [self stringForTimeInMS:positionInMS],
                            [self stringForTimeInMS:durationInMS]];
    [self showProgressIndicatorWithDescription:timeString isRewind:YES];
}

- (void)doFastForward {
    /// seek统计
    [self doSeekStatisticWithType:YES isRewind:NO];
    
    NSInteger positionInMS = [self.videoPlayerCore fastForward];
    NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
    NSString *timeString = [NSString stringWithFormat:@"%@/%@",
                            [self stringForTimeInMS:positionInMS],
                            [self stringForTimeInMS:durationInMS]];
    [self showProgressIndicatorWithDescription:timeString isRewind:NO];
}

- (void)switchWithResolutionIndex:(NSInteger)resolutionIndex {
    PKResolutionSource *resolutionSource = self.sourceManager.resolutionSource;
    if (!resolutionSource || !resolutionSource.resolutionIndexChangedBlock) {
        return;
    }
    
    NSArray *dataSourceArray = resolutionSource.availableResolutionTitleArrayBlock();
    
    if (resolutionIndex >=0 && resolutionIndex < dataSourceArray.count) {
        [NSObject asyncTaskOnMainWithBlock:^{
            NSString *title = dataSourceArray[resolutionIndex];
            [self.resolutionBtn setTitle:title forState:UIControlStateNormal];
        }];
    }
    
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowControlOnly;
    [self stopAutoHideControlTimer];
    
    /// 切集之前先保存播放记录
    [self saveRecordForPlayCompletionWithType:kVideoPlayCompletionTypeClosed];
    
    self.dlnaBtn.enabled = NO;
    
    if (resolutionSource.resolutionIndexChangedBlock) {
        resolutionSource.resolutionIndexChangedBlock(resolutionIndex);
    }
}

- (BOOL)switchToNextResolutionIfNeeded {
    PKResolutionSource *resolutionSource = self.sourceManager.resolutionSource;
    
    NSInteger nextIndex = -1;
    if (resolutionSource.nextResolutionIndexForAutoSwitchBlock) {
        nextIndex = resolutionSource.nextResolutionIndexForAutoSwitchBlock();
    }
    
    if (nextIndex >= 0 && resolutionSource.resolutionIndexChangedBlock) {
        [self switchWithResolutionIndex:nextIndex];
        return YES;
    }
    
    return NO;
}

- (void)switchWithEpisodeIndex:(NSInteger)episodeIndex {
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    if (!episodeSource || !episodeSource.episodeIndexChangedBlock) {
        return;
    }
    
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowControlOnly;
    [self stopAutoHideControlTimer];
    
    /// 切集之前先保存播放记录
    [self saveRecordForPlayCompletionWithType:kVideoPlayCompletionTypeClosed];
    
    self.dlnaBtn.enabled = NO;
    
    if (episodeSource.episodeIndexChangedBlock) {
        episodeSource.episodeIndexChangedBlock(episodeIndex);
    }
    
    [self.episodeTableView reloadData];
}

- (BOOL)switchToNextEpisodeIfNeeded {
    NSInteger nextIndex = -1;
    if (self.sourceManager.episodeSource.nextEpisodeIndexForAutoSwitchBlock) {
        nextIndex = self.sourceManager.episodeSource.nextEpisodeIndexForAutoSwitchBlock();
    }
    
    if (nextIndex >= 0) {
        [self switchWithEpisodeIndex:nextIndex];
        return YES;
    }
    
    return NO;
}

- (void)switchToFillDisplayMode:(BOOL)switchToFill {
    UIImage *imageN = nil;
    UIImage *imageH = nil;
    
    if (switchToFill) {
        self.videoPlayerCore.videoViewDisplayMode = kVideoViewDisplayModeScaleAspectFill;
        
        imageN = [UIImage imageInPKBundleWithName:@"pk_fit_btn_n.png"];
        imageH = [UIImage imageInPKBundleWithName:@"pk_fit_btn_h.png"];
    } else {
        self.videoPlayerCore.videoViewDisplayMode = kVideoViewDisplayModeScaleAspectFit;
        
        imageN = [UIImage imageInPKBundleWithName:@"pk_fill_btn_n.png"];
        imageH = [UIImage imageInPKBundleWithName:@"pk_fill_btn_h.png"];
    }
}

- (void)displayWithHeaderControlHidden:(BOOL)headerControlHidden
                    otherControlHidden:(BOOL)otherControlHidden
                         episodeHidden:(BOOL)episodeHidden
                        subtitleHidden:(BOOL)subtitleHidden
                      audioTrackHidden:(BOOL)audioTrackhidden {
    if (self.isChangingPlayerViewDisplayMode) {
        return;
    }
    
    self.isChangingPlayerViewDisplayMode = YES;
    [NSObject asyncTaskOnMainWithBlock:^{
        if (self.currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowControlOnly ||
            self.currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowHeaderControlOnly) {
            [self setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        } else {
            [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
        
        if (self.resolutionPController.isPopoverVisible) {
            [self.resolutionPController dismissPopoverAnimated:YES];
            [self popoverControllerDidDismissPopover:self.resolutionPController];
        }
        
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             if (headerControlHidden) {
                                 self.headerHolder.frame =
                                 CGRectMake(0,
                                            0-self.headerHolder.frame.size.height,
                                            self.headerHolder.frame.size.width,
                                            self.headerHolder.frame.size.height);
                                 self.headerHolder.alpha = 0.0;
                             } else {
                                 self.headerHolder.frame =
                                 CGRectMake(0,
                                            0,
                                            self.headerHolder.frame.size.width,
                                            self.headerHolder.frame.size.height);
                                 self.headerHolder.alpha = 1.0;
                             }
                             if (otherControlHidden) {
                                 self.bottomHolder.frame =
                                 CGRectMake(0,
                                            self.holder.bounds.size.height,
                                            self.bottomHolder.frame.size.width,
                                            self.bottomHolder.frame.size.height);
                                 self.brightnessHolder.frame =
                                 CGRectMake(0-self.brightnessHolder.frame.size.width,
                                            self.brightnessHolder.frame.origin.y,
                                            self.brightnessHolder.frame.size.width,
                                            self.brightnessHolder.frame.size.height);
                                 self.volumeHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width,
                                            self.volumeHolder.frame.origin.y,
                                            self.volumeHolder.frame.size.width,
                                            self.volumeHolder.frame.size.height);
                                 self.bottomHolder.alpha = 0.0;
                                 self.brightnessHolder.alpha = 0.0;
                                 self.volumeHolder.alpha = 0.0;
                             } else {
                                 self.bottomHolder.frame =
                                 CGRectMake(0,
                                            self.holder.bounds.size.height-self.bottomHolder.frame.size.height,
                                            self.bottomHolder.frame.size.width,
                                            self.bottomHolder.frame.size.height);
                                 CGFloat distanceX = 17;
                                 if ([UIDevice isIPad]) {
                                     distanceX = 20;
                                 }
                                 self.brightnessHolder.frame =
                                 CGRectMake(distanceX,
                                            self.brightnessHolder.frame.origin.y,
                                            self.brightnessHolder.frame.size.width,
                                            self.brightnessHolder.frame.size.height);
                                 self.volumeHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width-distanceX-self.volumeHolder.frame.size.width,
                                            self.volumeHolder.frame.origin.y,
                                            self.volumeHolder.frame.size.width,
                                            self.volumeHolder.frame.size.height);
                                 self.bottomHolder.alpha = 1.0;
                                 self.brightnessHolder.alpha = 1.0;
                                 self.volumeHolder.alpha = 1.0;
                             }
                             if (episodeHidden) {
                                 self.episodeHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width,
                                            self.episodeHolder.frame.origin.y,
                                            self.episodeHolder.frame.size.width,
                                            self.episodeHolder.frame.size.height);
                                 self.episodeHolder.alpha = 0.0;
                             } else {
                                 self.episodeHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width-self.episodeHolder.frame.size.width,
                                            self.episodeHolder.frame.origin.y,
                                            self.episodeHolder.frame.size.width,
                                            self.episodeHolder.frame.size.height);
                                 self.episodeHolder.alpha = 1.0;
                             }
                             if (subtitleHidden) {
                                 self.subtitleHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width,
                                            self.subtitleHolder.frame.origin.y,
                                            self.subtitleHolder.frame.size.width,
                                            self.subtitleHolder.frame.size.height);
                                 self.subtitleHolder.alpha = 0.0;
                             } else {
                                 self.subtitleHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width-self.subtitleHolder.frame.size.width,
                                            self.subtitleHolder.frame.origin.y,
                                            self.subtitleHolder.frame.size.width,
                                            self.subtitleHolder.frame.size.height);
                                 self.subtitleHolder.alpha = 1.0;
                             }
                             if (audioTrackhidden) {
                                 self.audioTrackHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width,
                                            self.audioTrackHolder.frame.origin.y,
                                            self.audioTrackHolder.frame.size.width,
                                            self.audioTrackHolder.frame.size.height);
                                 self.audioTrackHolder.alpha = 0.0;
                             } else {
                                 self.audioTrackHolder.frame =
                                 CGRectMake(self.holder.bounds.size.width-self.audioTrackHolder.frame.size.width,
                                            self.audioTrackHolder.frame.origin.y,
                                            self.audioTrackHolder.frame.size.width,
                                            self.audioTrackHolder.frame.size.height);
                                 self.audioTrackHolder.alpha = 1.0;
                             }
                         }
                         completion:^(BOOL finished) {
                             self.isChangingPlayerViewDisplayMode = NO;
                         }];
    }];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {
    if ([UIDevice iosVersion] < 7.0) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
    } else {
        self.isStatusBarHidden = hidden;
        self.statusBarUpdateAnimation = animation;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)startAutoHideControlTimer {
    [NSObject asyncTaskOnMainWithBlock:^{
        self.autoHideControlTimer =
        [[TWeakTimer alloc] initWithTimeInterval:5.0
                                          target:self
                                        selector:@selector(autoHideControlTimerAction:)
                                        userInfo:nil
                                         repeats:NO];
    }];
}

- (void)stopAutoHideControlTimer {
    self.autoHideControlTimer = nil;
}

- (void)autoHideControlTimerAction:(TWeakTimer *)timer {
    if (self.isDLNAPlaying) {
        return;
    }
    
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeHideAll;
}

- (CGFloat)changeBrightnessAndUpdateSlider:(BOOL)isIncrement {
    CGFloat value = 0.0;
    if (isIncrement) {
        [UIScreen mainScreen].brightness += kMinPercentForLeftVPanGesture;
    } else {
        [UIScreen mainScreen].brightness -= kMinPercentForLeftVPanGesture;
    }
    value = [UIScreen mainScreen].brightness;
    self.landscapeBrightnessSlider.progressInPercent = value;
    return value;
}

- (CGFloat)changeVolumeAndUpdateSlider:(BOOL)isIncrement {
    CGFloat value = 0.0;
    if (isIncrement) {
        value = [self.videoPlayerCore increaseVolume:kMinPercentForRightVPanGesture];
    } else {
        value = [self.videoPlayerCore decreaseVolume:kMinPercentForRightVPanGesture];
    }
    return value;
}

- (void)changeDisplayProgressAndUpdateViews:(BOOL)isIncrement multiplier:(NSInteger)multiplier {
    if (isIncrement) {
        self.displayProgressInMS += kMinTimeForHSeekingInMS*multiplier;
        if (self.displayProgressInMS > self.videoPlayerCore.videoInfo.videoDurationInMS) {
            self.displayProgressInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
        }
    } else {
        self.displayProgressInMS -= kMinTimeForHSeekingInMS*multiplier;
        if (self.displayProgressInMS < 0) {
            self.displayProgressInMS = 0;
        }
    }
    NSLog(@"[display_time]: %ldMS\n[mutiplier]: %ld", (long)self.displayProgressInMS, (long)multiplier);
    
    NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
    NSString *timeString = [NSString stringWithFormat:@"%@/%@",
                            [self stringForTimeInMS:self.displayProgressInMS],
                            [self stringForTimeInMS:durationInMS]];
    [self showProgressIndicatorWithDescription:timeString isRewind:!isIncrement];
    
    if (durationInMS == 0) {
        NSLog(@"[WARNING]: Zero duration!\n%s", __FUNCTION__);
        self.progressSlider.progressInPercent = 0;
    } else {
        self.progressSlider.progressInPercent = (double)self.displayProgressInMS/durationInMS;
    }
    self.timeLabel.text = timeString;
    [self.timeLabel sizeToFit];
}

- (void)changeVolume:(CGFloat)volumeInPercent {
    [self.videoPlayerCore setVolume:volumeInPercent];
}

- (void)enableControl:(BOOL)enable {
    if (enable) {
        self.bottomHolder.userInteractionEnabled = YES;
    } else {
        self.bottomHolder.userInteractionEnabled = NO;
    }
}

- (void)saveRecordForPlayCompletionWithType:(PKVideoPlayCompletionType)type {
    if (self.sourceManager.recordSource.playCompletionBlock) {
        NSInteger currentPlayPositionInMS = self.videoPlayerCore.playPositionInMS;
        BOOL finished = (type == kVideoPlayCompletionTypeEOF);
        self.sourceManager.recordSource.playCompletionBlock (currentPlayPositionInMS, finished);
    }
}

- (void)initAudioTrackVCWithDataSourceArray:(NSArray *)dataSourceArray
                               currentIndex:(NSInteger)currentIndex {
    if (!self.audioTrackVC) {
        [NSObject asyncTaskOnMainWithBlock:^{
            PKAudioTrackViewController *vc = [PKAudioTrackViewController nibInstance];
            
            __weak typeof(self) weakSelf = self;
            [vc setSelectionChangeHandler:^(NSInteger newIndex) {
                if (newIndex < 0 || newIndex >= dataSourceArray.count) {
                    return;
                }
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.videoPlayerCore setCurrentAudioTrackIndex:newIndex];
                strongSelf.currentPlayerViewDisplayMode = kPlayerViewDisplayModeHideAll;
            }];
            
            [vc setDataSourceArray:dataSourceArray currentIndex:currentIndex];
            
            self.audioTrackVC = vc;
            self.audioTrackVC.view.frame = self.audioTrackHolder.bounds;
            [self.audioTrackHolder addSubview:self.audioTrackVC.view];
            [self addChildViewController:self.audioTrackVC];
        }];
    }
}

- (void)initSubtitleVCWithDataSourceArray:(NSArray *)dataSourceArray
                             currentIndex:(NSInteger)currentIndex {
    if (!self.subtitleVC) {
        [NSObject asyncTaskOnMainWithBlock:^{
            PKSubtitleSource *subtitleSource = self.sourceManager.subtitleSource;
            
            PKSubtitleViewController *vc = [PKSubtitleViewController nibInstance];
            
            __weak typeof(self) weakSelf = self;
            [vc setSelectionChangeHandler:^(NSInteger newIndex) {
                if (newIndex < 0 || newIndex >= dataSourceArray.count) {
                    return;
                }
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (subtitleSource.subtitleIndexChangedBlock) {
                    subtitleSource.subtitleIndexChangedBlock(newIndex);
                }
                
                if (subtitleSource.loadSubtitleInfoBlock) {
                    NSArray *embeddedSubtitles = strongSelf.videoPlayerCore.embeddedSubtitles;
                    subtitleSource.loadSubtitleInfoBlock(newIndex, embeddedSubtitles, ^(PKSubtitleInfo *subtitleInfo){
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (subtitleInfo) {
                            [strongSelf.videoPlayerCore setSubtitleWithInfo:subtitleInfo];
                        }
                        strongSelf.currentPlayerViewDisplayMode = kPlayerViewDisplayModeHideAll;
                    });
                }
            }];
            
            [vc setDataSourceArray:dataSourceArray currentIndex:currentIndex];
            
            self.subtitleVC = vc;
            self.subtitleVC.view.frame = self.subtitleHolder.bounds;
            [self.subtitleHolder addSubview:self.subtitleVC.view];
            [self addChildViewController:self.subtitleVC];
        }];
    }
}

- (void)updateVolumeImageWithVolume:(CGFloat)volumeInPercent {
    if (!self.volumeImage) {
        self.volumeImage = [UIImage imageInPKBundleWithName:@"pk_volume_logo.png"];
    }
    if (!self.muteImage) {
        self.muteImage = [UIImage imageInPKBundleWithName:@"pk_mute_logo.png"];
    }
    if (volumeInPercent <= 0.0) {
        self.volumeLogoView.image = self.muteImage;
    } else {
        self.volumeLogoView.image = self.volumeImage;
    }
}

- (void)postStartPlayingNotification {
    NSDictionary *userInfo = @{kPKPlayerNotificationVideoInfoKey:self.videoPlayerCore.videoInfo};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPKPlayerStartPlayingNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)postFinishPlayingNotification {
    NSDictionary *userInfo = @{kPKPlayerNotificationVideoInfoKey:self.videoPlayerCore.videoInfo};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPKPlayerFinishPlayingNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (NSString *)stringForTimeInMS:(NSInteger)timeInMS {
    static const NSInteger kSecondsInMinute = 60;
    static const NSInteger kSecondsInHour = kSecondsInMinute * kSecondsInMinute;
    
    NSInteger timeInSeconds = timeInMS/1000;
    NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                            (long)(timeInSeconds/kSecondsInHour),
                            (long)((timeInSeconds%kSecondsInHour)/kSecondsInMinute),
                            (long)(timeInSeconds%kSecondsInMinute)];
    return timeString;
}

- (NSString *)stringForDownloadSpeedInBytes:(long long)downloadSpeedInBytes {
    static const NSInteger kBytesInK = 1024;
    static const NSInteger kBytesInM = kBytesInK * kBytesInK;
    static const NSInteger kBytesInG = kBytesInM * kBytesInK;
    
    NSString *speedString = nil;
    if (downloadSpeedInBytes >= kBytesInG) {
        speedString = [NSString stringWithFormat:@"%.1fGB/S", (double)downloadSpeedInBytes/kBytesInG];
    } else if (downloadSpeedInBytes >= kBytesInM) {
        speedString = [NSString stringWithFormat:@"%.1fMB/S", (double)downloadSpeedInBytes/kBytesInM];
    } else if (downloadSpeedInBytes >= kBytesInK) {
        speedString = [NSString stringWithFormat:@"%.1fKB/S", (double)downloadSpeedInBytes/kBytesInK];
    } else if (downloadSpeedInBytes >= 0) {
        speedString = [NSString stringWithFormat:@"%.1fB/S", (double)downloadSpeedInBytes];
    } else {
        speedString = @"0B/S";
    }
    
    return speedString;
}

- (BOOL)isShowingLoading {
    return self.loadingView.isShowing;
}

- (void)showLoadingWithBufferProgress:(CGFloat)progressInPercent
                        downloadSpeed:(long long)downloadSpeedInBytes {
    if (progressInPercent < 0.0 || progressInPercent > 1.0) {
        return;
    }
    
    NSInteger percent = 100 * progressInPercent;
    NSString *percentString = [NSString stringWithFormat:@"%ld%%", (long)percent];
    NSString *text = [NSString stringWithFormat:@"加载中...%@\n%@",
                      percentString,
                      [self stringForDownloadSpeedInBytes:downloadSpeedInBytes]];
    [self showLoadingWithDescription:text];
}

- (void)showLoadingWithDescription:(NSString *)descriptionString {
    if (self.isShowingProgressIndicator || self.isShowingTip) {
        return;
    }
    
    [NSObject asyncTaskOnMainWithBlock:^{
        if (!self.loadingView) {
            self.loadingView = [PKLoading nibInstance];
            [self.loadingHolder addSubview:self.loadingView];
        }
        
        [self.loadingView showWithDescription:descriptionString];
    }];
}

- (void)hideLoading {
    if (self.loadingView) {
        PKLoading *loading = self.loadingView;
        [NSObject asyncTaskOnMainWithBlock:^{
            [loading hide];
        }];
    }
}

- (BOOL)isShowingProgressIndicator {
    return self.progressIndicatorView.isShowing;
}

- (void)showProgressIndicatorWithDescription:(NSString *)descriptionString isRewind:(BOOL)isRewind {
    if (self.isShowingTip) {
        return;
    }
    
    [self hideLoading];
    
    if (!self.progressIndicatorView) {
        self.progressIndicatorView = [PKProgressIndicator nibInstance];
        [self.progressIndicatorHolder addSubview:self.progressIndicatorView];
    }
    
    [self.progressIndicatorView showWithDescription:descriptionString isRewind:isRewind];
}

- (void)hideProgressIndicator {
    [self.progressIndicatorView hide];
}

- (BOOL)isShowingTip {
    return self.tipView.isShowing;
}

- (void)showTipWithType:(PKPlayerTipType)type {
    [self hideLoading];
    [self hideProgressIndicator];
    
    if (!self.tipView) {
        self.tipView = [PKTip nibInstance];
        [self.tipHolder addSubview:self.tipView];
    }
    
    [self.tipView showWithType:type];
}

- (void)hideTipWithType:(PKPlayerTipType)type {
    [self.tipView hideWithType:type];
}

- (void)showError:(NSError *)error withCompletionHandler:(void (^) ())completionBlock {
    [NSObject asyncTaskOnMainWithBlock:^{
        self.showErrorCompletionBlock = completionBlock;
#if 0
        NSMutableString *errorMessage = [NSMutableString stringWithFormat:@"[ERROR]: %@\n\n[URL]: %@",
                                         error,
                                         self.videoPlayerCore.videoInfo.playContentURLString];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                     message:errorMessage
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tf = [av textFieldAtIndex:0];
        tf.text = errorMessage;
#else
        NSString *errorMessage = @"加载影片失败";
        if (error.code == 0x80000002) {
            errorMessage = @"资源加载失败，试试退出后重新播放。";
        }
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:errorMessage
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
#endif
        av.tag = kErrorAlertTag;
        [av show];
    }];
}

- (void)showWWANAlertWithCompletionHandler:(void (^) (BOOL cancel))completionBlock {
    [NSObject asyncTaskOnMainWithBlock:^{
        self.showWWANAlertCompletionBlock = completionBlock;
        NSString *message = @"当前为移动数据网络，观看会消耗流量，是否继续？（流量费由运营商收取）";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"取消播放"
                                           otherButtonTitles:@"继续播放" , nil];
        av.tag = kWWANAlertTag;
        [av show];
    }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePlayBtnImage:(BOOL)isPlayImage {
    [NSObject asyncTaskOnMainWithBlock:^{
        UIImage *imageN = nil;
        UIImage *imageH = nil;
        if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
            if (isPlayImage) {
                imageN = [UIImage imageInPKBundleWithName:@"pk_play_btn_n_i5.png"];
                imageH = [UIImage imageInPKBundleWithName:@"pk_play_btn_h_i5.png"];
            } else {
                imageN = [UIImage imageInPKBundleWithName:@"pk_pause_btn_n_i5.png"];
                imageH = [UIImage imageInPKBundleWithName:@"pk_pause_btn_h_i5.png"];
            }
        } else {
            if (isPlayImage) {
                imageN = [UIImage imageInPKBundleWithName:@"pk_play_btn_n.png"];
                imageH = [UIImage imageInPKBundleWithName:@"pk_play_btn_h.png"];
            } else {
                imageN = [UIImage imageInPKBundleWithName:@"pk_pause_btn_n.png"];
                imageH = [UIImage imageInPKBundleWithName:@"pk_pause_btn_h.png"];
            }
        }
        [self.playBtn setBackgroundImage:imageN forState:UIControlStateNormal];
        [self.playBtn setBackgroundImage:imageH forState:UIControlStateHighlighted];
    }];
}

- (BOOL)needShowWWANAlert {
    if (!self.videoPlayerCore.videoInfo.isOnlineVideo) {
        return NO;
    }
    
    BOOL need = NO;
    if (self.sourceManager.reachabilitySource.currentNetworkStatus) {
        PKNetworkStatus status = self.sourceManager.reachabilitySource.currentNetworkStatus();
        if (status == KNetworkStatusReachableViaWWAN) {
            need = YES;
        }
    }
    return need;
}

- (void)showGuide {
    if ([self needShowGuide]) {
        if (!self.guideVC) {
            self.guideVC = [PKGuideViewController nibInstance];
            __weak typeof(self) weakSelf = self;
            [self.guideVC setDismissHandler:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf hideGuide];
            }];
            self.guideVC.view.frame = self.holder.bounds;
            [self.holder addSubview:self.guideVC.view];
            [self addChildViewController:self.guideVC];
            
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:kGuideKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (BOOL)needShowGuide {
    id need = [[NSUserDefaults standardUserDefaults] objectForKey:kGuideKey];
    if (need) {
        return [need boolValue];
    }
    return YES;
}

- (void)hideGuide {
    [self.guideVC.view removeFromSuperview];
    [self.guideVC removeFromParentViewController];
    self.guideVC = nil;
}

- (void)notifyOpenCompleted {
    if (self.sourceManager.playerStatusSource.openCompletedBlock) {
        self.sourceManager.playerStatusSource.openCompletedBlock(self.videoPlayerCore.videoInfo);
    }
}

- (void)notifyPlayCompleted {
    if (self.sourceManager.playerStatusSource.playCompletedBlock) {
        self.sourceManager.playerStatusSource.playCompletedBlock(self.videoPlayerCore.videoInfo);
    }
}

- (void)switchToDLNAPlaying {
    if (self.isDLNAPlaying) {
        return;
    }
    
    PKDLNASource *dlnaSource = self.sourceManager.dlnaSource;
    if (!dlnaSource || !dlnaSource.dlnaDeviceViewBlock || !dlnaSource.dlnaPlayingTipViewBlock) {
        return;
    }
    
    self.isDLNAPlaying = YES;
    self.subtitleBtn.enabled = NO;
    self.dlnaBtn.enabled = NO;
    
    __weak typeof(self) weakSelf = self;
    UIViewController *tipVC = dlnaSource.dlnaPlayingTipViewBlock(^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf switchBackFromDLNAPlaying];
    });
    self.dlnaPlayingTipVC = tipVC;
    self.dlnaPlayingTipVC.view.frame = self.holder.bounds;
    [self.holder insertSubview:self.dlnaPlayingTipVC.view aboveSubview:self.gestureHolder];
    [self addChildViewController:self.dlnaPlayingTipVC];
    
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowHeaderControlOnly;
}

- (void)switchBackFromDLNAPlaying {
    self.isDLNAPlaying = NO;
    [self.dlnaPlayingTipVC.view removeFromSuperview];
    [self.dlnaPlayingTipVC removeFromParentViewController];
    self.dlnaPlayingTipVC = nil;
    
    if (self.needResumePlayAfterDLNA) {
        [self switchToPausedStatus:NO];
    }
    [self initSubtitle];
    [self initDLNA];
    [self initAudioTrack];
    
    self.currentPlayerViewDisplayMode = kPlayerViewDisplayModeShowControlOnly;
    [self startAutoHideControlTimer];
}

- (void)syncSystemInfo {
    self.landscapeBrightnessSlider.progressInPercent = [UIScreen mainScreen].brightness;
    self.landscapeVolumeSlider.progressInPercent = self.videoPlayerCore.volume;
}

- (void)disableControlAndButton {
    [self enableControl:NO];
    self.subtitleBtn.enabled = NO;
    self.dlnaBtn.enabled = NO;
}

- (void)seekForDisplayProgressAndUpdateViews:(NSInteger)progressInMS {
    /// seek统计
    [self doSeekStatisticWithType:YES isRewind:(self.videoPlayerCore.playPositionInMS > progressInMS)];
    
    [self.videoPlayerCore seekWithTimeInMS:progressInMS];
    [self hideProgressIndicator];
}

- (void)showVideoInfo {
#ifdef DEBUG
    NSString *text = nil;
    text = self.videoPlayerCore.videoInfo.playContentURLString;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Video info"
                                                 message:text
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf = [av textFieldAtIndex:0];
    tf.text = text;
    [av show];
#endif
}

- (void)doStartPlayingStatistic {
    if (self.sourceManager.statisticSource.startPlayingStatisticBlock) {
        self.sourceManager.statisticSource.startPlayingStatisticBlock(self.videoPlayerCore.videoInfo);
    }
}

- (void)doStopPlayingStatistic : (PKEndType)endType withError:(NSError *)error {
    if (self.sourceManager.statisticSource.stopPlayingStatisticBlock) {
        NSTimeInterval playTime = [self.videoPlayerCore timeIntervalSinceStartPlaying];
        self.sourceManager.statisticSource.stopPlayingStatisticBlock(endType, playTime, self.videoPlayerCore.videoInfo, error);
    }
}

- (void)doSeekStatisticWithType:(BOOL)isGesture isRewind:(BOOL)isRewind {
    if (self.sourceManager.statisticSource.seekStatisticBlock) {
        self.sourceManager.statisticSource.seekStatisticBlock(isGesture, isRewind);
    }
}

- (void)doEpisodeBtnClickStatistic {
    if (self.sourceManager.statisticSource.episodeBtnClickStatisticBlock) {
        self.sourceManager.statisticSource.episodeBtnClickStatisticBlock();
    }
}

- (void)doSubtitleBtnClickStatistic {
    if (self.sourceManager.statisticSource.subtitleBtnClickStatisticBlock) {
        self.sourceManager.statisticSource.subtitleBtnClickStatisticBlock();
    }
}

- (void)doDisplaymodeChangedStatistic {
    if (self.sourceManager.statisticSource.displaymodeChangedStatisticBlock) {
        self.sourceManager.statisticSource.displaymodeChangedStatisticBlock(self.videoPlayerCore.videoViewDisplayMode);
    }
}

- (void)doDisplayPlayerViewStatistic {
    if (self.sourceManager.statisticSource.displayPlayerViewStatisticBlock) {
        self.sourceManager.statisticSource.displayPlayerViewStatisticBlock();
    }
}

- (void)doDLNABtnClickStatistic {
    if (self.sourceManager.statisticSource.dlnaBtnClickStatisticBlock) {
        self.sourceManager.statisticSource.dlnaBtnClickStatisticBlock();
    }
}

- (void)doUserPauseStatistic : (BOOL)isPauseMode {
    if (self.sourceManager.statisticSource.userPauseStatisticBlock) {
        self.sourceManager.statisticSource.userPauseStatisticBlock(isPauseMode);
    }
}

- (void)doAudioTrackBtnClickStatistic {
    if (self.sourceManager.statisticSource.audioTrackBtnClickStatisticBlock) {
        self.sourceManager.statisticSource.audioTrackBtnClickStatisticBlock();
    }
}

- (void)doAudioTrackInfoStatistic {
    if (self.sourceManager.statisticSource.audioTrackInfoStatisticBlock) {
        self.sourceManager.statisticSource.audioTrackInfoStatisticBlock(self.videoPlayerCore.audioTracks);
    }
}

- (void)donextBtnClickStatistic {
    if (self.sourceManager.statisticSource.nextBtnClickStatisticBlock) {
        self.sourceManager.statisticSource.nextBtnClickStatisticBlock();
    }
}

#pragma mark - PKVideoPlayerCoreDelegate

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
openCompletedWithResult:(BOOL)isReadyForPlaying
              videoInfo:(PKVideoInfo *)videoInfo
                  error:(NSError *)error {
    [self notifyOpenCompleted];

    /// 播放统计
    [self doStartPlayingStatistic];
    
    if (isReadyForPlaying) {
        if (self.videoPlayerCore.isUsingHardwareSpeedup) {
            NSLog(@"[INFO]: 使用硬解加速中...");
        }
        
        [self doAudioTrackInfoStatistic];
        [self initPlay];
    }
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
 seekCompletedWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
  playCompletedWithType:(PKVideoPlayCompletionType)type
                  error:(NSError *)error {
    [self notifyPlayCompleted];
    
    [self resetInit];
    
    if (videoPlayerCore.isSwitching) {
        return;
    }
    
    [self saveRecordForPlayCompletionWithType:type];
    if (type == kVideoPlayCompletionTypeEOF) {
        if (![self switchToNextEpisodeIfNeeded]) {
            
            //播放完成统计
            [self doStopPlayingStatistic:kPlayEndByComplete withError:nil];
            
            [self doQuit];
        }
    } else if (type == kVideoPlayCompletionTypeClosed) {
        
        //手动退出统计
        [self doStopPlayingStatistic:kPlayEndByUser withError:nil];
        
    } else if (type == kVideoPlayCompletionTypeError) {
        
        //播放失败统计
        [self doStopPlayingStatistic:kPlayEndByFail withError:error];
        
        NSInteger errorCode = error.code & 0xffffffff;
        if (errorCode == 0x80000001 || errorCode == 0x80000002) {
            /// 打开失败
        } else {
            /// 播放失败
        }
        
        if (![self switchToNextResolutionIfNeeded]) {
            __weak typeof(self) weakSelf = self;
            [self showError:error withCompletionHandler:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf doQuit];
            }];
        }
    }
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
     playPositionUpdate:(NSInteger)timeInMS {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.isHPanGestureRecognized) {/// 左右拖动时不更新
        return;
    }
    
    [NSObject asyncTaskOnMainWithBlock:^{
        NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
        if (durationInMS == 0) {
            NSLog(@"[WARNING]: Zero duration!\n%s", __FUNCTION__);
            self.progressSlider.progressInPercent = 0;
        } else {
            self.progressSlider.progressInPercent = (double)timeInMS/durationInMS;
        }
        NSString *timeString = [NSString stringWithFormat:@"%@/%@",
                                [self stringForTimeInMS:timeInMS],
                                [self stringForTimeInMS:durationInMS]];
        self.timeLabel.text = timeString;
        [self.timeLabel sizeToFit];
    }];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferPositionUpdate:(NSInteger)timeInMS {
    NSLog(@"%s", __FUNCTION__);
    [NSObject asyncTaskOnMainWithBlock:^{
        NSInteger durationInMS = self.videoPlayerCore.videoInfo.videoDurationInMS;
        if (durationInMS <= 0) {
            NSLog(@"[WARNING]: Zero duration!\n%s", __FUNCTION__);
            self.progressSlider.bufferProgressInPercent = 0;
        } else {
            self.progressSlider.bufferProgressInPercent = (double)timeInMS/durationInMS;
        }
    } delay:.3];
}

- (void)videoPlayerCore:(PKVideoPlayerCoreBase *)videoPlayerCore
   bufferProgressUpdate:(CGFloat)progressInPercent {
    NSLog(@"%s", __FUNCTION__);
    if (progressInPercent < 1.0) {
        if (!self.videoPlayerCore.isPaused) {
            [self showLoadingWithBufferProgress:progressInPercent
                                  downloadSpeed:self.videoPlayerCore.downloadSpeedInBytes];
        }
    } else {
        [self hideLoading];
        if (!self.bufferHasBeenFull) {
            self.bufferHasBeenFull = YES;
            if (self.currentPlayerViewDisplayMode == kPlayerViewDisplayModeShowControlOnly) {
                [self startAutoHideControlTimer];
            }
        }
    }
}

#pragma mark - PKSliderDelegate

- (void)sliderProgressValueChanged:(PKSlider *)slider {
    if (slider == self.progressSlider) {/// 进度
        NSInteger positionInMS = slider.progressInPercent*self.videoPlayerCore.videoInfo.videoDurationInMS;
        NSString *description = [self stringForTimeInMS:positionInMS];
        CGPoint center = CGPointMake(slider.thumbBtnCenterInSlider.x,
                                     self.progressDescriptionView.center.y);
        [self.progressDescriptionView showDescription:description
                                           withCenter:center
                                             autoHide:!slider.isUserInteracting];
        
        if (!slider.isUserInteracting) {
            if (self.videoPlayerCore.videoInfo.isOnlineVideo && !self.videoPlayerCore.isPaused) {
                [self showLoadingWithBufferProgress:0.0 downloadSpeed:0];
            }
            
            /// seek统计
            [self doSeekStatisticWithType:NO isRewind:NO];
            
            [self.videoPlayerCore seekWithProgress:slider.progressInPercent];
            [self startAutoHideControlTimer];
        } else {
            [self stopAutoHideControlTimer];
        }
    } else if (slider == self.landscapeVolumeSlider) {/// 声音
        [self changeVolume:slider.progressInPercent];
        if (!slider.isUserInteracting) {
            [self startAutoHideControlTimer];
        } else {
            [self stopAutoHideControlTimer];
        }
    } else if (slider == self.landscapeBrightnessSlider) {/// 亮度
        [UIScreen mainScreen].brightness = slider.progressInPercent;
        if (!slider.isUserInteracting) {
            [self startAutoHideControlTimer];
        } else {
            [self stopAutoHideControlTimer];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kErrorAlertTag) {
        if (self.showErrorCompletionBlock) {
            self.showErrorCompletionBlock();
            self.showErrorCompletionBlock = nil;
        }
    } else if (alertView.tag == kWWANAlertTag) {
        BOOL cancel = YES;
        if (buttonIndex != 0) {
            cancel = NO;
        }
        if (self.showWWANAlertCompletionBlock) {
            self.showWWANAlertCompletionBlock(cancel);
            self.showWWANAlertCompletionBlock = nil;
        }
    }
}

#pragma mark - WEPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    if (!popoverController) {
        return;
    }
    
    [self startAutoHideControlTimer];
    if (popoverController == self.resolutionPController) {
        self.resolutionBtn.selected = NO;
        self.resolutionPController = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    PKEpisodeCellType type = kEpisodeCellTypeMutilEpisode;
    if (episodeSource.episodeCellTypeBlock) {
        type = episodeSource.episodeCellTypeBlock();
    }
    NSInteger count = 0;
    if (episodeSource.availableEpisodeTitleArrayBlock) {
        count = episodeSource.availableEpisodeTitleArrayBlock().count;
    }
    if (count <= 0) {
        return 0;
    }
    if (type == kEpisodeCellTypeSingleEpisode) {
        return count;
    } else {
        return (count-1)/3+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    PKEpisodeCellType type = kEpisodeCellTypeMutilEpisode;
    if (episodeSource.episodeCellTypeBlock) {
        type = episodeSource.episodeCellTypeBlock();
    }
    NSArray *availableEpisodeTitleArray = nil;
    if (episodeSource.availableEpisodeTitleArrayBlock) {
        availableEpisodeTitleArray = episodeSource.availableEpisodeTitleArrayBlock();
    }
    NSInteger currentEpisodeIndex = -1;
    if (episodeSource.currentEpisodeIndexBlock) {
        currentEpisodeIndex = episodeSource.currentEpisodeIndexBlock();
    }
    
    NSInteger row = indexPath.row;
    
    if (type == kEpisodeCellTypeMutilEpisode) {
        PKMutilEpisodeCell *cell =  [tableView dequeueReusableCellWithIdentifier:kMutilEpisodeCellIdentifier];
        cell.delegate = self;
        
        for (NSInteger i = 0; i < 3; ++i) {
            NSInteger index = row*3+i;
            PKMutilEpisodeCellColumnDisplayMode columnDisplayMode = kMutilEpisodeCellColumnDisplayModeUnselected;
            if (index == currentEpisodeIndex) {
                columnDisplayMode = kMutilEpisodeCellColumnDisplayModeSelected;
            } else if (index >= availableEpisodeTitleArray.count) {
                columnDisplayMode = kMutilEpisodeCellColumnDisplayModeInvisible;
            }
            NSString *columnTitle = nil;
            if (columnDisplayMode != kMutilEpisodeCellColumnDisplayModeInvisible) {
                columnTitle = availableEpisodeTitleArray[index];
            }
            [cell setColumnTitle:columnTitle displayMode:columnDisplayMode withColumnIndex:i];
        }
        
        return cell;
    } else {
        PKSingleEpisodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleEpisodeCellIdentifier];
        
        static UIView *singleEpisodeCellBgView = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleEpisodeCellBgView = [[UIView alloc] init];
            singleEpisodeCellBgView.backgroundColor = [UIColor clearColor];
        });
        if (cell.selectedBackgroundView != singleEpisodeCellBgView) {
            cell.selectedBackgroundView = singleEpisodeCellBgView;
        }
        
        cell.episodeLabel.text = availableEpisodeTitleArray[row];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    PKEpisodeCellType type = kEpisodeCellTypeMutilEpisode;
    if (episodeSource.episodeCellTypeBlock) {
        type = episodeSource.episodeCellTypeBlock();
    }
    if (type == kEpisodeCellTypeSingleEpisode) {
        if ([UIDevice isIPad]) {
            return 72;
        } else if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
            return 41;
        } else {
            return 51;
        }
    } else {
        if ([UIDevice isIPad]) {
            return 80;
        } else if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
            return 40;
        } else {
            return 48;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PKEpisodeSource *episodeSource = self.sourceManager.episodeSource;
    PKEpisodeCellType type = kEpisodeCellTypeMutilEpisode;
    if (episodeSource.episodeCellTypeBlock) {
        type = episodeSource.episodeCellTypeBlock();
    }
    NSInteger currentEpisodeIndex = -1;
    if (episodeSource.currentEpisodeIndexBlock) {
        currentEpisodeIndex = episodeSource.currentEpisodeIndexBlock();
    }
    if (type == kEpisodeCellTypeSingleEpisode) {
        if (indexPath.row != currentEpisodeIndex) {
            [self switchWithEpisodeIndex:indexPath.row];
        }
    }
}

#pragma mark - PKMutilEpisodeCellDelegate

- (void)columnSelectionChangedWithCell:(PKMutilEpisodeCell *)cell
                   selectedColumnIndex:(NSInteger)columnIndex {
    NSIndexPath *indexPath = [self.episodeTableView indexPathForCell:cell];
    NSInteger newIndex = indexPath.row*3+columnIndex;
    
    [self switchWithEpisodeIndex:newIndex];
}

@end
