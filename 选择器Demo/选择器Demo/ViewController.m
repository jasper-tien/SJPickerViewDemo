//
//  ViewController.m
//  选择器test
//
//  Created by tianmaotao on 2017/8/2.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import "ViewController.h"
#import "SJPickerView.h"

@interface ViewController ()<SJPickerViewDataSource, SJPickerViewDelegate>
@property (nonatomic, strong) SJPickerView *pickerView;
@property (nonatomic, copy) NSArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.datas =  [self getRandomArray];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sourceDatasOfRows {
    self.datas = [self getRandomArray];
    
    return self.datas;
}

- (NSArray *)getRandomArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        int x = arc4random() % 100;
        NSString *str = [NSString stringWithFormat:@"test %d", x];
        [array addObject:str];
    }
    
    return array;
}

- (void)pickerView:(SJPickerView *)view didSelectRowAtIndexPath:(SJIndexPath *)indexPath cellTitle:(NSString *)title {
     [self.pickerView didSelectRowReloadPickerView];
}

- (IBAction)show:(id)sender {
    if (!self.pickerView) {
        self.pickerView = [[SJPickerView alloc] initWithSourceDatas:self.datas];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        self.pickerView.itemCount = 10;
        self.pickerView.title = @"test pickerView";
    }
    [self.pickerView showInView:self.view];
}

- (IBAction)update:(id)sender {
    if (!self.pickerView) {
        return;
    }
    
    [self.pickerView didSelectRowReloadPickerView];
}

@end
