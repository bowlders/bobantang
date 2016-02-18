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
#import <Masonry.h>

@interface BBTNorthSpecialRailwayTwoViewController ()

@property (strong, nonatomic) UITableView * tableView;

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
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.scrollEnabled = YES;
        tableView.allowsSelection = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    
    [self.view addSubview:self.tableView];
    
    CGFloat tableViewUpPadding = 20.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat containerViewHeight = self.view.frame.size.height - navigationBarHeight - tabBarHeight;
    CGRect containerViewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), containerViewHeight * 0.95);
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(statusBarHeight + navigationBarHeight);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
        make.right.equalTo(self.view.mas_right);
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
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = applicationFrame.size.height - navigationBarHeight - tabBarHeight;
    return screenHeight * 0.9 / 12.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"specialRailwayCell";
    
    BBTSpecRailway2TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTSpecRailway2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell initCellContent:[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames[[[BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames count] - indexPath.row - 1]];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didReceiveBusNotification : (NSNotification *)busNotification
{
    NSLog(@"Did receive special railway data notification");
    [self updateView];
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