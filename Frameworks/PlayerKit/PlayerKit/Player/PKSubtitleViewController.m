//
//  PKSubtitleViewController.m
//  PlayerKit
//
//  Created by lucky.li on 15/4/3.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKSubtitleViewController.h"
#import "NSBundle+pk.h"
#import "UIDevice+pk.h"
#import "PKSubtitleCell.h"

#pragma mark -

static NSString *const kSubtitleCellIdentifier = @"subtitle_cell_identifier";

#pragma mark -
@interface PKSubtitleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSourceArray;
@property (assign, nonatomic) NSInteger currentIndex;

@end

#pragma mark -
@implementation PKSubtitleViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSBundle *bundle = [NSBundle pkBundle];
    UINib *subtitleCellNib = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        subtitleCellNib = [UINib nibWithNibName:@"PKSubtitleCell_i5" bundle:bundle];
        self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    } else {
        subtitleCellNib = [UINib nibWithNibName:NSStringFromClass([PKSubtitleCell class]) bundle:bundle];
    }
    [self.tableView registerNib:subtitleCellNib
         forCellReuseIdentifier:kSubtitleCellIdentifier];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKSubtitleViewController *vc = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        vc = [[PKSubtitleViewController alloc] initWithNibName:@"PKSubtitleViewController_i5"
                                                        bundle:bundle];
    } else {
        vc = [[PKSubtitleViewController alloc] initWithNibName:NSStringFromClass([self class])
                                                        bundle:bundle];
    }
    return vc;
}

- (void)setDataSourceArray:(NSArray *)dataSourceArray currentIndex:(NSInteger)currentIndex {
    self.dataSourceArray = dataSourceArray;
    self.currentIndex = currentIndex;
    
    if (self.tableView) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKSubtitleCell *cell =  [tableView dequeueReusableCellWithIdentifier:kSubtitleCellIdentifier];
    
    static UIView *subtitleCellBgView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        subtitleCellBgView = [[UIView alloc] init];
        subtitleCellBgView.backgroundColor = [UIColor clearColor];
    });
    if (cell.selectedBackgroundView != subtitleCellBgView) {
        cell.selectedBackgroundView = subtitleCellBgView;
    }
    
    NSString *text = self.dataSourceArray[indexPath.row];
    cell.subtitleLabel.text = text;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.currentIndex) {
        self.currentIndex = indexPath.row;
        
        if (self.selectionChangeHandler) {
            self.selectionChangeHandler(self.currentIndex);
        }
    }
}

@end
