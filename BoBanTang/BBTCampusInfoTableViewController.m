//
//  BBTCampusInfoTableViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCampusInfoTableViewController.h"
#import "BBTCampusInfoManager.h"
#import "BBTCampusInfoTableViewCell.h"
#import "BBTCampusInfoViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <Masonry.h>

@interface BBTCampusInfoTableViewController ()

@end

@implementation BBTCampusInfoTableViewController

extern NSString * campusInfoNotificationName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCampusInfoNotification) name:campusInfoNotificationName object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *cellIdentifier = @"infoCell";
    [self.tableView registerClass:[BBTCampusInfoTableViewCell class] forCellReuseIdentifier:cellIdentifier];

    self.tableView.backgroundColor = [UIColor whiteColor];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    [header setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    
    //Retrive all campus infos
    [[BBTCampusInfoManager sharedInfoManager] retriveData:@""];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[BBTCampusInfoManager sharedInfoManager].infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = applicationFrame.size.height;
    return screenHeight / 4.3;
     */
    
    NSArray *infoArray = [BBTCampusInfoManager sharedInfoManager].infoArray;
    return [tableView fd_heightForCellWithIdentifier:@"infoCell" configuration:^(BBTCampusInfoTableViewCell *cell){
        [cell setCellContentDictionary:infoArray[indexPath.row]];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"infoCell";
    BBTCampusInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTCampusInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *infoArray = [BBTCampusInfoManager sharedInfoManager].infoArray;
    
    [cell setCellContentDictionary:infoArray[indexPath.row]];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didReceiveCampusInfoNotification
{
    NSLog(@"Did receive campus info notification");
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (void)refresh
{
    [[BBTCampusInfoManager sharedInfoManager] retriveData:@""];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTCampusInfoViewController *destinationVC = [[BBTCampusInfoViewController alloc] init];
    destinationVC.info = [BBTCampusInfoManager sharedInfoManager].infoArray[indexPath.row];
    
    [self.navigationController pushViewController:destinationVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    [(BBTCampusInfoViewController *)[segue destinationViewController] setInfo:[BBTCampusInfoManager sharedInfoManager].infoArray[indexPath.row]];
}


@end
