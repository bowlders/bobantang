//
//  BBTLectureRoomsQueryTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 8/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTLectureRoomsQueryTableViewController.h"
#import "ActionSheetPicker.h"

static NSString * const emptyRoomURL = @"http://218.192.166.167/api/protype.php?table=emptyroom";

@interface BBTLectureRoomsQueryTableViewController ()

@end

@implementation BBTLectureRoomsQueryTableViewController
{
    NSMutableArray *_parseResults;
    BBTLectureRooms *_filterConditions;
    NSArray *_rawData; //Not exactly raw data. Just without building filter.
    NSArray *_filterResults; //After filter buiding.
    BBTHudView *_hudView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _filterConditions = [[BBTLectureRooms alloc] init];
        _parseResults = [[NSMutableArray alloc] init];
        _rawData = [[NSArray alloc] init];
        _filterResults = [[NSArray alloc] init];
        
        _filterConditions.time = @[@"上午", @"下午", @"晚上"];
    }
    return self;
}

- (void)configureDefaultBuilings
{
    if (self.campus.selectedSegmentIndex == 0) {
        self.buildings.text = @"31";
    } else if (self.campus.selectedSegmentIndex == 1) {
        self.buildings.text = @"A1";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    [self configureDefaultBuilings];
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
    
    NSTimeInterval secondsPerDay = 3600 * 24;
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:secondsPerDay * 2];
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
    [self configureDefaultBuilings];
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

#pragma mark - Set Filter Conditions
- (void)configureFilterConditions
{
    _filterConditions.date = [self getDateString];
    _filterConditions.buildings = self.buildings.text;
    
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
    
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            [self choseBuilding];
        }
    }
    
    if (indexPath.section == 1)
    {
        _hudView = [BBTHudView hudInView:self.navigationController.view animated:YES];
        [self performGetEmptyRooms];
    }
}

- (void)choseBuilding
{
    if (self.campus.selectedSegmentIndex == 0)
    {
        NSArray *buildings = @[@"31", @"32", @"33", @"34", @"35"];
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"请选择教学楼"
                                                                                    rows:buildings
                                                                        initialSelection:0
                                                                               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                   self.buildings.text = selectedValue;
                                                                               }
                                                                             cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                 
                                                                             }
                                                                                  origin:self.buildings];
        [picker showActionSheetPicker];
    } else if (self.campus.selectedSegmentIndex == 1)
    {
        NSArray *buildings = @[@"A1", @"A2", @"A3"];
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"请选择教学楼"
                                                                                    rows:buildings
                                                                        initialSelection:0
                                                                               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                   self.buildings.text = selectedValue;
                                                                               }
                                                                             cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                 
                                                                             }
                                                                                  origin:self.buildings];
        [picker showActionSheetPicker];
    }
}

- (void)performGetEmptyRooms
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //NSDictionary *parameters = @{@"table":@"emptyroom",
    //                             @"method":@"get"};
    
    [manager POST:emptyRoomURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@" %lu", (unsigned long)[responseObject count]);
        _hudView = [BBTHudView removeHudInView:self.navigationController.view withHudView:_hudView];
        [self parse:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        _hudView = [BBTHudView removeHudInView:self.navigationController.view withHudView:_hudView];
        [self showAlert];
    }];
}

- (void)showAlert
{
    UIAlertController *alertController = [[UIAlertController alloc] init];
    alertController = [UIAlertController alertControllerWithTitle:@"连接错误" message:@"请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)parse:(NSArray *)responseObject
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

    _rawData = [_filterConditions filterCampusWithParseResults:_parseResults withFilterConditions:_filterConditions];
    NSLog(@"The number of empty rooms is %lu in one campus and they are", (unsigned long)[_rawData count]);
    
    _filterResults = [_filterConditions filterLectureRoomsWithFilterResults:_rawData withFilterConditions:_filterConditions];
    NSLog(@"The number of empty rooms is %lu and they are", (unsigned long)[_filterResults count]);
    
    [self performSegueWithIdentifier:@"ShowResult" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"TimePicker"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TimePicker"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTLectureRoomsTimeTableViewController *controller = (BBTLectureRoomsTimeTableViewController *)navigationController.topViewController;
        controller.delegate = self;
    } else {
        BBTLectureRoomsResultTableViewController *controller = segue.destinationViewController;
        controller.rawData = [[NSArray alloc] initWithArray:_rawData];
        controller.resultRooms = [[NSMutableArray alloc] initWithArray:_filterResults];
        controller.filterConditions = [[BBTLectureRooms alloc] init];
        controller.filterConditions = _filterConditions;
        
        _parseResults = [[NSMutableArray alloc] init];
    }
}

@end
