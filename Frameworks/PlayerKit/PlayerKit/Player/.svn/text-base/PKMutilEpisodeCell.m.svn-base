//
//  PKMutilEpisodeCell.m
//  iThunder
//
//  Created by luckyli on 14-6-13.
//  Copyright (c) 2014年 xunlei.com. All rights reserved.
//

#import "PKMutilEpisodeCell.h"

#pragma mark -
@interface PKMutilEpisodeCell ()

@property (weak, nonatomic) IBOutlet UIButton *columnBtn0;
@property (weak, nonatomic) IBOutlet UIButton *columnBtn1;
@property (weak, nonatomic) IBOutlet UIButton *columnBtn2;

- (IBAction)columnBtnAction:(UIButton *)sender;

- (UIButton *)columnBtnWithIndex:(NSInteger)columnIndex;

@end

#pragma mark -
@implementation PKMutilEpisodeCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public

- (void)setColumnTitle:(NSString *)title
           displayMode:(PKMutilEpisodeCellColumnDisplayMode)mode
       withColumnIndex:(NSInteger)columnIndex {
    UIButton *columnBtn = [self columnBtnWithIndex:columnIndex];
    [columnBtn setTitle:title forState:UIControlStateNormal];
    columnBtn.hidden = (mode == kMutilEpisodeCellColumnDisplayModeInvisible);
    columnBtn.selected = (mode == kMutilEpisodeCellColumnDisplayModeSelected);
}

#pragma mark - Private

- (IBAction)columnBtnAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    
    if (self.delegate && [(id)self.delegate respondsToSelector:@selector(columnSelectionChangedWithCell:selectedColumnIndex:)]) {
        [self.delegate columnSelectionChangedWithCell:self selectedColumnIndex:sender.tag];
    }
}

- (UIButton *)columnBtnWithIndex:(NSInteger)columnIndex {
    UIButton *btn = nil;
    if (columnIndex == 0) {
        btn = self.columnBtn0;
    } else if  (columnIndex == 1) {
        btn = self.columnBtn1;
    } else if (columnIndex == 2) {
        btn = self.columnBtn2;
    }
    return btn;
}

@end
