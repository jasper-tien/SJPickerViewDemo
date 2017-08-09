//
//  SJPickerView.h
//  选择器
//
//  Created by tianmaotao on 2017/7/7.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPickerViewConst.h"

@interface SJIndexPath : NSObject
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger section;

@end

@class SJPickerView;
@protocol SJPickerViewDataSource <NSObject>
@optional
/** 读取将要显示的数据(调用didSelectRowReloadPickerView方法后调用此方法获取数据) */
@optional
- (NSArray *)sourceDatasOfRows;
@end

@protocol SJPickerViewDelegate <NSObject>
@optional
/** 选择中某个单元格后调用 */
- (void)pickerView:(SJPickerView *)view didSelectRowAtIndexPath:(SJIndexPath *)indexPath cellTitle:(NSString *)title;
/**  返回最后的结果 */
- (void)pickerView:(SJPickerView *)view didEndSelectRowAtIndexPaths:(NSArray<SJIndexPath *> *)indexPaths cellTitles:(NSArray *)titles;

@end

@interface SJPickerView : UIView
@property (readonly, nonatomic, copy) NSMutableArray *sourceDatas;                      //存放对应item的tableview的数据
@property (readonly, nonatomic, copy) NSArray *tableViewSourceDatas;                    //源数据
@property (readonly, nonatomic, copy) NSMutableArray *selectDatas;                      //选择的数据
@property (readonly, nonatomic, weak) UIView *superView;                                //父视图
@property (readonly, nonatomic, copy) NSMutableArray *items;                            //存储item按钮对象
@property (readonly, nonatomic, copy) NSMutableArray<SJIndexPath *> *indexPaths;        //每一组源数据选择下标和对应item下标的集合


@property (nonatomic, assign) NSInteger itemCount;                                      //最大类目数
@property (nonatomic, copy) NSString *title;                                            //标题
@property (nonatomic, weak) id<SJPickerViewDataSource> dataSource;                      //数据源代理
@property (nonatomic, weak) id<SJPickerViewDelegate> delegate;                          //其他操作代理

/** 初始化
    datas：为初始化的数据
 */
- (instancetype)initWithSourceDatas:(NSArray *)datas;
/**
    刷新数据
    点击选择器的单元格后，从外面获取数据的时候调用此方法，刷新选择器的数据。
    （原则上是点击单元格后调用此方法，其他情况也可以，如：初始化的时候，调用刷新初始化的数据！）
 */
- (void)didSelectRowReloadPickerView;
/**
    显示选择器
    view：为选择器的父视图。
 */
- (void)showInView:(UIView *)view;
/**
    隐藏选择器
 */
- (void)hideView;

@end
