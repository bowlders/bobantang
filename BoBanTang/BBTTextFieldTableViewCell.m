//
//  BBTTextFieldTableViewCell.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTTextFieldTableViewCell.h"

@implementation BBTTextFieldTableViewCell

- (void)awakeFromNib
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = view;
    self.contents.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellForDifferntUse:(NSInteger)type
{
    switch (type) {
        case 0:
            self.title.text = @"地点";
            self.contents.placeholder = @"填写详细丢失/拾获地点";
            break;
            
        case 1:
            self.title.text = @"联系人";
            self.contents.placeholder = @"填写联系人名称";
            break;
            
        case 2:
            self.title.text = @"联系电话";
            self.contents.placeholder = @"填写联系人电话";
            break;
            
        case 3:
            self.title.text = @"其他";
            self.contents.placeholder = @"请备注类别，如短号/QQ/微信";
            break;
            
        default:
            break;
    }
}

- (void)dismissKeyboard
{
    [self.contents resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
