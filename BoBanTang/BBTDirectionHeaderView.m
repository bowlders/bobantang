//
//  BBTDirectionHeaderView.m
//  bobantang
//
//  Created by Xu Donghui on 16/5/15.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDirectionHeaderView.h"
#import <Masonry/Masonry.h>

@interface BBTDirectionHeaderView()

@end

@implementation BBTDirectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.routeButton = ({
            UIButton *button = [UIButton new];
            [button setImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFill;
            button.alpha = 1.0;
            button;
        });
        
        self.hideDownArrowButton = ({
            UIButton *button = [UIButton new];
            [button setImage:[UIImage imageNamed:@"hideDownArrow"] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFill;
            button.alpha = 1.0;
            button;
        });
        
        self.fromLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = NO;
            label.text = @"从";
            label.font = [UIFont systemFontOfSize:18.0];
            label;
        });
        
        self.toLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = NO;
            label.text = @"到";
            label.font = [UIFont systemFontOfSize:18.0];
            label;
        });
        
        self.upperMarginLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.adjustsFontSizeToFitWidth = NO;
            label.backgroundColor = [UIColor BBTAppGlobalBlue];
            label;
        });
        
        self.leftMarginLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.adjustsFontSizeToFitWidth = NO;
            label.backgroundColor = [UIColor BBTAppGlobalBlue];
            label;
        });

        self.startTextField = ({
            UITextField *textField = [UITextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            textField.textAlignment = NSTextAlignmentLeft;
            textField.textColor = [UIColor colorWithRed:17.0/255.0 green:215.0/255.0 blue:139.0/255.0 alpha:1.0];
            textField.font = [UIFont systemFontOfSize:14.0];
            textField.background = [UIImage imageNamed:@"underDash"];
            textField.borderStyle = UITextBorderStyleNone;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField;
        });
        
        self.endTextField = ({
            UITextField *textField = [UITextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            textField.textAlignment = NSTextAlignmentLeft;
            textField.textColor = [UIColor colorWithRed:149.0/255.0 green:19.0/255.0 blue:201.0/255.0 alpha:1.0];
            textField.font = [UIFont systemFontOfSize:14.0];
            textField.background = [UIImage imageNamed:@"underDash"];
            textField.borderStyle = UITextBorderStyleNone;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField;
        });
        
        self.tableView = ({
            UITableView *tableView = [UITableView new];
            tableView.translatesAutoresizingMaskIntoConstraints = NO;
            tableView;
        });
        
        self.distanceLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = NO;
            label.font = [UIFont fontWithName:@"Helvetica Neue Light" size:13.0];
            label.textColor = [UIColor BBTAppGlobalBlue];
            label;
        });
        
        [self addSubview:self.routeButton];
        [self addSubview:self.fromLabel];
        [self addSubview:self.toLabel];
        [self addSubview:self.startTextField];
        [self addSubview:self.endTextField];
        [self addSubview:self.tableView];
        [self addSubview:self.distanceLabel];
        [self addSubview:self.hideDownArrowButton];
        [self addSubview:self.upperMarginLabel];
        [self addSubview:self.leftMarginLabel];
    }
    
    return self;
}

- (void)updateConstraints
{
    self.routeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.fromLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.startTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.toLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.endTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    //CGFloat width = (self.superview.frame.size.width);
    CGFloat buttonSize = 30.0f;
    CGFloat innerSpacing = 10.0f;
    CGFloat size = 20.0f;
    CGFloat textFieldWidth = (self.superview.frame.size.width - 2*innerSpacing - buttonSize - 5 - 2*size)/2;
    
    [self.routeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview.mas_left).offset(innerSpacing);
        make.top.equalTo(self.superview.mas_top).offset(15.0);
        make.height.equalTo(@(buttonSize));
        make.width.equalTo(@(buttonSize));
    }];
    
    [self.hideDownArrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview.mas_left).offset(2 * innerSpacing);
        make.bottom.equalTo(self.superview.mas_bottom).offset(-5.0);
        make.width.equalTo(@(25));
        make.height.equalTo(@(25));
    }];
    
    [self.fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.routeButton.mas_right).offset(5.0f);
        make.top.equalTo(self.superview.mas_top).offset(2 * innerSpacing);
        make.height.equalTo(@(size));
        make.width.equalTo(@(size));
    }];
    
    [self.startTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fromLabel.mas_right);
        make.top.equalTo(self.superview.mas_top).offset(2 * innerSpacing);
        make.height.equalTo(@(size));
        make.width.equalTo(@(textFieldWidth));
    }];
    
    [self.toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startTextField.mas_right);
        make.top.equalTo(self.superview.mas_top).offset(2 * innerSpacing);
        make.height.equalTo(@(size));
        make.width.equalTo(@(size));
    }];
    
    [self.endTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.toLabel.mas_right);
        make.top.equalTo(self.superview.mas_top).offset(2 * innerSpacing);
        make.height.equalTo(@(size));
        make.width.equalTo(@(textFieldWidth));
    }];
    
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startTextField.mas_bottom);
        make.left.equalTo(self.routeButton.mas_right);
        make.right.equalTo(self.superview.mas_right).offset(- 2 * innerSpacing);
        make.height.equalTo(@(30));
    }];
    
    [self.upperMarginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.distanceLabel.mas_bottom);
        make.left.equalTo(self.superview.mas_left);
        make.right.equalTo(self.superview.mas_right);
        make.height.equalTo(@(2));
    }];
    
    [self.leftMarginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview.mas_left).offset(2 * innerSpacing + 25 + 25);
        make.top.equalTo(self.upperMarginLabel.mas_bottom);
        make.bottom.equalTo(self.superview.mas_bottom);
        make.width.equalTo(self.upperMarginLabel.mas_height);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top .equalTo(self.distanceLabel.mas_bottom).offset(innerSpacing);
        make.right.equalTo(self.superview.mas_right).offset( - innerSpacing);
        make.left.equalTo(self.leftMarginLabel.mas_right).offset(innerSpacing);
    }];

    [super updateConstraints];
}

@end
