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

@end

@implementation BBTSouthSpecialRailwayTwoViewController

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
        //tableView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0);
        tableView;
    });
    
    [self.view addSubview:self.tableView];

    CGFloat tableViewUpPadding = 20.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    //CGFloat buttonOffset = 10.0f;
    //CGFloat buttonSideLength = 50.0f;
    CGFloat containerViewHeight = self.view.frame.size.height - navigationBarHeight - tabBarHeight;
    CGRect containerViewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), containerViewHeight * 0.95);
    self.tableView.frame = containerViewRect;
    
    /*
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top);//.offset(navigationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom);//.offset(-tabBarHeight - 144);
        make.width.equalTo(self.view.mas_width);
        make.left.equalTo(self.view.mas_left);
    }];
    */
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
    
    BBTSpecRailway2TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTSpecRailway2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell initCellContent:[BBTSpecRailway2BusManager sharedBusManager].directionSouthStationNames[indexPath.row]];
    
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
    for (int i = (int)[[BBTSpecRailway2BusManager sharedBusManager].directionSouthStationNames count];i >= 0;i--)
    {
        if ([[BBTSpecRailway2BusManager sharedBusManager] noBusInBusArray:[BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses RunningAtStationSeq:i])
        {
            [(BBTSpecRailway2TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i - 1) inSection:0]] initCellContent];
        }
        else
        {
            [(BBTSpecRailway2TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i - 1) inSection:0]] changeCellImage];
        }
    }
}

@end
