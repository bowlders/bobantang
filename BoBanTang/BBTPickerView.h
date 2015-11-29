//
//  BBTPickerView.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 23/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSArray *buildings;

+ (NSString *)selectedBuildingsInPickerView:(BBTPickerView *)pickerview;

+ (instancetype)pickerViewInView:(UIView *)view withBuildings:(NSArray *)buildingsToChoose hidden:(BOOL)hidden;
+ (instancetype)removerPickerView:(UIView *)view withPickerView:(BBTPickerView *)pickerView hidden:(BOOL)hidden;

@end
