//
//  BBTLafSearchResultTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/19.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLafSearchResultTableViewController.h"
#import "BBTLafItemsTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+AFNetworking.h"

static NSString *itemCellIdentifier = @"BBTLafItemsTableViewCell";

@interface BBTLafSearchResultTableViewController ()

@end

@implementation BBTLafSearchResultTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:itemCellIdentifier bundle:nil] forCellReuseIdentifier:itemCellIdentifier];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:itemCellIdentifier configuration:^(BBTLafItemsTableViewCell *cell)
            {
                if (self.filteredItems && [self.filteredItems count] > 0)
                {
                    [cell configureItemsCells:self.filteredItems[indexPath.row]];
                }
            }];
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
    __unsafe_unretained BBTLafItemsTableViewCell *cell = (BBTLafItemsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:itemCellIdentifier forIndexPath:indexPath];
    
    //Prevent the cell point to a reused cell with wrong contents because the download request is in the background
    cell.thumbLostImageView.image = nil;
    [cell.thumbLostImageView cancelImageDownloadTask];
    
    [cell configureItemsCells:self.filteredItems[indexPath.row]];
    
    [cell.thumbLostImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:((BBTLAF *)self.filteredItems[indexPath.row]).thumbURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * image) {
        //NSLog(@"Succeed!");
        if (cell) {
            cell.thumbLostImageView.image = image;
        }
        [cell setNeedsLayout];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        cell.thumbLostImageView.image = [UIImage imageNamed:@"BoBanTang"];
    }];
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    return cell;
}


@end
