//
//  BBTLectureRoomsQueryTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 8/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTLectureRoomsQueryTableViewController.h"

static NSString * const emptyRoomURL = @"http://218.192.166.167/api/protype.php";

@interface BBTLectureRoomsQueryTableViewController ()

@end

@implementation BBTLectureRoomsQueryTableViewController
{
    NSArray *_selectedTime;
    NSArray *_selectedBuildings;
    BOOL _isLoading;
    NSMutableArray *_parseResults;
    BBTLectureRooms *_filterConditions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    self.lectureRoomsFilter = [[BBTLectureRooms alloc] init];
    _filterConditions = [[BBTLectureRooms alloc] init];
    _parseResults = [[NSMutableArray alloc] init];
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

//Responds to region format or locale changes.
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)campusChanged:(id)sender
{
    self.buildings.text = @"全部";
}

#pragma delegate methods
- (void)BBTLectureRoomsTime:(BBTLectureRoomsTimeTableViewController *)controller didFinishSelectTime:(NSArray *)selectedTime
{
    _filterConditions.time = selectedTime;
    
    if ([_filterConditions.time count] == 3)
    {
        self.time.text = @"全天";
    }
    else
    {
        NSMutableString *tempString = [[NSMutableString alloc] init];
        for (NSString *chosenTime in _filterConditions.time) {
            [tempString appendString:chosenTime];
        }
        self.time.text = tempString;
    }
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)BBTBuildings:(BBTBuildingsTableViewController *)controller didFinishSelectBuildings:(NSMutableArray *)selectedBuildings
{
    _filterConditions.seletedBulidings = selectedBuildings;
    
    if (self.campus.selectedSegmentIndex == 0)
    {
        if ([_filterConditions.seletedBulidings count] == 5) {
            self.buildings.text = @"全部";
        }
    } else if (self.campus.selectedSegmentIndex == 1) {
        if ([_filterConditions.seletedBulidings count] == 3) {
            self.buildings.text = @"全部";
        }
    }
    else
    {
        NSMutableString *tempString = [[NSMutableString alloc] init];
        for (NSString *chosenBuildings in _selectedBuildings) {
            [tempString appendString:chosenBuildings];
        }
        self.buildings.text = tempString;
    }
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Set Filter Conditions
- (void)configureFilterConditions
{
    _filterConditions.date = [self getDateString];
    if (self.campus.selectedSegmentIndex == 0) {
        _filterConditions.campus = @"N";
    } else {
        _filterConditions.campus = @"S";
    }
    
    //The rest conditions has been configured in Delegate Method.
}

- (NSString *)getDateString
{
    NSDate *date = self.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];

    return dateString;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        [self performGetEmptyRooms];
    }
}

- (void)performGetEmptyRooms
{
    _isLoading = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"table":@"emptyroom",
                                 @"method":@"get"};
    
    [manager POST:emptyRoomURL parameters:parameters success:^(AFHTTPRequestOperation * operation, NSArray *responseObject) {
        NSLog(@" %lu", (unsigned long)[responseObject count]);
        [self parse:responseObject];
        _isLoading = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        _isLoading = NO;
    }];
}

- (void)parse:(NSArray *)responseObject //还没调用过滤
{
    BBTLectureRooms *lectureRooms = [[BBTLectureRooms alloc] init];
    
    for (NSDictionary *resultDic in responseObject) {
        lectureRooms.date = resultDic[@"date"];
        lectureRooms.period = resultDic[@"period"];
        lectureRooms.campus = resultDic[@"campus"];
        lectureRooms.buildings = resultDic[@"building"];
        lectureRooms.lectureRooms = resultDic[@"room"];
        
        [_parseResults addObject:resultDic];
    }
    
    [self configureFilterConditions];
    NSArray *filterResults = [[NSArray alloc] init];
    filterResults = [_filterConditions filterLectureRooms:_parseResults withFilterConditions:_filterConditions];
    NSLog(@"The number of empty rooms is %lu and they are %@", (unsigned long)[filterResults count], filterResults);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TimePicker"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTLectureRoomsTimeTableViewController *controller = (BBTLectureRoomsTimeTableViewController *)navigationController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"BuildingsPicker"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTBuildingsTableViewController *controller = (BBTBuildingsTableViewController *)navigationController.topViewController;
        
        switch (self.campus.selectedSegmentIndex) {
            case 0:
                controller.buildingsToChoose = [[NSArray alloc] initWithObjects:@"31 ",@"32 ",@"33 ",@"34 ",@"35", nil];
                break;
            case 1:
                controller.buildingsToChoose = [[NSArray alloc] initWithObjects:@"A1 ",@"A2 ",@"A3 ", nil];
                break;
        }
        
        controller.delegate = self;
    }
}

@end
