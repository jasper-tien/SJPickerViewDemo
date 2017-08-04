//
//  SJPickerView.m
//  选择器
//
//  Created by tianmaotao on 2017/7/7.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import "SJPickerView.h"

@implementation SJIndexPath

@end

#define TABLEVIEWCELL_ID @"tableViewCellID"
#define SIGN_VIEW_HIGHT 3               //标记view条的高度
#define SIGN_VIEW_WIDTH 60              //标记view条的宽度
#define ITEMS_SRCOLLVIEW_HIGHT 53       //放item的srcollview的高度
#define TITLE_LABEL_HIGHT 40            //标题label的高度
#define ITEM_SPACING 25                 //item间的间隔


@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *hook;
/* 设置单元格的标题 */
- (void)setCellTitle:(NSString *)title;

@end

@implementation CustomTableViewCell
- (void)setCellTitle:(NSString *)title {
    if (!title || ![title isKindOfClass:[NSString class]]) {
        return;
    }
    
    CGFloat labelW = [self getTitleWidthFont:[UIFont fontWithName:@"PingFangSC-Light" size:14] content:title];
    self.titleLabel.frame = CGRectMake(25, 0, labelW, 60);
    self.titleLabel.text = title;
    self.hook.frame = CGRectMake(labelW + 25 + 8, self.hook.frame.origin.y, self.hook.frame.size.width, self.hook.frame.size.height);
}

//获取指定字符串的长度
- (CGFloat)getTitleWidthFont:(UIFont *)font content:(NSString *)text{
    if (!text || ![text isKindOfClass:[NSString class]]) {
        return -1;
    }
    
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    
    NSDictionary *attribute = @{NSFontAttributeName : font};
    CGSize size=[text sizeWithAttributes:attribute];
    
    return size.width + 20;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIImageView *)hook {
    if (!_hook) {
        _hook = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 14, 11)];
        _hook.image = [UIImage imageNamed:@"ic_xuanze"];
        _hook.hidden = YES;
        [self addSubview:_hook];
    }
    
    return _hook;
}

@end

@interface SJPickerView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;           //显示源数据的tableview
@property (nonatomic, strong) UIScrollView *itemsSrcollView;    //已经选择item背景view
@property (nonatomic, strong) UILabel *titleLabel;              //标题view
@property (nonatomic, strong) UIView *partingView;              //分割线
@property (nonatomic, strong) UIView *contentBackgroundView;    //存放内容背景view
@property (nonatomic, strong) UIView *backgroundView;           //背景view
@property (nonatomic, strong) UIView *signView;                 //标记待选择的item
@property (nonatomic, strong) UIButton *backBtn;                //返回
@property (nonatomic, assign) NSInteger indexItem;              //记录正在选择的item，即正在选择的艺术品分类下标

@property (nonatomic, strong) NSLayoutConstraint *contentBackgroundBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentBackgroundHeightConstraint;

@end

@implementation SJPickerView

#pragma mark - init
- (void)dealloc {
    
}

- (instancetype)initWithSourceDatas:(NSArray *)datas {
    if (self = [super init]) {
        [self initWithTableViewDatas:datas];
    }
    
    return self;
}

- (void)initWithTableViewDatas:(NSArray *)datas {
    self.backgroundColor = [UIColor clearColor];
    UIView* screenView = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self.frame = screenView.frame;
    
    [self triggerInitialize];
    
    _indexItem = 0;
    _itemCount = 1;
    
    _items = [NSMutableArray array];
    _indexPaths = [NSMutableArray array];
    _selectDatas = [NSMutableArray array];
    _sourceDatas = [NSMutableArray array];
    
    if (datas) {
        [self reloadTableViewWithDatas:datas];
    }
    
    UIButton *item = [self createButtonWithTitle:@"请选择" font:[UIFont fontWithName:@"PingFang-SC-Regular" size:14]];
    if (item) {
        [self.itemsSrcollView addSubview:item];
        [_items addObject:item];
        self.signView.frame = CGRectMake(ITEM_SPACING, ITEMS_SRCOLLVIEW_HIGHT - SIGN_VIEW_HIGHT, SIGN_VIEW_WIDTH, SIGN_VIEW_HIGHT);
        }
}

//触发view的get方法，初始化
- (void)triggerInitialize {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideView)];
    [self.backgroundView addGestureRecognizer:tap];
    self.contentBackgroundView.backgroundColor = [UIColor whiteColor];
    self.partingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.signView.backgroundColor = [UIColor blackColor];
    [self.backBtn setImage:[UIImage imageNamed:@"ic_YSPFL_delete"] forState:UIControlStateNormal];
    [self layoutIfNeeded];
}

#pragma mark - public methods
//刷新本view的数据,即刷新tableview的数据
//注意：点击单元格以后调用该方法
- (void)didSelectRowReloadPickerView {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(sourceDatasOfRows)]) {
        NSArray *datas = [self.dataSource sourceDatasOfRows];
        
        [self reloadTableViewWithDatas:datas];
    }
}

//显示本view
- (void)showInView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return;
    }
    
    if (_superView != view) {
        _superView = view;
        [_superView addSubview:self];
    }
    
    self.hidden = NO;
    self.titleLabel.text = self.title;

    self.contentBackgroundBottomConstraint.constant = CGRectGetHeight(self.contentBackgroundView.frame);
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.contentBackgroundBottomConstraint.constant = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

//隐藏本view
- (void)hideView {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentBackgroundBottomConstraint.constant = CGRectGetHeight(self.contentBackgroundView.frame);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - event response
- (void)back {
    [self hideView];
}

- (void)itemAction:(UIButton *)button {
    NSInteger tagIndex = button.tag - 1000;
    if (tagIndex < self.indexItem) {
        //移除点击item对应的源数组后面的数组
        [self.sourceDatas removeObjectsInRange:NSMakeRange(tagIndex + 1, self.sourceDatas.count - tagIndex -1)];
        //移除点击item对应选择项的title以后的所有数据，包括它自己对应的。
        [self.selectDatas removeObjectsInRange:NSMakeRange(tagIndex , self.selectDatas.count - tagIndex)];
        //移除点击item对应选择项的indexPath以后的所有数据，包括它自己对应的。
        [self.indexPaths removeObjectsInRange:NSMakeRange(tagIndex , self.indexPaths.count - tagIndex)];
        
        [self removeItemAtIndex:tagIndex];
        
        UIButton *item = [self.items lastObject];
        [self showItemInScrollViewWithItem:item isRightOffset:NO];
        self.indexItem = tagIndex;
        
        [self reloadTableViewWithDatas:[self.sourceDatas lastObject]];
    }
}

#pragma mark - private methods
//移除点击item后面的item
- (void)removeItemAtIndex:(NSInteger)index {
    for (NSInteger i = (self.items.count - 1); i > index ; i--) {
        UIButton *item = self.items[i];
        [self.items removeObject:item];
        [item removeFromSuperview];
    }
}

//创建一个新的item
- (void)newItem {
    //创建一个新的item
    UIButton *item = [self createButtonWithTitle:@"请选择" font:[UIFont fontWithName:@"PingFang-SC-Regular" size:14]];
    if (item) {
        [self.itemsSrcollView addSubview:item];
        [_items addObject:item];
        [self showItemInScrollViewWithItem:item isRightOffset:YES];
    }
}

//创建button
- (UIButton *)createButtonWithTitle:(NSString *)title font:(UIFont *)font{
    if (!title || ![title isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    CGFloat itemW = [self getTitleWidthFont:font content:title];
    if (itemW < 0) {
        itemW = 60;
    }
    
    CGFloat pointX = 0;
    if (self.items.count != 0 ) {
        UIButton *lastItem = [self.items lastObject];
        pointX = lastItem.frame.origin.x + lastItem.frame.size.width + ITEM_SPACING;
    } else {
        pointX = ITEM_SPACING;
    }
    
    UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(pointX, 0, itemW, 40)];
    item.titleLabel.font = font;
    item.tag = 1000 + self.indexItem;
    
    [item setTitle:title forState:UIControlStateNormal];
    [item setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return item;
}

//设置当前选择的item的title
- (void)setLastItemTitle:(NSString *)title {
    if (!title) {
        return;
    }
    
    UIButton *lastItem = [self.items lastObject];
    [lastItem setTitle:title forState:UIControlStateNormal];
    CGFloat nextW = [self getTitleWidthFont:[UIFont fontWithName:@"PingFangSC-Light" size:15] content:title];
    
    __weak SJPickerView *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        lastItem.frame = CGRectMake(lastItem.frame.origin.x, lastItem.frame.origin.y, nextW, lastItem.frame.size.height);
        self.signView.frame = CGRectMake(lastItem.frame.origin.x, ITEMS_SRCOLLVIEW_HIGHT - SIGN_VIEW_HIGHT, nextW, SIGN_VIEW_HIGHT);
    } completion:^(BOOL finished) {
        if (self.indexItem < self.itemCount - 1) {
            [self pointToNextItemIndex];
            [weakSelf newItem];
            
        } else {
            [self hideView];
        }
        
    }];
    
}

//indexItem指向下一个item
- (void)pointToNextItemIndex {
    self.indexItem++;
}

//获取指定字符串的长度
- (CGFloat)getTitleWidthFont:(UIFont *)font content:(NSString *)text{
    if (!text || ![text isKindOfClass:[NSString class]]) {
        return -1;
    }
    
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    
    NSDictionary *attribute = @{NSFontAttributeName : font};
    CGSize size=[text sizeWithAttributes:attribute];
    
    return size.width + 10;
}

//刷新tableview
- (void)reloadTableViewWithDatas:(NSArray *)datas {
    _tableViewSourceDatas = datas;
    [self.tableView reloadData];
    
    //防止添加nil到数组中导致崩溃
    if (!datas) {
        datas = [NSArray array];
    }
    
    //判断是否要添加,新拿到的数据需要添加，已经存在的不添加
    if (!(datas == [self.sourceDatas lastObject])) {
        [self.sourceDatas addObject:datas];
    }
}

//根据item，调整显示item的scrollview的横向偏移量。并刷新标记正在选择的item的view的frame
- (void)showItemInScrollViewWithItem:(UIButton *)item isRightOffset:(BOOL)isRightOffset{
    //判断scrollview的是否可以容纳生成的button
    CGFloat itemsAndSpacingsW = item.frame.origin.x + item.frame.size.width;
    if (itemsAndSpacingsW > self.itemsSrcollView.frame.size.width) {
        CGFloat offsetX = itemsAndSpacingsW - self.itemsSrcollView.frame.size.width;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.itemsSrcollView.contentOffset = CGPointMake(offsetX, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.signView.frame = CGRectMake(item.frame.origin.x, ITEMS_SRCOLLVIEW_HIGHT - SIGN_VIEW_HIGHT, item.frame.size.width, SIGN_VIEW_HIGHT);
            }];
        }];
        
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.signView.frame = CGRectMake(item.frame.origin.x, ITEMS_SRCOLLVIEW_HIGHT - SIGN_VIEW_HIGHT, item.frame.size.width, SIGN_VIEW_HIGHT);
        }];
    }
}

//显示单元格的勾view
- (void)showHookViewWithCell:(CustomTableViewCell *)cell{
    cell.hook.hidden = NO;
    cell.titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:15];
}

//获取cell的标题
- (NSString *)getTitleWithTableViewCell:(CustomTableViewCell *)cell {
    if (!cell || ![cell isKindOfClass:[CustomTableViewCell class]]) {
        return nil;
    }
    
    return cell.titleLabel.text;
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewSourceDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSString *cellTitle = self.tableViewSourceDatas[indexPath.row];
    [cell setCellTitle:cellTitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.hook.hidden = YES;
    cell.titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Regular" size:15];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self showHookViewWithCell:cell];
    NSString *cellTitle = self.tableViewSourceDatas[indexPath.row];
    if (cellTitle) {
        if (self.selectDatas.count == self.itemCount) {
            [self.selectDatas removeLastObject];
        }
        [self.selectDatas addObject:cellTitle];
    }
    
    SJIndexPath *tempIndexPath = [[SJIndexPath alloc] init];
    tempIndexPath.row = indexPath.row;
    tempIndexPath.section = self.indexItem;
    if (self.indexPaths.count == self.itemCount) {
        [self.indexPaths removeLastObject];
        
    }
    [self.indexPaths addObject:tempIndexPath];
    
    //调用选择cell的点击代理方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didSelectRowAtIndexPath:cellTitle:)]) {
        [self.delegate pickerView:self didSelectRowAtIndexPath:tempIndexPath cellTitle:cellTitle];
    }
    
    //判断是否是最后一次
    if (self.itemCount <= 1 || self.indexItem >= self.itemCount - 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didEndSelectRowAtIndexPaths:cellTitles:)]) {
            [self.delegate pickerView:self didEndSelectRowAtIndexPaths:self.indexPaths cellTitles:self.selectDatas];
        }
    
    }
    
    NSString *titleStr = [self getTitleWithTableViewCell:cell];
    [self setLastItemTitle:titleStr];
    
}


#pragma mark - setters and getters
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:0.7];
        [self addSubview:_backgroundView];
    }
    
    return _backgroundView;
}
- (UIView *)contentBackgroundView {
    if (!_contentBackgroundView) {
        _contentBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentBackgroundView.backgroundColor = [UIColor whiteColor];
        _contentBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentBackgroundView];
        
        //右边
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_contentBackgroundView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1
                                                                  constant:0];
        
        //左边
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_contentBackgroundView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1
                                                                 constant:0];
        
        //高度
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_contentBackgroundView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:self.frame.size.height * 4 / 7];
        self.contentBackgroundHeightConstraint = height;
        
        //顶部
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_contentBackgroundView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:0];
        self.contentBackgroundBottomConstraint = bottom;
        NSArray *constraints = @[right, left, height, bottom];
        [self addConstraints:constraints];
    }
    
    return _contentBackgroundView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:TABLEVIEWCELL_ID];
        [self.contentBackgroundView addSubview:_tableView];
        //右边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_tableView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1
                                                                                constant:0]];
        //左边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_tableView
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1
                                                                                constant:0]];
        //底部
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_tableView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1
                                                                                constant:0]];
        
        //顶部
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_tableView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:ITEMS_SRCOLLVIEW_HIGHT + TITLE_LABEL_HIGHT + 1 + + 10 + 13]];
    }
    
    return _tableView;
}

- (UIScrollView *)itemsSrcollView {
    if (!_itemsSrcollView) {
        _itemsSrcollView = [[UIScrollView alloc] init];
        _itemsSrcollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentBackgroundView addSubview:_itemsSrcollView];
        //右边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_itemsSrcollView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1
                                                                                constant:0]];
        //左边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_itemsSrcollView
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1
                                                                                constant:0]];
        //高度
        [_itemsSrcollView addConstraint:[NSLayoutConstraint constraintWithItem:_itemsSrcollView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:ITEMS_SRCOLLVIEW_HIGHT]];
        //顶部
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_itemsSrcollView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:TITLE_LABEL_HIGHT + 13 + 10]];
    }
    
    return _itemsSrcollView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentBackgroundView addSubview:_backBtn];
        //右边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_backBtn
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1
                                                                                constant:-25]];
        //宽度
        [_backBtn addConstraint:[NSLayoutConstraint constraintWithItem:_backBtn
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:17]];
        //高度
        [_backBtn addConstraint:[NSLayoutConstraint constraintWithItem:_backBtn
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:17]];
        //顶部
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_backBtn
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:24]];

    }
    
    return _backBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentBackgroundView addSubview:_titleLabel];
        //水平居中
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                               attribute:NSLayoutAttributeCenterX
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeCenterX
                                                                              multiplier:1
                                                                                constant:0]];
        //宽度
        [self.titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:150]];
        //高度
        [_titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:TITLE_LABEL_HIGHT]];
        //顶部
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:13]];
        
    }
    
    return _titleLabel;
}

- (UIView *)partingView {
    if (!_partingView) {
        _partingView = [[UIView alloc] init];
        _partingView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
        _partingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentBackgroundView addSubview:_partingView];
        
        //右边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_partingView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1
                                                                                constant:0]];
        //左边
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_partingView
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1
                                                                                constant:0]];
        //高度
        [_partingView addConstraint:[NSLayoutConstraint constraintWithItem:_partingView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:1]];
        //顶部
        [self.contentBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_partingView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentBackgroundView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:TITLE_LABEL_HIGHT + ITEMS_SRCOLLVIEW_HIGHT + 10 + 13]];
    }
    
    return _partingView;
}

- (UIView *)signView {
    if (!_signView) {
        _signView = [[UIView alloc] initWithFrame:CGRectMake(ITEM_SPACING, ITEMS_SRCOLLVIEW_HIGHT - SIGN_VIEW_HIGHT, SIGN_VIEW_WIDTH, SIGN_VIEW_HIGHT)];
        [self.itemsSrcollView addSubview:_signView];
    }
    
    return _signView;
}

@end
