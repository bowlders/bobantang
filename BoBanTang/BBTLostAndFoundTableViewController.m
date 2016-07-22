//
//  BBTLostAndFoundTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/29.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLostAndFoundTableViewController.h"
#import "PopoverView.h"
#import "BBTPostInfoViewController.h"
#import "BBTLAF.h"
#import "BBTLAFManager.h"
#import "BBTLafItemsTableViewCell.h"
#import "BBTItemDetailsTableViewController.h"
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"
#import "BBTLafSearchResultTableViewController.h"
#import "BBTItemCampusTableViewCell.h"
#import "BBTItemFilterSettingsViewController.h"
#import <MJRefresh.h>
#import <MJRefreshStateHeader.h>
#import "UIImageView+AFNetworking.h"
#import "UIColor+BBTColor.h"
#import "WYPopoverController.h"

static NSString *postIdentifier = @"LAFPostIdentifier";
static NSString *itemCellIdentifier = @"BBTLafItemsTableViewCell";
static NSString *showItemsDetailsIdentifier = @"showItemsDetailsIdentifier";
static NSString *campusCellIdentifier = @"BBTItemCampusTableViewCell";

@interface BBTLostAndFoundTableViewController () <WYPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl           * lostOrFound;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem              * filterButton;

@property (strong, nonatomic) NSArray                               * filteredItems;
@property (strong, nonatomic) NSArray                               * itemArray;
@property (strong, nonatomic) NSDictionary                          * conditions;

@property (strong, nonatomic) UISearchController                    * searchController;
@property (strong, nonatomic) BBTLafSearchResultTableViewController * resultsTableController;
@property (strong, nonatomic) WYPopoverController                   * settingsPopoverController;
@property (strong, nonatomic) BBTItemFilterSettingsViewController   * settingsViewController;

@end

@implementation BBTLostAndFoundTableViewController

extern NSString * lafNotificationName;
extern NSString * kUserAuthentificationFinishNotifName;
extern NSString * kGetFuzzyConditionsItemNotificationName;

- (void)viewWillAppear:(BOOL)animated
{
    self.itemArray = [NSArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLafNotification:) name:lafNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUserAuthentificaionNotification) name:kUserAuthentificationFinishNotifName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFuzzyItemsNotificaion) name:kGetFuzzyConditionsItemNotificationName object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    [header setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];

    self.filteredItems = [[NSArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:itemCellIdentifier bundle:nil] forCellReuseIdentifier:itemCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:campusCellIdentifier bundle:nil] forCellReuseIdentifier:campusCellIdentifier];
    
    _resultsTableController = [[BBTLafSearchResultTableViewController alloc] init];
    _searchController =  [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.resultsTableController.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveLafNotification:(NSNotification *)notification
{
    NSLog(@"Items notification received");
    self.itemArray = (NSArray *)notification.object;
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (BOOL)didReceiveUserAuthentificaionNotification
{
    NSLog(@"User Authentification received");
    return YES;
}

- (void)didReceiveFuzzyItemsNotificaion
{
    BBTLafSearchResultTableViewController *controller = (BBTLafSearchResultTableViewController *)self.searchController.searchResultsController;
    controller.filteredItems = [[NSArray alloc] initWithArray:[BBTLAFManager sharedLAFManager].itemArray];
    [controller.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)didChangeLafType:(id)sender
{
    [self refresh];
    
    [self.tableView reloadData];
}

- (IBAction)addLAFButtonTapped:(id)sender
{
    UIButton *showBtn = sender;
    
    PopoverView *popoverView = [PopoverView new];
    popoverView.menuTitles   = @[@"发布招领启事", @"发布寻物启事", @"已发布的消息", @"全部失物"];
    [popoverView showFromView:showBtn selected:^(NSInteger index)
    {
        if ([self didReceiveUserAuthentificaionNotification])
        {
            if (index == 2)
            {
                [self.filterButton setAccessibilityElementsHidden:YES];
                self.conditions = @{@"account": @201430202488};
                [self.tableView.mj_header beginRefreshing];
                [self refresh];
            } else if (index ==3 ){
                self.conditions = [[NSDictionary alloc] init];
                [self.tableView.mj_header beginRefreshing];
                [self refresh];
            } else {
                if ([self shouldPerformSegueWithIdentifier:postIdentifier sender:@(index)])
                {
                    [self performSegueWithIdentifier:postIdentifier sender:@(index)];
                }
            }
        } else {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController = [UIAlertController alertControllerWithTitle:@"验证用户失败" message:@"请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __unsafe_unretained BBTLafItemsTableViewCell *cell = (BBTLafItemsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:itemCellIdentifier forIndexPath:indexPath];
    
    //Prevent the cell point to a reused cell with wrong contents because the download request is in the background
    cell.thumbLostImageView.image = nil;
    [cell.thumbLostImageView cancelImageDownloadTask];
    
    //Configure cell
    //NSArray *itemArray = [BBTLAFManager sharedLAFManager].itemArray;
    [cell configureItemsCells:self.itemArray[indexPath.row]];
    
    //Asynchronously downloads the thumbnail
    [cell.thumbLostImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:((BBTLAF *)self.itemArray[indexPath.row]).thumbURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * image) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSArray *itemArray = [BBTLAFManager sharedLAFManager].itemArray;
    BBTLAF *itemDetails = self.itemArray[indexPath.row];
    
    [self performSegueWithIdentifier:showItemsDetailsIdentifier sender:itemDetails];
}

//Search
- (IBAction)setFilterConditions:(id)sender
{
    self.settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BBTItemFilterSettingsViewController"];
    self.settingsViewController.delegate = self;
    self.settingsViewController.preferredContentSize = CGSizeMake(self.view.frame.size.width, 280);
    WYPopoverBackgroundView *popoverAppearance = [WYPopoverBackgroundView appearance];
    [popoverAppearance setOuterCornerRadius:0];
    [popoverAppearance setInnerCornerRadius:0];
    self.settingsViewController.title = @"请选择筛选条件";
    self.settingsViewController.modalInPopover = NO;
    UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
    self.settingsPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
    self.settingsPopoverController.delegate = self;
    self.settingsPopoverController.passthroughViews = @[self.filterButton];
    self.settingsPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    self.settingsPopoverController.wantsDefaultContentAppearance = NO;
    
    [self.settingsPopoverController presentPopoverFromBarButtonItem:self.filterButton
                                           permittedArrowDirections:WYPopoverArrowDirectionDown
                                                           animated:YES
                                                            options:WYPopoverAnimationOptionFade];
}

- (void)BBTItemFilters:(BBTItemFilterSettingsViewController *)controller didFinishSelectConditions:(NSMutableDictionary *)conditions
{
    self.conditions = [[NSDictionary alloc] initWithDictionary:conditions];
    [self refresh];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSArray *fuzzyArray = @[searchBar.text];
    NSDictionary *fuzzyCondition = @{@"fuzzy":fuzzyArray};
    [[BBTLAFManager sharedLAFManager] retriveItems:self.lostOrFound.selectedSegmentIndex WithConditions:fuzzyCondition];
}

- (void)refresh
{
    [[BBTLAFManager sharedLAFManager] retriveItems:self.lostOrFound.selectedSegmentIndex WithConditions:self.conditions];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:postIdentifier])
    {
        if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
        {
            NSLog(@"Account: %@", [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account);
            return YES;
        } else {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController = [UIAlertController alertControllerWithTitle:@"你还没有登录哟" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去登陆"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 BBTLoginViewController *loginViewController = [[BBTLoginViewController alloc] init];
                                                                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                                                                 [self presentViewController:navigationController animated:YES completion:nil];
                                                                 if ([(NSNumber *)sender longValue] == 0 || [(NSNumber *)sender longValue] == 1) {
                                                                     [self performSegueWithIdentifier:postIdentifier sender:sender];
                                                                 }
                                                             }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            return NO;
        }
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:postIdentifier])
    {
        BBTPostInfoViewController *controller = segue.destinationViewController;
        controller.lostOrFound = (NSNumber *)sender;
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
