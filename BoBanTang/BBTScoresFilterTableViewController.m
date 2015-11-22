//
//  BBTScoresFilterTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 21/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTScoresFilterTableViewController.h"

static NSString *kYearPickerCell = @"yearPcikerCell";

@interface BBTScoresFilterTableViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) NSMutableArray *filterConditions;
@property (strong, nonatomic) NSIndexPath *pickerIndexPath;

@end

@implementation BBTScoresFilterTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationItem.title = [NSString stringWithFormat:@"欢迎你，%@", self.scores.studentName];
    
    self.filterConditions = [[NSMutableArray alloc] init];
    
    [self configurePickerData];
    self.picker.dataSource = self;
    self.picker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configurePickerData
{
    /*
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY"];
    NSString *date = [dateFormatter stringFromDate:now];
    int yearInt = [date intValue];
    */
     
   // NSMutableArray *yearArray = [[NSMutableArray alloc] init];
    NSArray *semesterArray = @[@"全学年", @"第一学期", @"第二学期"];
    NSArray *yearArray = @[@"1", @"2", @"3", @"4"];
    
    /*
    for (NSInteger i = 0; i < 7; i++) {
        [yearArray addObject:date];
        --yearInt;
        date = [NSString stringWithFormat:@"%i", (int)yearInt];
    }
    */
    
    [self.filterConditions addObject:yearArray];
    [self.filterConditions addObject:semesterArray];
}

#pragma set pickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 4;
    } else {
        return 3;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.filterConditions[component][row];
}

- (void)getConditionsFromPicker
{
    NSInteger component = 0;
    NSInteger row;
    for (; component < 2 ; ++component) {
        row = [self.picker selectedRowInComponent:component];
        if (component == 0) {
            self.scores.year = [NSNumber numberWithInt:[self.filterConditions[component][row] intValue]];
        } else {
            if ([self.filterConditions[component][row] isEqualToString:@"第一学期"]) {
                self.scores.semester = [NSNumber numberWithInt:1];
            } else if ([self.filterConditions[component][row] isEqualToString:@"第二学期"]) {
                self.scores.semester = [NSNumber numberWithInt:2];
            }
        }
    }
}

- (BOOL)pickerIsShown
{
    return self.pickerIndexPath != nil;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self getConditionsFromPicker];
    BBTScoresQueryResultsTableViewController *controller = segue.destinationViewController;
    controller.scores = [[BBTScores alloc] init];
    controller.scores = self.scores;
}


@end
