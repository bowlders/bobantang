//
//  BBTDirectionHeaderView.h
//  bobantang
//
//  Created by Xu Donghui on 16/5/15.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTDirectionHeaderView : UIView
@property (strong, nonatomic) UITextField *startTextField;
@property (strong, nonatomic) UITextField *endTextField;
@property (strong, nonatomic) UIButton *routeButton;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *fromLabel;
@property (strong, nonatomic) UILabel *toLabel;
@property (strong, nonatomic) UILabel *upperMarginLabel;
@property (strong, nonatomic) UILabel *leftMarginLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *hideDownArrowButton;
@end

