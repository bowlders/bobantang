//
//  BBTDailyArticleTableViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTDailyArticleTableViewController.h"
#import "BBTDailyArticleManager.h"
#import "BBTDailyArticleTableViewCell.h"
#import "BBTDailyArticleViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <MJRefresh.h>
#import <MJRefreshStateHeader.h>
#import <Masonry.h>

@interface BBTDailyArticleTableViewController ()

@end

@implementation BBTDailyArticleTableViewController

extern NSString * dailyArticleNotificationName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDailyArticleNotification) name:dailyArticleNotificationName object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *cellIdentifier = @"articleCell";
    [self.tableView registerClass:[BBTDailyArticleTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    [header setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    
    [self.tableView.mj_header beginRefreshing];
    
    [[BBTDailyArticleManager sharedArticleManager] retriveData:@""];
}

- (void)didReceiveDailyArticleNotification
{
    NSLog(@"Did receive daily article notification");
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *articleArray = [BBTDailyArticleManager sharedArticleManager].articleArray;
    
    return [tableView fd_heightForCellWithIdentifier:@"articleCell" configuration:^(BBTDailyArticleTableViewCell *cell){
        [cell setCellContentDictionary:articleArray[indexPath.row]];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[BBTDailyArticleManager sharedArticleManager].articleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"articleCell";
    BBTDailyArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTDailyArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *articleArray = [BBTDailyArticleManager sharedArticleManager].articleArray;
    
    [cell setCellContentDictionary:articleArray[indexPath.row]];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTDailyArticleViewController *destinationVC = [[BBTDailyArticleViewController alloc] init];
    //destinationVC.info = [BBTCampusInfoManager sharedInfoManager].infoArray[indexPath.row];
    
    [self.navigationController pushViewController:destinationVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refresh
{
    [[BBTDailyArticleManager sharedArticleManager] retriveData:@""];
}

@end
