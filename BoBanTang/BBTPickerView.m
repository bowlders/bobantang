//
//  BBTPickerView.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 23/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTPickerView.h"

@implementation BBTPickerView

+ (instancetype)pickerViewInView:(UIView *)view withBuildings:(NSArray *)buildingsToChoose hidden:(BOOL)hidden
{
    BBTPickerView *pickerView = [[BBTPickerView alloc] init];
    [pickerView viewWithTag:100];
    
    pickerView.buildings = [[NSArray alloc] initWithArray:buildingsToChoose];
    
    [view addSubview:pickerView];
    view.userInteractionEnabled = NO;
    
    [pickerView setPickerHidden:NO withPickerView:pickerView];
    return pickerView;
}

+ (instancetype)removerPickerView:(UIView *)view withPickerView:(BBTPickerView *)pickerView hidden:(BOOL)hidden
{
    view.userInteractionEnabled = YES;
    
    [pickerView setPickerHidden:YES withPickerView:pickerView];
    
    return pickerView;
}

- (void)setPickerHidden: (BOOL)hidden withPickerView:(BBTPickerView *)pickerview
{
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         if (hidden) {
                             [pickerview setAlpha:0.0];
                             [pickerview setTransform:CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(pickerview.frame))];
                         } else {
                             [pickerview setAlpha:1.0];
                             [pickerview setTransform:CGAffineTransformIdentity];
                         }
                     } completion:nil];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.buildings count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.buildings[component][row];
}

+ (NSString *)selectedBuildingsInPickerView:(BBTPickerView *)pickerview
{
    NSInteger row = [pickerview.picker selectedRowInComponent:0];
    NSString *building = pickerview.buildings[row];
    return building;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
