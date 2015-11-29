//
//  BBTSpecialRailwayLineTwoViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/11/17.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTSpecialRailwayLineTwoViewController.h"
#import "BBTSpecRailway2Bus.h"
#import "BBTSpecRailway2BusManager.h"

@interface BBTSpecialRailwayLineTwoViewController ()

@end

@implementation BBTSpecialRailwayLineTwoViewController

NSString * busDataNotificationName = @"specBusNotification";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    
    CGFloat screenWidth = applicationFrame.size.width;
    CGFloat screenHeight = applicationFrame.size.height;
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;

    CGRect tableViewRect = CGRectMake(0.0f, naviBarHeight + statusBarHeight, screenWidth, screenHeight - naviBarHeight - statusBarHeight - tabBarHeight);
    
    self.tableView.frame = tableViewRect;

    //Add self to bus data notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveBusNotification:)
                                                 name:busDataNotificationName
                                               object:nil];
    
    //Init specRailwayManager
    [BBTSpecRailway2BusManager sharedBusManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveBusNotification : (NSNotification *)busNotification
{
    NSLog(@"Did receive special railway data notification");
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rowNumber;
    
    if (section == 0)
    {
        rowNumber = [[BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses count] + 1;
    }
    else if (section == 1)
    {
        rowNumber = [[BBTSpecRailway2BusManager sharedBusManager].directionNorthBuses count] + 1;
    }
    
    return rowNumber;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle;
    
    switch (section)
    {
        case 0:
            sectionTitle = @"一路向南";
            break;
        case 1:
            sectionTitle = @"一路向北";
            break;
        default:
            NSAssert(NO, @"Invalid section index");
    }
    
    return sectionTitle;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *specCellIdentifier = @"specCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:specCellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:specCellIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"向南行驶的车有%lu辆:", (unsigned long)[[BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses count]];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%ld:现在位于%@", (long)indexPath.row, ((NSString *)([BBTSpecRailway2BusManager sharedBusManager].directionSouthStationNames[((BBTSpecRailway2Bus *)([BBTSpecRailway2BusManager sharedBusManager].directionSouthBuses[indexPath.row - 1])).stationSeq]))];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"向北行驶的车有%lu辆:", (unsigned long)[[BBTSpecRailway2BusManager sharedBusManager].directionNorthBuses count]];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%ld:现在位于%@",(long)indexPath.row, ((NSString *)([BBTSpecRailway2BusManager sharedBusManager].directionNorthStationNames[((BBTSpecRailway2Bus *)([BBTSpecRailway2BusManager sharedBusManager].directionNorthBuses[indexPath.row - 1])).stationSeq]))];
        }
    }
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
