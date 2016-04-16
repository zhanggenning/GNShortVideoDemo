//
//  PKMutilEpisodeCell.h
//  iThunder
//
//  Created by luckyli on 14-6-13.
//  Copyright (c) 2014年 xunlei.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKMutilEpisodeCell;

/// 集数按钮显示模式
typedef NS_ENUM(NSInteger, PKMutilEpisodeCellColumnDisplayMode) {
    kMutilEpisodeCellColumnDisplayModeInvisible=0,  // 不可见
    kMutilEpisodeCellColumnDisplayModeUnselected,   // 可见，未选中状态
    kMutilEpisodeCellColumnDisplayModeSelected,     // 可见，选中状态
};

#pragma mark -
@protocol PKMutilEpisodeCellDelegate

@optional

/// 按钮点击
- (void)columnSelectionChangedWithCell:(PKMutilEpisodeCell *)cell
                   selectedColumnIndex:(NSInteger)columnIndex;

@end

#pragma mark -
@interface PKMutilEpisodeCell : UITableViewCell

@property (assign, nonatomic) id<PKMutilEpisodeCellDelegate> delegate;

- (void)setColumnTitle:(NSString *)title
           displayMode:(PKMutilEpisodeCellColumnDisplayMode)mode
       withColumnIndex:(NSInteger)columnIndex;

@end
