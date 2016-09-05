//
//  BBTLoginTableViewCell.m
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLoginTableViewCell.h"
#import <Masonry.h>

@interface BBTLoginTableViewCell ()

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation BBTLoginTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        self.label = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = NO;
            label;
        });
        
        self.textField = ({
            UITextField *textField = [UITextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            textField.textAlignment = NSTextAlignmentLeft;
            textField.adjustsFontSizeToFitWidth = NO;
            textField;
        });
        
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.textField];

    }
    
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        
        CGFloat labelLeftPadding = 10.0f;
        CGFloat labelTextFieldInnerSpacing = 10.0f;
        CGFloat labelWidth = 40.0f;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(labelLeftPadding);
            make.width.equalTo(@(labelWidth));
            make.height.equalTo(self.contentView.mas_height);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.label.mas_right).offset(labelTextFieldInnerSpacing);
            make.right.equalTo(self.contentView.mas_right);
            make.height.equalTo(self.contentView.mas_height);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setCellContentWithLabelText:(NSString *)labelText andTextFieldPlaceHolder:(NSString *)placeHolder
{
    self.label.text = labelText;
    self.textField.placeholder = placeHolder;
}

- (void)presetTextFieldContentWithString:(NSString *)string
{
    self.textField.text = string;
}

@end
