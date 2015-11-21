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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    self.lectureRoomsFilter = [[BBTLectureRooms alloc] init];
    
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
    [self getJson];
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
    _selectedTime = selectedTime;
    
    if ([_selectedTime count] == 3)
    {
        self.time.text = @"全天";
    }
    else
    {
        NSMutableString *tempString = [[NSMutableString alloc] init];
        for (NSString *chosenTime in _selectedTime) {
            [tempString appendString:chosenTime];
        }
        self.time.text = tempString;
    }
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)BBTBuildings:(BBTBuildingsTableViewController *)controller didFinishSelectBuildings:(NSMutableArray *)selectedBuildings
{
    _selectedBuildings = selectedBuildings;
    
    if ([_selectedBuildings count] == 5)
    {
        self.buildings.text = @"全部";
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

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"尽请期待" message:@"等接口 ＝＝" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
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
                controller.buildingsToChoose = [[NSArray alloc] initWithObjects:@"A1 ",@"A2 ",@"A3 ",@"A4 ",@"A5 ", nil];
                break;
        }
        
        controller.delegate = self;
    }
}

- (void)getJson
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:emptyRoomURL parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
@end
