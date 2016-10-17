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
#import <MBProgressHUD.h>

@interface BBTNorthSpecialRailwayTwoViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIImageView * waterMarkImageView;
@property (strong, nonatomic) UIView      * labelContainerView;
@property (strong, nonatomic) UILabel     * directionSouthLabel;

@property (nonatomic) CGFloat cellHeight;

@end

@implementation BBTNorthSpecialRailwayTwoViewController

- (void)viewWillAppear:(BOOL)animated
{
    //Show loading hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Add self to bus data notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveBusNotification)
                                                 name:busDataNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDirectionNorthFailNotification)
                                                 name:retriveDirectionNorthFailNotifName
                                               object:nil];
}

- (void)viewDidLoad
{
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
    //Here I create a new cell every time in order to fix a bug in view, often you need to reuse a cell.
    BBTSpecRailway2TableViewCell *cell = [[BBTSpecRailway2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
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

- (void)didReceiveBusNotification
{
    //NSLog(@"Did receive special railway data notification");
    
    //Hide loading hud
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.tableView reloadData];
}

- (void)didReceiveDirectionNorthFailNotification
{
    //Hide loading hud
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //Show HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"加载失败";
    
    //Move to center.
    hud.xOffset = 0.0f;
    hud.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [hud hide:YES afterDelay:2.0f];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end