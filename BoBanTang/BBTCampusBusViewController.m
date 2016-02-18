//
//  BBTCampusBusViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/31.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCampusBusViewController.h"
#import "BBTCampusBusTableViewCell.h"
#import "BBTCampusBusManager.h"
#import <Masonry.h>

@interface BBTCampusBusViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIButton    * refreshButton;

@end

@implementation BBTCampusBusViewController

extern NSString * campusBusNotificationName;

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCampusBusNotification)
                                                 name:campusBusNotificationName
                                               object:nil];
    
    //Initialization
    [BBTCampusBusManager sharedCampusBusManager];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.scrollEnabled = NO;
        tableView.allowsSelection = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    
    self.refreshButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"BoBanTang"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(clickRefreshButton)
         forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.numberOfLines = 1;
        button.titleLabel.textAlignment = NSTextAlignmentRight;
        button.titleLabel.adjustsFontSizeToFitWidth = NO;
        button.alpha = 1.0;
        button;
    });
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.refreshButton];
    CGFloat tableViewUpPadding = 20.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat buttonOffset = 10.0f;
    CGFloat buttonSideLength = 50.0f;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view.mas_right).offset(-buttonOffset);
        make.bottom.equalTo(self.view.mas_bottom).offset(- tabBarHeight - buttonOffset);
        make.width.equalTo(@(buttonSideLength));
        make.height.equalTo(@(buttonSideLength));
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BBTCampusBusManager sharedCampusBusManager].stationNameArray count];
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
    static NSString *cellIdentifier = @"campusBusCell";
    
    BBTCampusBusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTCampusBusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell initCellContent:[BBTCampusBusManager sharedCampusBusManager].stationNameArray[indexPath.row]];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didReceiveCampusBusNotification
{
    NSLog(@"Did receive campus bus notification");
    [self updateView];
}

- (void)updateView
{
    if ([[BBTCampusBusManager sharedCampusBusManager] noBusRunningAtStartingStation])
    {
        [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]] initCellContent];
    }
    else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 0)
    {
        [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]] changeCellImageAtSide:1];
    }
    else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 1)
    {
        [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]] changeCellImageAtSide:0];
    }
    else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 2)
    {
        [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]] changeCellImageAtSide:1];
        [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]] changeCellImageAtSide:0];
    }
    
    //Start from station 2(中山像站)
    for (int i = ((int)[[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - 2);i >= 0;i--)
    {
        if ([[BBTCampusBusManager sharedCampusBusManager] noBusRunningAtStationAtIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - i)])
        {
            [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] initCellContent];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - i)] == 0)
        {
            [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] changeCellImageAtSide:1];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - i)] == 1)
        {
            [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] changeCellImageAtSide:0];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - i)] == 2)
        {
            [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] changeCellImageAtSide:1];
            [(BBTCampusBusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] changeCellImageAtSide:0];
        }
    }
}

- (void)clickRefreshButton
{
    [[BBTCampusBusManager sharedCampusBusManager] refresh];
}

@end
