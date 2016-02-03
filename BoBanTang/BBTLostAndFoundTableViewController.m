//
//  BBTLostAndFoundTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/29.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLostAndFoundTableViewController.h"
#import "PopoverView.h"
#import "BBTPostInfoTableViewController.h"
#import "BBTLAFManager.h"
#import "BBTLafItemsTableViewCell.h"
#import "BBTItemDetailsTableViewController.h"

static NSString *postIdentifier = @"LAFPostIdentifier";
static NSString *itemCellIdentifier = @"BBTLafItemsTableViewCell";
static NSString *showItemsDetailsIdentifier = @"showItemsDetailsIdentifier";

@interface BBTLostAndFoundTableViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *lostOrFound;

@end

@implementation BBTLostAndFoundTableViewController

extern NSString * lafNotificationName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLafNotification) name:lafNotificationName object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    [[BBTLAFManager sharedLAFManager] retriveItemsWithType:self.lostOrFound.selectedSegmentIndex];
    
    UINib *cellNib = [UINib nibWithNibName:itemCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:itemCellIdentifier];
    
    self.tableView.rowHeight = 100;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveLafNotification
{
    NSLog(@"Items notification received");
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)didChangeLafType:(id)sender
{
    [[BBTLAFManager sharedLAFManager] retriveItemsWithType:self.lostOrFound.selectedSegmentIndex];
    
    [self.tableView reloadData];
}

- (IBAction)addLAFButtonTapped:(id)sender
{
    UIButton *showBtn = sender;
    
    PopoverView *popoverView = [PopoverView new];
    popoverView.menuTitles   = @[@"发布招领启事", @"发布寻物启事", @"已发布的消息"];
    [popoverView showFromView:showBtn selected:^(NSInteger index){
        [self performSegueWithIdentifier:postIdentifier sender:popoverView.menuTitles[index]];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BBTLAFManager sharedLAFManager].itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBTLafItemsTableViewCell *cell = (BBTLafItemsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:itemCellIdentifier forIndexPath:indexPath];
    
    NSArray *itemArray = [BBTLAFManager sharedLAFManager].itemArray;
    [cell configureItemsCells:itemArray[indexPath.row]];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *itemArray = [BBTLAFManager sharedLAFManager].itemArray;
    NSDictionary *itemDetails = itemArray[indexPath.row];
    
    [self performSegueWithIdentifier:showItemsDetailsIdentifier sender:itemDetails];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:postIdentifier])
    {
        BBTPostInfoTableViewController *controller = segue.destinationViewController;
        controller.postType = sender;
    }
    else if ([segue.identifier isEqualToString:showItemsDetailsIdentifier])
    {
        BBTItemDetailsTableViewController *controller = segue.destinationViewController;
        controller.itemDetails = sender;
        if (self.lostOrFound.selectedSegmentIndex == 0) {
            controller.lostOrFound = false;
        } else if (self.lostOrFound.selectedSegmentIndex == 1){
            controller.lostOrFound = true;
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
