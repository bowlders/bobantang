//
//  BBTSpecialRailwayViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/13.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTSouthSpecialRailwayTwoViewController.h"
#import "BBTSpecRailway2BusManager.h"
#import "BBTSpecRailway2TableViewCell.h"
#import <Masonry.h>

@interface BBTSouthSpecialRailwayTwoViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIButton    * invertButton;


@end

@implementation BBTSouthSpecialRailwayTwoViewController

extern NSString * busDataNotificationName;

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@ special line", NSStringFromCGRect(self.tableView.frame));
}

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
        tableView;
    });
    
    [self.view addSubview:self.tableView];

    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat containerViewHeight = self.view.frame.size.height - navigationBarHeight - tabBarHeight;
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
    return [[BBTSpecRailway2BusManager sharedBusManager].directionSouthStationNames count];
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
    
    //Here I create a new cell every time in order to fix a bug in view, often you need to reuse a cell.
    BBTSpecRailway2TableViewCell *cell = [[BBTSpecRailway2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    [cell initCellContent:[BBTSpecRailway2BusManager sharedBusManager].directionSouthStationNames[indexPath.row]];
    
    if ([[BBTSpecRailway2BusManager sharedBusManager] noBusInBusArray:[BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses RunningAtStationSeq:(indexPath.row + 1)])
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
    NSLog(@"Did receive special railway data notification");
    //NSLog(@"south buses - %@", [BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses);
    [self.tableView reloadData];
}

- (void)updateView
{
    for (int i = (int)[[BBTSpecRailway2BusManager sharedBusManager].directionSouthStationNames count];i >= 0;i--)
    {
        if ([[BBTSpecRailway2BusManager sharedBusManager] noBusInBusArray:[BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses RunningAtStationSeq:i])
        {
            //NSLog(@"init i - %d", i);
            [(BBTSpecRailway2TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i - 1) inSection:0]] initCellContent];
        }
        else
        {
            //NSLog(@"change i - %d", i);
            [(BBTSpecRailway2TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i - 1) inSection:0]] changeCellImage];
        }
    }
}

@end
