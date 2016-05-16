//
//  BBTRouteManagerView.h
//  BoBanTang
//
//  Created by Xu Donghui on 16/5/15.
//  Copyright © 2016年 100steps. All rights reserved.
//

/* This is another UI for route. Haven't be implemented yet. Will have a try in the near future. DO NOT REMOVE! */

#import <UIKit/UIKit.h>

@interface BBTRouteManagerView : UIView

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *startTextField;
@property (nonatomic, strong) UITextField *endTextField;
@property (nonatomic, strong) UIButton *exchangeButton;
@property (nonatomic, strong) UITableView *tableView;

@end
