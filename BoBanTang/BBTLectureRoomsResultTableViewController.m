//
//  BBTLectureRoomsResultTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 24/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTLectureRoomsResultTableViewController.h"
#import "ActionSheetPicker.h"
#import "BBTLectureRoomsManager.h"
#import <JGProgressHUD.h>
#import <MBProgressHUD.h>

static NSString *conditionCellIdentifier = @"conditionCell";
static NSString *resultCellIdentifier = @"resultsCell";
extern NSString *kDidGetEmptyRoomsNotificaionName;
extern NSString *kFailGetEmptyRoomsNotificaionName;

@interface BBTLectureRoomsResultTableViewController ()

@end

@implementation BBTLectureRoomsResultTableViewController
{
    NSArray *_selectedPeriod;
    NSMutableArray *_sortedResults;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRoomsNotification) name:kDidGetEmptyRoomsNotificaionName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetRoomsNotification) name:kFailGetEmptyRoomsNotificaionName object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:0/255.0 green:153.0/255.0 blue:204.0/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    _selectedPeriod = [[NSArray alloc] initWithArray:self.filterConditions.period];
    
    self.tableView.scrollEnabled = NO;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self retriveRoomsWithConditions:self.filterConditions];
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

- (void)retriveRoomsWithConditions:(BBTLectureRooms *)filterdConditions;
{
    NSDictionary *conditions = @{@"date":filterdConditions.date,
                                 @"period":filterdConditions.period,
                                 @"campus":filterdConditions.campus,
                                 @"building":filterdConditions.buildings
                                 };
    
    [[BBTLectureRoomsManager sharedLectureRoomsManager] retriveEmptyRoomsWithConditions:conditions];
}

- (void)didGetRoomsNotification
{
    NSLog(@"Get Rooms");
    NSArray *test = [[NSArray alloc] initWithArray:[BBTLectureRoomsManager sharedLectureRoomsManager].rooms];
    NSLog(@"Rooms: %lu", (unsigned long)[test count]);
    [self.tableView reloadData];
    
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"查询成功";
    HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    HUD.square = YES;
    [HUD showInView:self.tableView];
    [HUD dismissAfterDelay:2.0 animated:YES];
    self.tableView.scrollEnabled = YES;
}

- (void)failGetRoomsNotification
{
    NSLog(@"Fail to Get Rooms");
    
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"查询失败";
    HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    HUD.square = YES;
    [HUD showInView:self.tableView];
    [HUD dismissAfterDelay:2.0 animated:YES];
    self.tableView.scrollEnabled = YES;
}

- (void)reConfigureRooms
{
    self.resultRooms = [_filterConditions filterLectureRoomsWithFilterResults:self.rawData withFilterConditions:_filterConditions];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNum = [_selectedPeriod count] + 1;
    
    return sectionNum;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
    if (section == 0) {
        sectionName = @"请选择楼栋";
        return sectionName;
    } else {
        if ([_selectedPeriod[section-1] isEqualToString:@"0"]) {
            sectionName = @"1-2节";
        } else if ([_selectedPeriod[section-1] isEqualToString:@"1"]) {
            sectionName = @"3-4节";
        } else if ([_selectedPeriod[section-1] isEqualToString:@"2"]) {
            sectionName = @"5-6节";
        } else if ([_selectedPeriod[section-1] isEqualToString:@"3"]) {
            sectionName = @"7-8节";
        } else if ([_selectedPeriod[section-1] isEqualToString:@"4"]) {
            sectionName = @"晚上";
        }
        return sectionName;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [[BBTLectureRoomsManager sharedLectureRoomsManager].rooms count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:conditionCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"楼栋";
        cell.detailTextLabel.text = _filterConditions.buildings;
        return cell;
    } else {
        
        NSArray *results = [BBTLectureRoomsManager sharedLectureRoomsManager].rooms;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSMutableArray *rooms = [[NSMutableArray alloc] init];
        for (NSDictionary *lectureRooms in results) {
            [rooms addObject:lectureRooms[@"room"]];
        }
        cell.textLabel.text = rooms[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"请选择楼栋"
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSArray *buildings;
        if ([self.filterConditions.campus isEqualToString:@"N"]) {
            buildings = @[@"31", @"32", @"33", @"34", @"35"];
        } else if ([self.filterConditions.campus isEqualToString:@"S"]) {
           buildings = @[@"A1", @"A2", @"A3"];
        }
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"请选择教学楼"
                                                                                    rows:buildings
                                                                        initialSelection:0
                                                                               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                   self.filterConditions.buildings = selectedValue;
                                                                                   [self retriveRoomsWithConditions:self.filterConditions];
                                                                                   [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
                                                                                   self.tableView.scrollEnabled = NO;
                                                                               }
                                                                             cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                 
                                                                             }
                                                                                  origin:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].detailTextLabel];
        [picker showActionSheetPicker];

    }
}

@end
