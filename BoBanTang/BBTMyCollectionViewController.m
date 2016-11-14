//
//  CollectionsTableViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/18.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTMyCollectionViewController.h"
#import "BBTCollectedCampusInfoManager.h"
#import "BBTCollectedDailyArticleManager.h"
#import "BBTCampusInfoTableViewCell.h"
#import "BBTDailyArticleTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "BBTCampusInfoViewController.h"
#import "BBTDailyArticleViewController.h"
#import <MJRefresh.h>
#import <MBProgressHUD.h>

@interface BBTMyCollectionViewController ()

@property (assign, nonatomic) int succeedNotifCount;        //Record how many successful notification have been received.
@property (assign, nonatomic) int failNotifCount;           //Record how many failed notification have been received.

@end

@implementation BBTMyCollectionViewController

extern NSString * fetchCollectedInfoSucceedNotifName;
extern NSString * fetchCollectedInfoFailNotifName;
extern NSString * fetchCollectedArticleSucceedNotifName;
extern NSString * fetchCollectedArticleFailNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [self addObserver];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    
    [header setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的收藏";
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    NSString *cellIdentifier1 = @"collectedInfoCell";
    [self.tableView registerClass:[BBTCampusInfoTableViewCell class] forCellReuseIdentifier:cellIdentifier1];
    NSString *cellIdentifier2 = @"collectedArticleCell";
    [self.tableView registerClass:[BBTDailyArticleTableViewCell class] forCellReuseIdentifier:cellIdentifier2];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFetchCollectedInfoSucceedNotification)
                                                 name:fetchCollectedInfoSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFetchCollectedInfoFailNotification)
                                                 name:fetchCollectedInfoFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFetchCollectedArticleSucceedNotification)
                                                 name:fetchCollectedArticleSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFetchCollectedArticleFailNotification)
                                                 name:fetchCollectedInfoFailNotifName
                                               object:nil];
}

- (void)didReceiveFetchCollectedInfoSucceedNotification
{
    _succeedNotifCount++;
    [self checkSucceedNotifCount];
}

- (void)didReceiveFetchCollectedInfoFailNotification
{
    _failNotifCount++;
    [self checkFailNotifCount];
}

- (void)didReceiveFetchCollectedArticleSucceedNotification
{
    _succeedNotifCount++;
    [self checkSucceedNotifCount];
}

- (void)didReceiveFetchCollectedArticleFailNotification
{
    _failNotifCount++;
    [self checkFailNotifCount];
}

- (void)checkSucceedNotifCount
{
    //Have received campusInfoSucceedNotif & dailyArticleSucceedNotif.
    if (_succeedNotifCount == 2)
    {
        //User hasn't collected any info.
        if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserCollectedDailyArticleArray count]))
        {
            [self.tableView reloadData];

            if (self.navigationController.view)
            {
                //Show HUD
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                //Set the annular determinate mode to show task progress.
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"你还什么都没有收藏哦";
                
                //Move to center.
                hud.xOffset = 0.0f;
                hud.yOffset = 0.0f;
                
                //Hide after 2 seconds.
                [hud hide:YES afterDelay:2.0f];
            }

            //Dismiss current VC 0.5 sec after HUD disappears.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                //Go back to the BBTMeViewController.
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
        _succeedNotifCount = 0;
    }
}

- (void)checkFailNotifCount
{
    if (_failNotifCount)
    {
        if (self.navigationController.view)
        {
            //Show HUD
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            //Set the annular determinate mode to show task progress.
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"加载失败";
            
            //Move to center.
            hud.xOffset = 0.0f;
            hud.yOffset = 0.0f;
            
            //Hide after 2 seconds.
            [hud hide:YES afterDelay:2.0f];
        }

        //Dismiss current VC 0.5 sec after HUD disappears.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            //Go back to the BBTMeViewController.
            [self.navigationController popViewControllerAnimated:YES];
        });
        _failNotifCount = 0;
    }
}

- (void)refresh
{
    [[BBTCollectedCampusInfoManager sharedCollectedInfoManager] fetchCurrentUserCollectedCampusInfoIntoArray];
    [[BBTCollectedDailyArticleManager sharedCollectedArticleManager] fetchCurrentUserCollectedDailyArticleIntoArray];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //User has collected both campus infos and daily articles.
    if (([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && ([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        return 2;
    }
    //User hasn't collected anything.
    else if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //User has collected both campus infos and daily articles.
    if (([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && ([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //collectedCampusInfo section.
        if (!section)
        {
            return @"校园资讯";
        }
        //collectedDailyArticle section.
        else
        {
            return @"每日一文";
        }
    }
    //User hasn't collected anything.
    else if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        return 0;
    }
    //User only collects campus infos.
    else if([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count])
    {
        return @"校园资讯";
    }
    else
    {
        return @"每日一文";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //User has collected both campus infos and daily articles.
    if (([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && ([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //collectedCampusInfo section.
        if (!section)
        {
            return [[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count];
        }
        //collectedDailyArticle section.
        else
        {
            return [[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count];
        }
    }
    //User hasn't collected anything.
    else if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        return 0;
    }
    //User only collects campus infos.
    else if([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count])
    {
        return [[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count];
    }
    else
    {
        return [[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //User has collected both campus infos and daily articles.
    if (([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && ([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //collectedCampusInfo section.
        if (!indexPath.section)
        {
            NSArray *collectedInfoArray = [BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray;
            return [tableView fd_heightForCellWithIdentifier:@"collectedInfoCell" configuration:^(BBTCampusInfoTableViewCell *cell){
                [cell setCellContentDictionary:collectedInfoArray[indexPath.row]];
            }];
        }
        //collectedDailyArticle section.
        else
        {
            NSArray *collectedArticleArray = [BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray;
            return [tableView fd_heightForCellWithIdentifier:@"collectedArticleCell" configuration:^(BBTDailyArticleTableViewCell *cell){
                [cell setCellContentDictionary:collectedArticleArray[indexPath.row]];
            }];
        }
    }
    //User hasn't collected anything.
    else if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        return 0;
    }
    //User only collects campus infos.
    else if([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count])
    {
        NSArray *collectedInfoArray = [BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray;
        return [tableView fd_heightForCellWithIdentifier:@"collectedInfoCell" configuration:^(BBTCampusInfoTableViewCell *cell){
            [cell setCellContentDictionary:collectedInfoArray[indexPath.row]];
        }];
    }
    else
    {
        NSArray *collectedArticleArray = [BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray;
        return [tableView fd_heightForCellWithIdentifier:@"collectedArticleCell" configuration:^(BBTDailyArticleTableViewCell *cell){
            [cell setCellContentDictionary:collectedArticleArray[indexPath.row]];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    //User has collected both campus infos and daily articles.
    if (([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && ([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //collectedCampusInfo section.
        if (!indexPath.section)
        {
            NSString *cellIdentifier = @"collctedInfoCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell)
            {
                cell = [[BBTCampusInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            NSArray *collectedInfoArray = [BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray;
            [(BBTCampusInfoTableViewCell *)cell setCellContentDictionary:collectedInfoArray[indexPath.row]];
        }
        //collectedDailyArticle section.
        else
        {
            NSString *cellIdentifier = @"collectedArticleCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell)
            {
                cell = [[BBTDailyArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
        
            NSArray *articleArray = [BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray;
            [(BBTDailyArticleTableViewCell *)cell setCellContentDictionary:articleArray[indexPath.row]];
        }
    }
    //User hasn't collected anything.
    else if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //Return an empty cell.
        cell = [[UITableViewCell alloc] init];
        return cell;
    }
    //User only collects campus infos.
    else if([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count])
    {
        NSString *cellIdentifier = @"collctedInfoCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell)
        {
            cell = [[BBTCampusInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSArray *collectedInfoArray = [BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray;
        [(BBTCampusInfoTableViewCell *)cell setCellContentDictionary:collectedInfoArray[indexPath.row]];
    }
    else
    {
        NSString *cellIdentifier = @"collectedArticleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell)
        {
            cell = [[BBTDailyArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSArray *articleArray = [BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray;
        [(BBTDailyArticleTableViewCell *)cell setCellContentDictionary:articleArray[indexPath.row]];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //User has collected both campus infos and daily articles.
    if (([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && ([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //collectedCampusInfo section.
        if (!indexPath.section)
        {
            BBTCampusInfoViewController *destinationVC = [[BBTCampusInfoViewController alloc] init];
            destinationVC.info = [BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray[indexPath.row];
            destinationVC.isActivityPage = NO;
            
            [self.navigationController pushViewController:destinationVC animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        //collectedDailyArticle section.
        else
        {
            BBTDailyArticleViewController *destinationVC = [[BBTDailyArticleViewController alloc] init];
            destinationVC.article = [BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray[indexPath.row];
            destinationVC.isEnteredFromArticleTableVC = 1;
            
            [self.navigationController pushViewController:destinationVC animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    //User hasn't collected anything.
    else if(!([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count]) && !([[BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray count]))
    {
        //Nothing.
    }
    //User only collects campus infos.
    else if([[BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray count])
    {
        BBTCampusInfoViewController *destinationVC = [[BBTCampusInfoViewController alloc] init];
        destinationVC.info = [BBTCollectedCampusInfoManager sharedCollectedInfoManager].currentUserIntactCollectedCampusInfoArray[indexPath.row];
        destinationVC.isActivityPage = NO;
        
        [self.navigationController pushViewController:destinationVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        BBTDailyArticleViewController *destinationVC = [[BBTDailyArticleViewController alloc] init];
        destinationVC.article = [BBTCollectedDailyArticleManager sharedCollectedArticleManager].currentUserIntactCollectedDailyArticleArray[indexPath.row];
        
        [self.navigationController pushViewController:destinationVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
