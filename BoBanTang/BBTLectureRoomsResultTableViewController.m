//
//  BBTLectureRoomsResultTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 24/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTLectureRoomsResultTableViewController.h"

static NSString *conditionCellIdentifier = @"conditionCell";
static NSString *resultCellIdentifier = @"resultsCell";

@interface BBTLectureRoomsResultTableViewController ()

@end

@implementation BBTLectureRoomsResultTableViewController
{
    NSArray *_selectedPeriod;
    NSMutableArray *_sortedResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:0/255.0 green:153.0/255.0 blue:204.0/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    _selectedPeriod = [[NSArray alloc] initWithArray:[self.filterConditions configurePeriod:self.filterConditions]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sortRooms:(NSArray *)resultsRooms
{
    NSMutableArray *sortResult = [[NSMutableArray alloc] init];
    
    for (NSString *period in _selectedPeriod) {
        NSMutableArray *roomOfPeriod = [[NSMutableArray alloc] init];
        
        for (NSDictionary *resultDic in self.resultRooms) {
            NSString *periodInDic = resultDic[@"period"];
            if ([periodInDic isEqualToString:period]) {
                [roomOfPeriod addObject:resultDic];
            }
        }
        
        [sortResult addObject:roomOfPeriod];
    }
    
    return sortResult;
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
        NSArray *sortResult = [self sortRooms:self.resultRooms][section-1];
        return [sortResult count];
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
        NSArray *sortResult = [self sortRooms:self.resultRooms][indexPath.section-1];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier forIndexPath:indexPath];
        
        NSMutableArray *rooms = [[NSMutableArray alloc] init];
        for (NSDictionary *lectureRooms in sortResult) {
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
        
        if ([_filterConditions.campus isEqualToString:@"N"]) {
            NSArray *array = [[NSArray alloc] initWithObjects:@"31", @"32", @"33", @"34", @"35", nil];
            for (int number = 0; number < 5; ++number) {
                UIAlertAction *act = [UIAlertAction actionWithTitle:array[number] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    _filterConditions.buildings = array[number];
                    [self reConfigureRooms];
                }];
                [alertController addAction:act];
            }
        } else if ([_filterConditions.campus isEqualToString:@"S"]) {
            NSArray *array = [[NSArray alloc] initWithObjects:@"A1", @"A2", @"A3", nil];
            for (int number = 0; number < 3; ++number) {
                UIAlertAction *act = [UIAlertAction actionWithTitle:array[number] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    _filterConditions.buildings = array[number];
                    [self reConfigureRooms];
                }];
                [alertController addAction:act];
            }
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
        

    }
}

@end
