//
//  SJPickerViewConst.h
//  PickerViewDemo
//
//  Created by tianmaotao on 2017/8/9.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import <UIKit/UIKit.h>
/************************************************************************************/
//细体
#define SJPickerViewFontLight(fontSize) [UIFont fontWithName:@"PingFangSC-Light" size:(fontSize)]
//正常体
#define SJPickerViewFontRegular(fontSize) [UIFont fontWithName:@"PingFang-SC-Regular" size:(fontSize)]
//粗体
#define SJPickerViewFontMedium(fontSize) [UIFont fontWithName:@"PingFang-SC-Medium" size:(fontSize)]

/************************************************************************************/
//遮挡view背景颜色
#define SJPickerViewCoverBackgroundColor [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0]
//字体颜色
#define SJPickerViewTextNormalColor [UIColor blackColor]
#define SJPickerViewTextBlurColor [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1.0];

/************************************************************************************/
//界面布局frame相关
#define SIGN_VIEW_HIGHT 3               //标记view条的高度
#define SIGN_VIEW_WIDTH 60              //标记view条的宽度
#define ITEMS_SRCOLLVIEW_HIGHT 53       //放item的srcollview的高度
#define TITLE_LABEL_HIGHT 40            //标题label的高度
#define ITEM_SPACING 25                 //item间的间隔

/************************************************************************************/
//单元格复用标志
UIKIT_EXTERN NSString *const SJPickerViewCellID;
/************************************************************************************/
