//
//  ShortVideoFeedCell.h
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ShortVideoFeedCellProtocol;
@class ShortVideoFeedCellModel;

@interface ShortVideoFeedCell : UITableViewCell

@property (nonatomic, weak) NSIndexPath *indexPath;

@property (nonatomic, strong) ShortVideoFeedCellModel *cellModel;

@property (nonatomic, weak) id<ShortVideoFeedCellProtocol> delegate;

+ (instancetype)cellInstance;

- (CGFloat)cellHeight;

- (void)configZanFlag:(BOOL)isFlag count:(NSInteger)count animate:(BOOL)animate;

@end


@protocol ShortVideoFeedCellProtocol <NSObject>

//点击赞
- (void)shortVideoFeedCellClickedZan:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath;

//点击评论
- (void)shortVideoFeedCellClickedComment:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath;

//点击分享
- (void)shortVideoFeedCellClickedShare:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath;

//点击图片
- (void)shortVideoFeedCellClickedImage:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath imageFrame:(CGRect)imageFrame;

@end