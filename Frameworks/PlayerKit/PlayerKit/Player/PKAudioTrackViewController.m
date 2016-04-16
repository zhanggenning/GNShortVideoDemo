//
//  PKAudioTrackViewController.m
//  PlayerKit
//
//  Created by lucky.li on 15/7/1.
//  Copyright (c) 2015年 xunlei. All rights reserved.
//

#import "PKAudioTrackViewController.h"
#import "NSBundle+pk.h"
#import "UIDevice+pk.h"
#import "PKAudioTrackCell.h"

#pragma mark -

static NSString *const kCellIdentifier = @"cell_identifier";

#pragma mark -
@interface PKAudioTrackViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSourceArray;
@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation PKAudioTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSBundle *bundle = [NSBundle pkBundle];
    UINib *cellNib = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        cellNib = [UINib nibWithNibName:@"PKAudioTrackCell_i5" bundle:bundle];
        self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    } else {
        cellNib = [UINib nibWithNibName:NSStringFromClass([PKAudioTrackCell class]) bundle:bundle];
    }
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:kCellIdentifier];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Public

+ (instancetype)nibInstance {
    NSBundle *bundle = [NSBundle pkBundle];
    PKAudioTrackViewController *vc = nil;
    if ([UIDevice isIphone_480] || [UIDevice isIphone_568]) {
        vc = [[PKAudioTrackViewController alloc] initWithNibName:@"PKAudioTrackViewController_i5"
                                                          bundle:bundle];
    } else {
        vc = [[PKAudioTrackViewController alloc] initWithNibName:NSStringFromClass([self class])
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
    PKAudioTrackCell *cell =  [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    static UIView *cellBgView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellBgView = [[UIView alloc] init];
        cellBgView.backgroundColor = [UIColor clearColor];
    });
    if (cell.selectedBackgroundView != cellBgView) {
        cell.selectedBackgroundView = cellBgView;
    }
    
    NSString *text = self.dataSourceArray[indexPath.row];
    cell.descriptionLabel.text = text;
    
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
