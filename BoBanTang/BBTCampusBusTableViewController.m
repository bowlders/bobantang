
//
//  BBTCampusBusTableViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/28.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCampusBusTableViewController.h"
#import "BBTCampusBusTableViewCell.h"
#import "BBTCampusBusManager.h"

@implementation BBTCampusBusTableViewController

extern NSString * campusBusNotificationName;

- (void)viewDidAppear:(BOOL)animated
{
    //Add refresh button
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    CGRect applicationFrame = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = CGRectGetWidth(applicationFrame);
    CGFloat screenHeight = CGRectGetHeight(applicationFrame);
    CGFloat buttonWidth = 40.0f;
    CGFloat buttonHeight = 40.0f;
    CGFloat spacing = 10.0f;
    CGFloat buttonX = screenWidth - buttonWidth - spacing;
    CGFloat buttonY = screenHeight - buttonHeight - spacing;
    CGRect buttonFrame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    refreshButton.frame = buttonFrame;
    NSLog(@"%@", NSStringFromCGRect(refreshButton.frame));
    NSLog(@"screen - %@", NSStringFromCGRect(applicationFrame));
    [refreshButton addTarget:self
                      action:@selector(clickRefreshButton)
            forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:refreshButton];
}

- (void)viewDidLoad
{
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCampusBusNotification)
                                                 name:campusBusNotificationName
                                               object:nil];
    

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
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = applicationFrame.size.height;
    return screenHeight * 0.77 / 12.0;
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
