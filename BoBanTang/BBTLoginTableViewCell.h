//
//  BBTLoginTableViewCell.h
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTLoginTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel     * label;
@property (strong, nonatomic) UITextField * textField;

- (void)setCellContentWithLabelText:(NSString *)labelText andTextFieldPlaceHolder:(NSString *)placeHolder;

@end
