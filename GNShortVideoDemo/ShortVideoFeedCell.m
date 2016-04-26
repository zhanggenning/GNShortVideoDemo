//
//  ShortVideoFeedCell.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShortVideoFeedCell.h"
#import "ShortVideoControlFlagView.h"
#import "ShortVideoFeedCellModel.h"

@interface ShortVideoFeedCell ()

@property (weak, nonatomic) IBOutlet UILabel *mainTitleLab;
@property (weak, nonatomic) IBOutlet UIImageView *bkImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet ShortVideoControlFlagView *funControlView;
@property (weak, nonatomic) IBOutlet ShortVideoControlFlagView *commentControlView;
@property (weak, nonatomic) IBOutlet ShortVideoControlFlagView *shareControlView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_imgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_userInfoHeight;

@end

@implementation ShortVideoFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _funControlView.controlStyle = ShortVideoControlFlagFun;
    _commentControlView.controlStyle = ShortVideoControlFlagComment;
    _shareControlView.controlStyle = ShortVideoControlFlagShare;
    
    [_funControlView addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
    [_commentControlView addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
    [_shareControlView addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//转换时间格式
- (NSString *)formatTimeWithSecond:(NSInteger)second
{
    static NSDateFormatter *dateFormatter = nil;
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if (second/3600 >= 1)
    {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    else
    {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:d];
    
    return showtimeNew;
}

- (void)configCellWithCellModel:(ShortVideoFeedCellModel *)cellModel
{
    //背景图片
    
    //题目
    _mainTitleLab.text = cellModel.mainTitle;
    
    //时长
    _durationLab.text = [self formatTimeWithSecond:cellModel.duration];
    
    //用户头像
    
    //用户名称
    _userNameLab.text = cellModel.userName;
    
    //赞的配置
    [_funControlView setFlag:cellModel.isZanFlagged count:cellModel.zanCount animation:NO];
    
    //评论的配置
    [_commentControlView setFlag:NO count:cellModel.commentCount animation:NO];
}

#pragma mark -- 事件
- (void)controlAction:(UIControl *)sender
{
    if (sender == _funControlView)
    {
        //点击赞
        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoFeedCellClickedZan:indexPath:)])
        {
            [_delegate shortVideoFeedCellClickedZan:self indexPath:_indexPath];
        }
    }
    else if (sender == _commentControlView)
    {
        //点击评论
        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoFeedCellClickedComment:indexPath:)])
        {
            [_delegate shortVideoFeedCellClickedComment:self indexPath:_indexPath];
        }
    }
    else if (sender == _shareControlView)
    {
        //点击分享
        if (_delegate && [_delegate respondsToSelector:@selector(shortVideoFeedCellClickedShare:indexPath:)])
        {
            [_delegate shortVideoFeedCellClickedShare:self indexPath:_indexPath];
        }
    }
}

- (IBAction)imgBtnAction:(UIButton *)sender
{
    //点击图片
    if (_delegate && [_delegate respondsToSelector:@selector(shortVideoFeedCellClickedImage:indexPath:imageFrame:)])
    {
        [_delegate shortVideoFeedCellClickedImage:self indexPath:_indexPath imageFrame:_bkImageView.frame];
    }
}

#pragma mark -- 属性
- (void)setCellModel:(ShortVideoFeedCellModel *)cellModel
{
    _cellModel = cellModel;
    
    [self configCellWithCellModel:cellModel];
}

#pragma mark -- 公共API
- (CGFloat)cellHeight
{
    CGFloat imgHeight = _constraint_imgHeight.constant;
    CGFloat userInfoHeight = _constraint_userInfoHeight.constant;
    
    return imgHeight + userInfoHeight + 1.0;
}

+ (instancetype)cellInstance
{
    ShortVideoFeedCell *cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    return cell;
}

- (void)configZanFlag:(BOOL)isFlag count:(NSInteger)count animate:(BOOL)animate
{
    [_funControlView setFlag:isFlag count:count animation:animate];
    
    _cellModel.isZanFlagged = isFlag;
    _cellModel.zanCount = count;
}

@end
