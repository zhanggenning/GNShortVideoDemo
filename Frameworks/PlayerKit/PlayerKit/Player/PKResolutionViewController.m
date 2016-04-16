//
//  PKResolutionViewController.m
//  PlayerKit
//
//  Created by lucky.li on 15/3/25.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKResolutionViewController.h"
#import "UIDevice+pk.h"
#import "UIImage+pk.h"
#import "UIColor+pk.h"
#import "NSBundle+pk.h"

#pragma mark -

static const CGFloat kRowWidth = 71;
static const CGFloat kRowHeight = 36;
static const CGFloat kRowWidthPad = 83;
static const CGFloat kRowHeightPad = 40;
static const NSInteger kNormalColorHexValue = 0xffffff;
static const NSInteger kSelectedColorHexValue = 0x4375e1;

#pragma mark -
@interface PKResolutionViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSourceArray;
@property (assign, nonatomic) NSInteger currentIndex;

///
- (void)updateFrame;

@end

#pragma mark -
@implementation PKResolutionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CGFloat rowWidth = kRowWidth;
        CGFloat rowHeight = kRowHeight;
        if ([UIDevice isIPad]) {
            rowWidth = kRowWidthPad;
            rowHeight = kRowHeightPad;
        }
        CGSize popSize = CGSizeMake(rowWidth, rowHeight*3);
        if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
            self.preferredContentSize = popSize;
        } else {
            self.contentSizeForViewInPopover = popSize;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    [self updateFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKResolutionViewController *rvc =
    [[PKResolutionViewController alloc] initWithNibName:NSStringFromClass([self class])
                                                 bundle:bundle];
    return rvc;
}

- (void)setDataSourceArray:(NSArray *)dataSourceArray currentIndex:(NSInteger)currentIndex {
    self.dataSourceArray = dataSourceArray;
    self.currentIndex = currentIndex;
    
    [self updateFrame];
    
    if (self.tableView) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        [self.tableView reloadData];
    }
}

#pragma mark - Private

- (void)updateFrame {
    CGFloat rowWidth = kRowWidth;
    CGFloat rowHeight = kRowHeight;
    if ([UIDevice isIPad]) {
        rowWidth = kRowWidthPad;
        rowHeight = kRowHeightPad;
    }
    CGSize popSize = CGSizeMake(rowWidth, rowHeight*self.dataSourceArray.count);
    if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
        self.preferredContentSize = popSize;
    } else {
        self.contentSizeForViewInPopover = popSize;
    }
    
    if (self.tableView) {
        self.tableView.frame = CGRectMake(0, 0, popSize.width, popSize.height);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellIdentifier = @"cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if ([UIDevice isIPad]) {
            cell.textLabel.font = [UIFont systemFontOfSize:17];
        } else if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        } else {
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        
        UIImageView *bg = [[UIImageView alloc] init];
        bg.image = [UIImage imageInPKBundleWithName:@"pk_resolution_selection_bg.png"];
        cell.selectedBackgroundView = bg;
    }
    
    NSString *text = self.dataSourceArray[indexPath.row];
    cell.textLabel.text = text;
    if (indexPath.row == self.currentIndex) {
        cell.textLabel.textColor = [UIColor colorWithHexValue:kSelectedColorHexValue alpha:1.0];
    } else {
        cell.textLabel.textColor = [UIColor colorWithHexValue:kNormalColorHexValue alpha:1.0];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.currentIndex) {
        self.currentIndex = indexPath.row;
        
        if (self.selectionChangeHandler) {
            self.selectionChangeHandler(self.currentIndex);
        }
    }
}

@end
