//
//  BBTLafSearchResultTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/19.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLafSearchResultTableViewController.h"
#import "BBTLafItemsTableViewCell.h"

static NSString *itemCellIdentifier = @"BBTLafItemsTableViewCell";

@interface BBTLafSearchResultTableViewController ()

@end

@implementation BBTLafSearchResultTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:itemCellIdentifier bundle:nil] forCellReuseIdentifier:itemCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTLafItemsTableViewCell *cell = (BBTLafItemsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:itemCellIdentifier forIndexPath:indexPath];
    
    [cell configureItemsCells:self.filteredItems[indexPath.row]];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}


@end
