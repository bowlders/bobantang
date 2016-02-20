//
//  BBTNorthSpecialRailwayTwoViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/14.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTNorthSpecialRailwayTwoViewController.h"
#import "BBTSpecRailway2BusManager.h"
#import "BBTSpecRailway2TableViewCell.h"
#import "UIFont+BBTFont.h"
#import "UIColor+BBTColor.h"
#import <Masonry.h>

@interface BBTNorthSpecialRailwayTwoViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIImageView * waterMarkImageView;
@property (strong, nonatomic) UIView      * labelContainerView;
@property (strong, nonatomic) UILabel     * directionSouthLabel;

@property (nonatomic) CGFloat cellHeight;

@end

@implementation BBTNorthSpecialRailwayTwoViewController

extern NSString * busDataNotificationName;

- (void)viewDidLoad
{
    //Add self to bus data notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveBusNotification:)
                                                 name:busDataNotificationName
                                               object:nil];
    
    //Init specRailwayManager
    [BBTSpecRailway2BusManager sharedBusManager];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:label];

    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.scrollEnabled = YES;
        tableView.allowsSelection = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView;
    });
    
    self.waterMarkImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.alpha = 1.0;
        imageView.image = [UIImage imageNamed:@"waterMark"];
        imageView;
    });
    
    self.labelContainerView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor BBTLightGray];
        view.alpha = 1.0;
        view;
    });
    
    self.directionSouthLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentLeft;
        label.adjustsFontSizeToFitWidth = NO;
        label.alpha = 1.0;
        label.text = @"至五山方向";
        label.font = [UIFont BBTGoLabelFont];
        label;
    });
    
    [self.view addSubview:self.waterMarkImageView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.labelContainerView];
    [self.labelContainerView addSubview:self.directionSouthLabel];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = applicationFrame.size.height - navigationBarHeight - tabBarHeight;
    CGFloat leftImageOffset = 50.0f;
    CGFloat labelHeight = 23.0f;
    CGFloat labelWidth = 80.0f;
    
    self.cellHeight = screenHeight * 0.9 / 12.0;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(statusBarHeight + navigationBarHeight + labelHeight);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [self.waterMarkImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
    }];

    [self.labelContainerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(statusBarHeight + navigationBarHeight);
        make.height.equalTo(@(labelHeight));
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [self.directionSouthLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(statusBarHeight + navigationBarHeight);
        make.height.equalTo(@(labelHeight));
        make.left.equalTo(self.view.mas_left).offset(leftImageOffset);
        make.width.equalTo(@(labelWidth));
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"specialRailwayCell";
    
    //Here I create a new cell every time in order to fix a bug in view, often you need to reuse a cell.
    BBTSpecRailway2TableViewCell *cell = [[BBTSpecRailway2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell initCellContent:[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames[([[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count] - indexPath.row - 1)]];
    
    if ([[BBTSpecRailway2BusManager sharedBusManager] noBusInBusArray:[BBTSpecRailway2BusManager sharedBusManager].directionNorthBuses RunningAtStationSeq:([[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count] - indexPath.row)])
    {
        [cell initCellContent];
    }
    else
    {
        [cell changeCellImage];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didReceiveBusNotification : (NSNotification *)busNotification
{
    //NSLog(@"Did receive special railway data notification");
    [self.tableView reloadData];
}

- (void)updateView
{
    for (int i = (int)[[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count];i >= 0;i--)
    {
        if ([[BBTSpecRailway2BusManager sharedBusManager] noBusInBusArray:[BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses RunningAtStationSeq:i])
        {
            [(BBTSpecRailway2TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count] - i) inSection:0]] initCellContent];
        }
        else
        {
            [(BBTSpecRailway2TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count] - i) inSection:0]] changeCellImage];
        }
    }
}

@end