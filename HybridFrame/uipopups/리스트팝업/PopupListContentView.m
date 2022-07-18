//
//  PopupListContentView.m
//  SCiP
//
//  Created by ym on 2016. 1. 14..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import "PopupListContentView.h"
#import "PopupListView.h"

@interface PopupListContentView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topMarginConstraint;
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation PopupListContentView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.titleView];
    self.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setHiddenTitleView:(BOOL)hiddenTitleView
{
    _hiddenTitleView = hiddenTitleView;
    if (hiddenTitleView) {
        self.titleView.hidden = YES;
        self.topMarginConstraint.constant = 0;
    }
    else {
        self.titleView.hidden = NO;
        self.topMarginConstraint.constant = self.titleView.frame.size.height;
    }
    
    [self.tableView setNeedsUpdateConstraints];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

#pragma mark - EventHandlers
- (IBAction)closeButtonTouched:(id)sender
{
    [self.delegate popupListContentView:self didSelectAtIndex:-1];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *Identifier = self.cellName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:self.cellName owner:self options:nil];
        cell = [nibs lastObject];
    }
    
    NSDictionary *item = [self.dataList objectAtIndex:indexPath.row];
    id title  = item[kPopListCellTitleKey];
    if ([title isKindOfClass:[NSAttributedString class]]) {
        [cell.textLabel setAttributedText:title];
    } else {
        cell.textLabel.text = title;
        cell.textLabel.font = [UIFont systemFontOfSize:kCellFontSize];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate popupListContentView:self didSelectAtIndex:indexPath.row];
}

@end
