//
//  BBTRouteManagerView.m
//  BoBanTang
//
//  Created by Xu Donghui on 16/5/15.
//  Copyright © 2016年 100steps. All rights reserved.
//

/* This is another UI for route. Haven't be implemented yet. Will have a try in the near future. DO NOT REMOVE! */

#import "BBTRouteManagerView.h"
#import <Masonry/Masonry.h>

@implementation BBTRouteManagerView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0.0f green:153.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f];
        
        self.cancelButton = ({
            UIButton *button = [UIButton new];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFill;
            button.alpha = 1.0;
            button;
        });
        
        self.nameLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = NO;
            label.font = [UIFont boldSystemFontOfSize:19.0];
            label.textColor = [UIColor whiteColor];
            label.text = @"路线";
            label;
        });
        
        self.fromLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont systemFontOfSize:17.0];
            label.textColor = [UIColor whiteColor];
            label.text = @"从这走";
            label;
        });
        
        self.toLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont systemFontOfSize:17.0];
            label.textColor = [UIColor whiteColor];
            label.text = @"到这去";
            label;
        });
        
        self.startTextField = ({
            UITextField *textField = [UITextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            textField.textAlignment = NSTextAlignmentLeft;
            textField.textColor = [UIColor colorWithRed:17.0/255.0 green:215.0/255.0 blue:139.0/255.0 alpha:1.0];
            textField.font = [UIFont systemFontOfSize:17.0];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField;
        });
        
        self.endTextField = ({
            UITextField *textField = [UITextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            textField.textAlignment = NSTextAlignmentLeft;
            textField.textColor = [UIColor colorWithRed:149.0/255.0 green:19.0/255.0 blue:201.0/255.0 alpha:1.0];
            textField.font = [UIFont systemFontOfSize:17.0];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField;
        });
        
        self.exchangeButton = ({
            UIButton *button = [UIButton new];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setImage:[UIImage imageNamed:@"交换"] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFill;
            button.alpha = 1.0;
            button;
        });
        
        self.tableView = ({
            UITableView *tableView = [UITableView new];
            tableView.translatesAutoresizingMaskIntoConstraints = NO;
            tableView;
        });
        
        self.whiteLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.adjustsFontSizeToFitWidth = NO;
            label.backgroundColor = [UIColor whiteColor];
            label;
        });
        
        [self addSubview:self.cancelButton];
        [self addSubview:self.nameLabel];
        [self addSubview:self.fromLabel];
        [self addSubview:self.toLabel];
        [self addSubview:self.startTextField];
        [self addSubview:self.endTextField];
        [self addSubview:self.exchangeButton];
        [self addSubview:self.whiteLabel];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)updateConstraints
{
    CGFloat size = 20.0f;
    CGFloat labelHeight = 30.0f;
    CGFloat nameLabelHeight = 40.0f;
    CGFloat labelWidth = 51.0f;
    CGFloat innerSpacing = 10.0f;
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(innerSpacing);
        make.top.equalTo(self.mas_top).offset(innerSpacing);
        make.height.equalTo(@(size));
        make.width.equalTo(@(size));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelButton.mas_right);
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(nameLabelHeight));
    }];
    
    [self.fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(innerSpacing);
        make.top.equalTo(self.cancelButton.mas_bottom).offset(innerSpacing);
        make.width.equalTo(@(labelWidth));
        make.height.equalTo(@(labelHeight));
    }];
    
    [self.toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(innerSpacing);
        make.top.equalTo(self.fromLabel.mas_bottom).offset(innerSpacing/2);
        make.width.equalTo(@(labelWidth));
        make.height.equalTo(@(labelHeight));
    }];
    
    [self.exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-innerSpacing);
        make.top.equalTo(self.nameLabel.mas_bottom).offset( 1.5 * innerSpacing);
        make.height.equalTo(@(3*innerSpacing));
        make.width.equalTo(@(26.9));
    }];
    
    [self.startTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fromLabel.mas_right).offset(innerSpacing);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.right.equalTo(self.exchangeButton.mas_left).offset( - innerSpacing);
        make.height.equalTo(@(labelHeight));
    }];
    
    [self.endTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.toLabel.mas_right).offset(innerSpacing);
        make.top.equalTo(self.startTextField.mas_bottom).offset(innerSpacing/2);
        make.right.equalTo(self.exchangeButton.mas_left).offset( - innerSpacing);
        make.height.equalTo(@(labelHeight));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.endTextField.mas_bottom).offset(innerSpacing/2);
        make.right.equalTo(self.mas_right).offset( - innerSpacing);
        make.left.equalTo(self.mas_left).offset(innerSpacing);
    }];
    
    [self.whiteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toLabel.mas_bottom).offset(innerSpacing/2);
        make.left.equalTo(self.superview.mas_left);
        make.right.equalTo(self.superview.mas_right);
        make.bottom.equalTo(self.superview.mas_bottom);
    }];
        
    [super updateConstraints];
}

@end
