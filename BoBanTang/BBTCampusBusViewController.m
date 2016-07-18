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
#import "UIFont+BBTFont.h"
#import "UIColor+BBTColor.h"
#import <Masonry.h>

@interface BBTCampusBusViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIButton    * refreshButton;
@property (strong, nonatomic) UIView      * labelContainerView;
@property (strong, nonatomic) UILabel     * directionSouthLabel;
@property (strong, nonatomic) UILabel     * directionNorthLabel;
@property (strong, nonatomic) UIImageView * waterMarkImageView;

@property (nonatomic) CGFloat cellHeight;

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
        tableView.backgroundColor = [UIColor clearColor];
        tableView;
    });
    
    self.refreshButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(clickRefreshButton)
         forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 1.0;
        button;
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
        label.text = @"至南门方向";
        label.font = [UIFont BBTGoLabelFont];
        label;
    });
    
    self.directionNorthLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentRight;
        label.adjustsFontSizeToFitWidth = NO;
        label.alpha = 1.0;
        label.text = @"至北区方向";
        label.font = [UIFont BBTGoLabelFont];
        label;
    });
    
    self.waterMarkImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.alpha = 1.0;
            imageView.image = [UIImage imageNamed:@"waterMark"];
            imageView;
    });
    
    [self.view addSubview:self.waterMarkImageView];
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.labelContainerView];
    [self.labelContainerView addSubview:self.directionSouthLabel];
    [self.labelContainerView addSubview:self.directionNorthLabel];

    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat buttonOffset = 10.0f;
    CGFloat buttonSideLength = 50.0f;
    CGFloat labelHeight = 23.0f;
    CGFloat labelWidth = 60.0f;
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = applicationFrame.size.height - navigationBarHeight - tabBarHeight;
    CGFloat horizontalInnerSpacing = 5.0f;
    CGFloat leftImageOffset = 50.0f;
    CGFloat stationLabelWidth = 120.0f;
    
    self.cellHeight = screenHeight * 0.9 / 12.0;

    CGFloat rightImageRightSide = leftImageOffset + 2 * 0.8 * self.cellHeight + 2 * horizontalInnerSpacing + stationLabelWidth;
    
    [self.waterMarkImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(statusBarHeight + navigationBarHeight + labelHeight);
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
    
    [self.directionNorthLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.directionSouthLabel.mas_top);
        make.height.equalTo(self.directionSouthLabel.mas_height);
        make.right.equalTo(self.view.mas_left).offset(rightImageRightSide);
        make.width.equalTo(@(labelWidth));
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
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Here I create a new cell every time in order to fix a bug in view, often you need to reuse a cell.
    //Use nil as identifier to avoid memory leak.
    BBTCampusBusTableViewCell *cell = [[BBTCampusBusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [cell initCellContent:[BBTCampusBusManager sharedCampusBusManager].stationNameArray[indexPath.row]];
    
    if (indexPath.row == 11)                                //Starting station
    {
        if ([[BBTCampusBusManager sharedCampusBusManager] noBusRunningAtStartingStation])
        {
            [cell initCellContent];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 0)
        {
            [cell changeCellImageAtSide:1];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 1)
        {
            [cell changeCellImageAtSide:0];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 2)
        {
            [cell changeCellImageAtSide:1];
            [cell changeCellImageAtSide:0];
        }
    }
    else
    {
        if ([[BBTCampusBusManager sharedCampusBusManager] noBusRunningAtStationAtIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - indexPath.row)])
        {
            [cell initCellContent];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - indexPath.row)] == 0)
        {
            [cell changeCellImageAtSide:1];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:([[BBTCampusBusManager sharedCampusBusManager].stationNameArray count] - indexPath.row)] == 1)
        {
            [cell changeCellImageAtSide:0];
        }
        else if ([[BBTCampusBusManager sharedCampusBusManager] directionOfTheBusAtStationIndex:1] == 2)
        {
            [cell changeCellImageAtSide:1];
            [cell changeCellImageAtSide:0];
        }

    }

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didReceiveCampusBusNotification
{
    //NSLog(@"Did receive campus bus notification");
    [self.tableView reloadData];
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
