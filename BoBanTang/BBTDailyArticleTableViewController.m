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
extern NSString * noMoreArticleNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDailyArticleNotification)
                                                 name:dailyArticleNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNoMoreArticleNotification)
                                                 name:noMoreArticleNotifName
                                               object:nil];
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
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)didReceiveDailyArticleNotification
{
    NSLog(@"Did receive daily article notification");
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
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
        [cell setCellContentDictionary:articleArray[indexPath.section]];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [BBTDailyArticleManager sharedArticleManager].articleCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"articleCell";
    BBTDailyArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTDailyArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *articleArray = [BBTDailyArticleManager sharedArticleManager].articleArray;
    [cell setCellContentDictionary:articleArray[indexPath.section]];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTDailyArticleViewController *destinationVC = [[BBTDailyArticleViewController alloc] init];
    destinationVC.article = [BBTDailyArticleManager sharedArticleManager].articleArray[indexPath.section];
    destinationVC.isEnteredFromArticleTableVC = 1;
    [self.navigationController pushViewController:destinationVC animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refresh
{
    [BBTDailyArticleManager sharedArticleManager].articleCount = 0;         //Load from the first 5 articles
    [[BBTDailyArticleManager sharedArticleManager] loadMoreData];
}

- (void)loadMoreData
{
    [[BBTDailyArticleManager sharedArticleManager] loadMoreData];
}

- (void)didReceiveNoMoreArticleNotification
{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

@end
