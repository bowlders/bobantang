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
extern NSString * noNewInfoNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCampusInfoNotification)
                                                 name:campusInfoNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNoMoreInfoNotification)
                                                 name:noNewInfoNotifName
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *cellIdentifier = @"infoCell";
    [self.tableView registerClass:[BBTCampusInfoTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //Clear infoCount
    [BBTCampusInfoManager sharedInfoManager].infoCount = 0;

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    [header setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
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
    return [BBTCampusInfoManager sharedInfoManager].infoCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"infoCell" configuration:^(BBTCampusInfoTableViewCell *cell){
        if ([BBTCampusInfoManager sharedInfoManager].infoArray && [[BBTCampusInfoManager sharedInfoManager].infoArray count])
        {
            [cell setCellContentDictionary:[BBTCampusInfoManager sharedInfoManager].infoArray[indexPath.row]];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"infoCell";
    BBTCampusInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTCampusInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([BBTCampusInfoManager sharedInfoManager].infoArray && [[BBTCampusInfoManager sharedInfoManager].infoArray count])
    {
        [cell setCellContentDictionary:[BBTCampusInfoManager sharedInfoManager].infoArray[indexPath.row]];
    }

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (void)didReceiveCampusInfoNotification
{
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (void)didReceiveNoMoreInfoNotification
{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)refresh
{
    [BBTCampusInfoManager sharedInfoManager].infoCount = 0;         //Load from the first 5 infos
    [[BBTCampusInfoManager sharedInfoManager] loadMoreData];
}

- (void)loadMoreData
{
    [[BBTCampusInfoManager sharedInfoManager] loadMoreData];
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
