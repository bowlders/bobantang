//
//  BBTMyPostedTableViewController.m
//  BoBanTang
//
//  Created by Xu Donghui on 25/07/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import "BBTMyPostedTableViewController.h"
#import <MJRefresh.h>
#import <MJRefreshStateHeader.h>
#import <Masonry.h>
#import <MBProgressHUD.h>
#import <JGProgressHUD.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+AFNetworking.h"
#import "BBTLafItemsTableViewCell.h"
#import "BBTLAFManager.h"
#import "BBTItemDetailsTableViewController.h"

static NSString *itemCellIdentifier = @"BBTLafItemsTableViewCell";
static NSString *showItemsDetailsIdentifier = @"showItemsDetailsIdentifier2";

@interface BBTMyPostedTableViewController ()

@property (assign, nonatomic) int lostOrFound;
@property (strong, nonatomic) NSMutableArray *myPicked;
@property (strong, nonatomic) NSMutableArray *myLost;
@property (assign, nonatomic) BOOL didGetPicked;

@end

@implementation BBTMyPostedTableViewController

extern NSString * lafNotificationName;
extern NSString * failNotificationName;
extern NSString * kDidDeleteItemNotificationName;
extern NSString * kFailDeleteItemNotificaionName;
extern NSString * kDidGetPickedItemsNotificationName;
extern NSString * kDidGetLostItemsNotificationName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPickedNotification) name:kDidGetPickedItemsNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetLostNotification) name:kDidGetLostItemsNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteItem) name:kDidDeleteItemNotificationName object:nil];
    self.didGetPicked = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.didGetPicked = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationItem.title = @"我的发布";
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    [header setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    
    [self.tableView registerNib:[UINib nibWithNibName:itemCellIdentifier bundle:nil] forCellReuseIdentifier:itemCellIdentifier];
    
    self.myPicked = [NSMutableArray array];
    self.myLost   = [NSMutableArray array];
    
    self.didGetPicked = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didGetPickedNotification
{
    self.didGetPicked = YES;
    [[BBTLAFManager sharedLAFManager] loadMyLostItemsWithAccount:self.account];
    self.myPicked = [BBTLAFManager sharedLAFManager].myPicked;
}

-(void)didGetLostNotification
{
    if (self.didGetPicked) {
        self.myLost = [BBTLAFManager sharedLAFManager].myLost;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.didGetPicked = NO;
    } else {
        [self refresh];
        self.didGetPicked = NO;
    }
}

- (void)didDeleteItem
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.interactionType = 0;
    HUD.textLabel.text = @"删除成功";
    HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    HUD.square = YES;
    [HUD showInView:self.navigationController.view];
    [HUD dismissAfterDelay:2.0 animated:YES];
    [self.view setUserInteractionEnabled:YES];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)refresh
{
    [[BBTLAFManager sharedLAFManager] loadMyPickedItemsWithAccount:self.account];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([BBTLAFManager sharedLAFManager].myPicked && [[BBTLAFManager sharedLAFManager].myPicked count] > 0)
    {
        NSArray *itemArray = [BBTLAFManager sharedLAFManager].myPicked;
        return [tableView fd_heightForCellWithIdentifier:itemCellIdentifier configuration:^(BBTLafItemsTableViewCell *cell)
                {
                    if ([itemArray count] > 0)
                    {
                        [cell configureItemsCells:itemArray[indexPath.row]];
                    }
                }];
    } else {
        NSArray *itemArray = [BBTLAFManager sharedLAFManager].myLost;
        return [tableView fd_heightForCellWithIdentifier:itemCellIdentifier configuration:^(BBTLafItemsTableViewCell *cell)
                {
                    if ([itemArray count] > 0)
                    {
                        [cell configureItemsCells:itemArray[indexPath.row]];
                    }
                }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"找失主";
            break;
            
        case 1:
            return @"找失物";
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[BBTLAFManager sharedLAFManager].myPicked count];
    } else {
        return [[BBTLAFManager sharedLAFManager].myLost   count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __unsafe_unretained BBTLafItemsTableViewCell *cell = (BBTLafItemsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:itemCellIdentifier forIndexPath:indexPath];
    
    //Prevent the cell point to a reused cell with wrong contents because the download request is in the background
    cell.thumbLostImageView.image = nil;
    [cell.thumbLostImageView cancelImageDownloadTask];

    if (indexPath.section == 0 && [BBTLAFManager sharedLAFManager].myPicked && [[BBTLAFManager sharedLAFManager].myPicked count] > 0)
    {
        [cell configureItemsCells:[BBTLAFManager sharedLAFManager].myPicked[indexPath.row]];
        
        [cell.thumbLostImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:((BBTLAF *)[BBTLAFManager sharedLAFManager].myPicked[indexPath.row]).thumbURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * image) {
            //NSLog(@"Succeed!");
            if (cell) {
                cell.thumbLostImageView.image = image;
            }
            [cell setNeedsLayout];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            cell.thumbLostImageView.image = [UIImage imageNamed:@"BoBanTang"];
        }];
        
    }
    else if (indexPath.section == 1 && [BBTLAFManager sharedLAFManager].myLost && [[BBTLAFManager sharedLAFManager].myLost count] > 0) {
        [cell configureItemsCells:[BBTLAFManager sharedLAFManager].myLost[indexPath.row]];
        
        [cell.thumbLostImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:((BBTLAF *)[BBTLAFManager sharedLAFManager].myLost[indexPath.row]).thumbURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * image) {
            //NSLog(@"Succeed!");
            if (cell) {
                cell.thumbLostImageView.image = image;
            }
            [cell setNeedsLayout];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            cell.thumbLostImageView.image = [UIImage imageNamed:@"BoBanTang"];
        }];
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BBTLAF *itemDetails = [BBTLAFManager sharedLAFManager].myPicked[indexPath.row];
        self.lostOrFound = 0;
        [self performSegueWithIdentifier:showItemsDetailsIdentifier sender:itemDetails];
    } else {
        BBTLAF *itemDetails = [BBTLAFManager sharedLAFManager].myLost[indexPath.row];
        self.lostOrFound = 1;
        [self performSegueWithIdentifier:showItemsDetailsIdentifier sender:itemDetails];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Show an alert view to avoid "hands diability"
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"确定删除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                             //Show a HUD
                                                             [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                                             [self.view setUserInteractionEnabled:NO];
                                                             
                                                             if (indexPath.section == 0)
                                                             {
                                                                 
                                                                 [[BBTLAFManager sharedLAFManager] deletePostedItemsWithId:((BBTLAF *)[BBTLAFManager sharedLAFManager].myPicked[indexPath.row]).ID inTable:0];
                                                             } else {
                                                                 
                                                                 [[BBTLAFManager sharedLAFManager] deletePostedItemsWithId:((BBTLAF *)[BBTLAFManager sharedLAFManager].myLost[indexPath.row]).ID inTable:1];
                                                             }
                                                         }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:showItemsDetailsIdentifier])
    {
        BBTItemDetailsTableViewController *controller = segue.destinationViewController;
        controller.itemDetails = sender;
        if (self.lostOrFound == 0) {
            controller.lostOrFound = false;
        } else if (self.lostOrFound == 1){
            controller.lostOrFound = true;
        }
    }

}


@end
