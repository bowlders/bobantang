//
//  BBTLectureRoomsTimeTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 7/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTLectureRoomsTimeTableViewController.h"

@interface BBTLectureRoomsTimeTableViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *morningCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *afternoonCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *eveningCell;


@end

@implementation BBTLectureRoomsTimeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:0/255.0 green:153.0/255.0 blue:204.0/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    if (self.period){
        if (![self.period containsObject:@"0"]&&![self.period containsObject:@"1"]){
            self.morningCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (![self.period containsObject:@"2"]&&![self.period containsObject:@"3"]){
            self.afternoonCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (![self.period containsObject:@"4"]){
            self.eveningCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (IBAction)done
{
    NSMutableArray *selectedTime = [[NSMutableArray alloc] init];
    
    if (self.morningCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [selectedTime addObject:@"上午"];
    }
    if (self.afternoonCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [selectedTime addObject:@"下午"];
    }
    if (self.eveningCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [selectedTime addObject:@"晚上"];
    } else if (self.morningCell.accessoryType == UITableViewCellAccessoryNone &&
               self.afternoonCell.accessoryType == UITableViewCellAccessoryNone &&
               self.eveningCell.accessoryType == UITableViewCellAccessoryNone) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"请至少选择一个时段" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [self.delegate BBTLectureRoomsTime:self didFinishSelectTime:selectedTime];
}



@end
