//
//  BBTLectureRoomsSettingsViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/21.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLectureRoomsSettingsViewController.h"
#import "BBTLectureRoomsTimeTableViewController.h"
#import "BBTLectureRoomsResultTableViewController.h"
#import "BBTLectureRooms.h"
#import "UIColor+BBTColor.h"
#import "BBTItemCampusTableViewCell.h"
#import "ActionSheetPicker.h"
#import <Masonry.h>
#import <AYVibrantButton.h>
#import <AVOSCloud.h>

static NSString * campusCellIdentifier = @"BBTItemCampusTableViewCell";
static NSString * rightDetailCellIdentifier = @"itemRightDetailCell";
static NSString * timePickerSegueIdentifier = @"TimePicker";
static NSString * showResultsSegueIdentifier = @"showResults";

@interface BBTLectureRoomsSettingsViewController ()

@property (strong, nonatomic) UITableView        * tableView;
@property (strong, nonatomic) AYVibrantButton    * searchButton;
@property (strong, nonatomic) UISegmentedControl * campus;

@property (strong, nonatomic) NSDictionary       * conditions;
@property (strong, nonatomic) BBTLectureRooms    * setConditions;
@property (strong, nonatomic) NSArray            * rooms;
@property (strong, nonatomic) NSString           * timeToShow;
- (IBAction)BackToHome:(UIButton *)sender;

@end

@implementation BBTLectureRoomsSettingsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"iOS_emptyRooms"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationItem.title = @"自习室查询";
    
    self.setConditions = [[BBTLectureRooms alloc] init];
    self.setConditions.campus = @"N";
    self.timeToShow = @"全天";
    
    //Set TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.scrollEnabled = NO;
    [self.tableView registerNib:[UINib nibWithNibName:campusCellIdentifier bundle:nil] forCellReuseIdentifier:campusCellIdentifier];
    
    //Set Button
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    effectView.frame = self.view.bounds;
    [self.view addSubview:effectView];
    self.searchButton = [[AYVibrantButton alloc] initWithFrame:CGRectZero style:AYVibrantButtonStyleFill];
    self.searchButton.vibrancyEffect = nil;
    self.searchButton.text = @"搜索";
    self.searchButton.font = [UIFont systemFontOfSize:18.0];
    self.searchButton.backgroundColor = [UIColor BBTAppGlobalBlue];
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchButton addTarget:self action:@selector(searchEmptyRooms) forControlEvents:UIControlEventTouchUpInside];
    [effectView.contentView addSubview:self.searchButton];
    [effectView.contentView addSubview:self.tableView];
    
    //Set up constrains
    CGFloat buttonHeight = 50.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat verticalInnerSpacing = 44.0f;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight);
        make.height.equalTo(@196);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
    }];
    
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(verticalInnerSpacing);
        make.height.equalTo(@(buttonHeight));
        make.width.equalTo(self.view.mas_width).multipliedBy(0.55);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"iOS_emptyRooms"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)valueChangeMethod:(UISegmentedControl *)segementcontrol
{
    if (segementcontrol.selectedSegmentIndex == 0) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]].detailTextLabel.text = @"31";
        self.setConditions.campus = @"N";
    } else {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]].detailTextLabel.text = @"A1";
        self.setConditions.campus = @"S";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:rightDetailCellIdentifier];
    
    if (indexPath.row == 2)
    {
        BBTItemCampusTableViewCell *cell = (BBTItemCampusTableViewCell *)[tableView dequeueReusableCellWithIdentifier:campusCellIdentifier];
        self.campus = cell.campus;
        [self.campus addTarget:self action:@selector(valueChangeMethod:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rightDetailCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            
            self.setConditions.date = [dateFormatter stringFromDate:[NSDate date]];
            
            cell.textLabel.text = @"日期";
            cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate date]];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"时段";
            cell.detailTextLabel.text = self.timeToShow;
            self.setConditions.period = @[@"0",@"1",@"2",@"3",@"4"];
        }
        else
        {
            cell.textLabel.text = @"楼栋";
            cell.detailTextLabel.text = @"32";
            self.setConditions.buildings = @"32";
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        NSArray *buildings;
        if (self.campus.selectedSegmentIndex == 0) {
           buildings = @[@"32", @"33", @"34", @"博学"];
        } else if (self.campus.selectedSegmentIndex == 1) {
           buildings = @[@"A1", @"A2", @"A3"];
        }
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"请选择教学楼"
                                                                                    rows:buildings
                                                                        initialSelection:0
                                                                               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                   [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = selectedValue;
                                                                                   self.setConditions.buildings = selectedValue;
                                                                               }
                                                                             cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                 
                                                                             }
                                                                                  origin:[self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel];
        [picker showActionSheetPicker];

    }
    else if (indexPath.row == 0)
    {
        AbstractActionSheetPicker *datePicker;
        
        NSDate *minDate = [NSDate date];
        NSDate *maxDate = [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 3];
        
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                   datePickerMode:UIDatePickerModeDate
                                                     selectedDate:[NSDate date]
                                                      minimumDate:minDate
                                                      maximumDate:maxDate
                                                           target:self
                                                           action:@selector(dateWasSelected:element:)
                                                           origin:[tableView cellForRowAtIndexPath:indexPath].detailTextLabel];
        [datePicker showActionSheetPicker];
    }
    else if (indexPath.row == 1)
    {
        [self performSegueWithIdentifier:timePickerSegueIdentifier sender:nil];
    }
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [element setText:[dateFormatter stringFromDate:selectedDate]];
}

- (void)BBTLectureRoomsTime:(BBTLectureRoomsTimeTableViewController *)controller didFinishSelectTime:(NSMutableArray *)selectedTime
{
    NSMutableArray *selectedPeriod = [[NSMutableArray alloc] init];
    
    for (NSString *timeString in selectedTime)
    {
        if ([timeString isEqualToString:@"上午"]) {
            [selectedPeriod addObject:@"0"];
            [selectedPeriod addObject:@"1"];
        }
        
        if ([timeString isEqualToString:@"下午"]) {
            [selectedPeriod addObject:@"2"];
            [selectedPeriod addObject:@"3"];
        }
        
        if ([timeString isEqualToString:@"晚上"]) {
            [selectedPeriod addObject:@"4"];
        }
    }
    
    self.setConditions.period = selectedPeriod;
    
    if ([selectedTime count] == 3)
    {
        self.timeToShow = @"全天";
    }
    else
    {
        NSMutableString *tempString = [[NSMutableString alloc] init];
        for (NSString *chosenTime in selectedTime) {
            [tempString appendString:chosenTime];
        }
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].detailTextLabel.text = tempString;
    }
    
    //[self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchEmptyRooms
{
    self.setConditions.date = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].detailTextLabel.text;
    self.setConditions.buildings = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]].detailTextLabel.text;
    self.conditions = @{@"date":self.setConditions.date,
                        @"period":self.setConditions.period,
                        @"campus":self.setConditions.campus,
                        @"building":self.setConditions.buildings
                        };
    [self performSegueWithIdentifier:showResultsSegueIdentifier sender:nil];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:timePickerSegueIdentifier]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTLectureRoomsTimeTableViewController *controller = (BBTLectureRoomsTimeTableViewController *)navigationController.topViewController;
        controller.delegate = self;
        //记住曾经选了什么
        controller.period = self.setConditions.period;
    } else if ([segue.identifier isEqualToString:showResultsSegueIdentifier]) {
        BBTLectureRoomsResultTableViewController *controller = segue.destinationViewController;
        controller.filterConditions = self.setConditions;
    }
}

- (IBAction)BackToHome:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
