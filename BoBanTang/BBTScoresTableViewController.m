//
//  BBTScoresTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/16.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTScoresTableViewController.h"
#import "BBTScoresManager.h"
#import "BBTScoresCell.h"
#import "ActionSheetPicker.h"
#import <JGProgressHUD.h>
#import <MBProgressHUD.h>

static NSString *scoresCellIdentifier = @"BBTScoresCell";
static NSString *filterCellIdentifier = @"filterCell";

@interface BBTScoresTableViewController ()

@property (strong, nonatomic) NSNumber *errorType;
@property (strong, nonatomic) NSArray *scoresArray;

@end

@implementation BBTScoresTableViewController

extern NSString * kGetScoresNotificaionName;
extern NSString * kFailGetNotificaionName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetScoresNotification) name:kGetScoresNotificaionName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetScoresNotification) name:kFailGetNotificaionName object:self.errorType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:scoresCellIdentifier bundle:nil] forCellReuseIdentifier:scoresCellIdentifier];
    
    [[BBTScoresManager sharedScoresManager] retriveScores:self.userInfo WithConditions:nil];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didGetScoresNotification
{
    NSLog(@"Scores Notification Received");
    self.scoresArray = [[NSArray alloc] initWithArray:[BBTScoresManager sharedScoresManager].scoresArray];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"查询成功";
    HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    HUD.square = YES;
    [HUD showInView:self.tableView];
    [HUD dismissAfterDelay:2.0 animated:YES];
}

- (void)failGetScoresNotification
{
    NSLog(@"Fail to Get Scores");
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    if ([self.errorType integerValue] == 0) {
        alertController = [UIAlertController alertControllerWithTitle:@"连接错误" message:@"可能是网络不好，请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:@"无此学期成绩" message:@"请重新选择学期或学年" preferredStyle:UIAlertControllerStyleAlert];
    }
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [self.scoresArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:filterCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"学年/学期";
        cell.detailTextLabel.text = @"请选择学年或学期";
        return cell;
    } else {
        BBTScoresCell *cell = (BBTScoresCell *)[tableView dequeueReusableCellWithIdentifier:scoresCellIdentifier forIndexPath:indexPath];
        [cell configureForScores:self.scoresArray[indexPath.row]];
        [cell updateConstraintsIfNeeded];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSArray *rows = @[@[@"大一", @"大二", @"大三", @"大四", @"大五"],
                          @[@"全学年", @"第一学期", @"第二学期"]
                          ];
        NSArray *initialSelection = @[@0, @0];
        [ActionSheetMultipleStringPicker showPickerWithTitle:@"请选择学期或学年"
                                                        rows:rows
                                            initialSelection:initialSelection
                                                   doneBlock:^(ActionSheetMultipleStringPicker *picker, NSArray *selectedIndexes, id selectedValues) {
                                                       [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = [selectedValues[0] stringByAppendingString:selectedValues[1]];
                                                       NSInteger year = [(NSNumber *)selectedIndexes[0] integerValue];
                                                       NSDictionary *conditions = @{@"year":@(year + 1),
                                                                                    @"term":selectedIndexes[1]
                                                                                    };
                                                       [[BBTScoresManager sharedScoresManager] retriveScores:self.userInfo WithConditions:conditions];
                                                       [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        }
                                                 cancelBlock:^(ActionSheetMultipleStringPicker *picker) {
            
        }
                                                      origin:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

@end
