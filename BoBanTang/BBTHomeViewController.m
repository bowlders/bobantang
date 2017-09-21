//
//  BBTHomeViewController.m
//  波板糖
//
//  Created by Authority on 2017/9/13.
//  Copyright © 2017年 100steps. All rights reserved.
//

#import "BBTHomeViewController.h"
#import <MBProgressHUD.h>
#import "BBTCampusBusManager.h"
#import "BBTCampusBus.h"
#import "BBTCourseTableViewCell.h"
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"
#import "BBTGoSegmentedControlViewController.h"
#import "ScheduleViewController.h"
#import "ScheduleDateManager.h"

@interface BBTHomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *CurrnetStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *NextStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *DestinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *BusCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *CourseTimetable;
@property (weak, nonatomic) IBOutlet UIButton *LoginButton;
@property (weak, nonatomic) IBOutlet UILabel *LoginReminderLabel;
@property (weak, nonatomic) IBOutlet UIStackView *CampusBusStackView;
@property (strong, nonatomic) NSArray<ScheduleDateManager *> *courseArr;
- (IBAction)changeDirection:(UIButton *)sender;
- (IBAction)login:(id)sender;

@end

@implementation BBTHomeViewController

extern NSString * kUserAuthentificationFinishNotifName;
bool ReceiveCampusBusNotification = false;
bool ReceiveUserAuthenticationNotif = false;

- (void)viewWillAppear:(BOOL)animated{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCampusBusNotification)
                                                 name:campusBusNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRetriveCampusBusDataFailNotification)
                                                 name:retriveCampusBusDataFailNotifName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUserAuthenticationNotif)
                                                 name:kUserAuthentificationFinishNotifName
                                               object:nil];
    [self reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    //reload一下课表的data
    self.courseArr = [[ScheduleDateManager sharedManager] getTheCurrentAndNextCoursesWithAccount:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account];
    [self.CourseTimetable reloadData];
    
    if (![[BBTCurrentUserManager sharedCurrentUserManager] userIsActive])
    {
        self.CourseTimetable.hidden = true;
        self.LoginReminderLabel.hidden = false;
        self.LoginButton.hidden = false;
    }else{
        self.CourseTimetable.hidden = false;
        self.LoginReminderLabel.hidden = true;
        self.LoginButton.hidden = true;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.CourseTimetable.dataSource = self;
    self.CourseTimetable.delegate = self;
    [self.CourseTimetable registerNib:[UINib nibWithNibName:@"BBTCourseTableViewCell" bundle:nil] forCellReuseIdentifier:@"CourseTimetableCellReuseIdentifier"];
    
    //获取本地课表数据
    self.courseArr = [[ScheduleDateManager sharedManager] getTheCurrentAndNextCoursesWithAccount:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account];
}


- (void)didReceiveCampusBusNotification
{
    //NSLog(@"Did receive campus bus notification");
    
    //Hide loading hud
    ReceiveCampusBusNotification = true;
    if ((ReceiveCampusBusNotification == true)&&(ReceiveUserAuthenticationNotif == true)){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    [self reloadData];
}

- (void)didReceiveRetriveCampusBusDataFailNotification
{
    //Hide loading hud
    ReceiveCampusBusNotification = true;
    if ((ReceiveCampusBusNotification == true)&&(ReceiveUserAuthenticationNotif == true)){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    [self reloadData];
}

-(void)didReceiveUserAuthenticationNotif{
    if (![[BBTCurrentUserManager sharedCurrentUserManager] userIsActive])
    {
        self.CourseTimetable.hidden = true;
        self.LoginReminderLabel.hidden = false;
        self.LoginButton.hidden = false;
    }else{
        self.CourseTimetable.hidden = false;
        self.LoginReminderLabel.hidden = true;
        self.LoginButton.hidden = true;
    }
    ReceiveUserAuthenticationNotif = true;
    if ((ReceiveCampusBusNotification == true)&&(ReceiveUserAuthenticationNotif == true)){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

bool direction;

- (void)reloadData{
    BBTCampusBusManager *busManager = [BBTCampusBusManager sharedCampusBusManager];
    NSMutableArray * runningBusArray = [busManager getRunningBuses];
    self.BusCountLabel.text = [NSString stringWithFormat:@"当前有%i辆校巴正在运行",(int)runningBusArray.count];
    if (runningBusArray.count == 0)
    {
        self.CurrnetStationLabel.text = @"暂无校巴";
        self.NextStationLabel.text = @"下一站：";
        self.DestinationLabel.text = @"终点站：";
    }
    else
    {
        if ([busManager getBusInDirection:direction] == nil) {
            direction = !direction;
        }
        BBTCampusBus * CampusBus = [busManager getBusInDirection:direction];
        self.CurrnetStationLabel.text = CampusBus.Station;
        if (direction == true) {
            self.DestinationLabel.text = [NSString stringWithFormat:@"终点站：%@",
                                          [busManager.stationNameArray lastObject]];
            if (CampusBus.StationIndex == 1) {
                self.NextStationLabel.text = [NSString stringWithFormat:@"下一站：%@",
                                              CampusBus.Station];
            }else{
                self.NextStationLabel.text = [NSString stringWithFormat:@"下一站：%@",
                                              [busManager.stationNameArray objectAtIndex:12 - CampusBus.StationIndex + 1]];
            }
        }else{
            self.DestinationLabel.text = [NSString stringWithFormat:@"终点站：%@",
                                          [busManager.stationNameArray firstObject]];
            if (CampusBus.StationIndex == busManager.stationNameArray.count) {
                self.NextStationLabel.text = [NSString stringWithFormat:@"下一站：%@", CampusBus.Station];
            }else{
                self.NextStationLabel.text = [NSString stringWithFormat:@"下一站：%@",
                                              [busManager.stationNameArray objectAtIndex:12 - CampusBus.StationIndex - 1]];
            }
        }
    }
}

- (IBAction)changeDirection:(UIButton *)sender {
    direction = !direction;
    [self reloadData];
}

- (IBAction)login:(id)sender {
    BBTLoginViewController *loginViewController = [[BBTLoginViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat{
    return tableView.frame.size.height / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBTCourseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CourseTimetableCellReuseIdentifier"];
    NSInteger rowCount = indexPath.row;
    NSInteger courseCount = self.courseArr.count-1 ;
    if (self.courseArr!=nil && rowCount <= courseCount){
        ScheduleDateManager *oneCourse = self.courseArr[indexPath.row];
        cell.ClassNumberLabel.text = [NSString stringWithFormat:@"第%@节",oneCourse.dayTime];
        cell.TeacherLabel.text = [NSString stringWithFormat:@"任课老师 : %@",oneCourse.teacherName];
        cell.CourseLabel.text = oneCourse.courseName;
        cell.ClassroomLabel.text = [NSString stringWithFormat:@"地点 : %@",oneCourse.location];
    }else{
        cell.ClassNumberLabel.text = @"";
        cell.TeacherLabel.text = @"";
        cell.CourseLabel.text = @"";
        cell.ClassroomLabel.text = @"";
    }
    return cell;
}
@end
