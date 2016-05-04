//
//  ShorVideoFeedViewController.m
//  GNShortVideoDemo
//
//  Created by zhanggenning on 16/4/25.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "ShorVideoFeedViewController.h"
#import "ShortVideoFeedCell.h"
#import "ShortVideoFeedCellModel.h"
#import "ShortVideoPlayerManger.h"

@interface ShorVideoFeedViewController () <UITableViewDelegate, UITableViewDataSource, ShortVideoFeedCellProtocol>

@property (nonatomic, strong) ShortVideoFeedCellModel *cellModel;
@property (strong, nonatomic) ShortVideoFeedCell *heightCell;
@property (weak, nonatomic) IBOutlet UITableView *shortVideoFeedTab;
@property (weak, nonatomic) UIViewController *playerVC;
@end

@implementation ShorVideoFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [_shortVideoFeedTab registerNib:[UINib nibWithNibName:NSStringFromClass([ShortVideoFeedCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark -- 属性
- (ShortVideoFeedCell *)heightCell
{
    if (!_heightCell)
    {
        _heightCell = [ShortVideoFeedCell cellInstance];
    }
    return _heightCell;
}

- (ShortVideoFeedCellModel *)cellModel
{
    if (!_cellModel)
    {
        _cellModel = [[ShortVideoFeedCellModel alloc] init];
        _cellModel.mainTitle = @"两行标题测试两行标题测试两行标题测试两行标题测试两行标题测试两行标题测试";
        _cellModel.userName = @"单行用户名";
        _cellModel.isZanFlagged = NO;
        _cellModel.zanCount = 999;
        _cellModel.commentCount = 999;
        _cellModel.duration = 128;
        _cellModel.videoUrl = @"http://flv2.bn.netease.com/tvmrepo/2016/4/R/V/EBKGQHARV/SD/EBKGQHARV-mobile.mp4";
    }
    return _cellModel;
}

#pragma mark -- <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShortVideoFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.cellModel = self.cellModel;
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self.heightCell cellHeight];

    return height;
}

#pragma mark -- <ShortVideoFeedCellProtocol>
//点击赞
- (void)shortVideoFeedCellClickedZan:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath
{

}

//点击评论
- (void)shortVideoFeedCellClickedComment:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
}

//点击分享
- (void)shortVideoFeedCellClickedShare:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath
{

}

//点击图片
- (void)shortVideoFeedCellClickedImage:(ShortVideoFeedCell *)cell indexPath:(NSIndexPath *)indexPath imageFrame:(CGRect)imageFrame
{
    //更新配置
    if (!_playerVC)
    {
        _playerVC = [[ShortVideoPlayerManger shareInstance] playerWithVideoUrl:cell.cellModel.videoUrl
                                                                    videoTitle:cell.cellModel.mainTitle
                                                                    isVertical:cell.cellModel.videoIsVertical];
    }
    else
    {
        [[ShortVideoPlayerManger shareInstance] resetPlayerWithVideoUrl:cell.cellModel.videoUrl
                                                             videoTitle:cell.cellModel.mainTitle
                                                             isVertical:cell.cellModel.videoIsVertical];
    }
    
    //移除
    if (_playerVC.parentViewController) {
        [_playerVC removeFromParentViewController];
    }
    if (_playerVC.view.superview) {
        [_playerVC.view removeFromSuperview];
    }
    
    //添加
    _playerVC.view.frame = [cell convertRect:imageFrame toView:_shortVideoFeedTab];
    [self addChildViewController:_playerVC];
    [_shortVideoFeedTab addSubview:_playerVC.view];
}
@end
