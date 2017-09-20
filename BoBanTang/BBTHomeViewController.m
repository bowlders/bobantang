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
//#import "ScheduleViewController.h"
//#import "ScheduleDateManager.h"

@interface BBTHomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *CurrnetStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *NextStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *DestinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *BusCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *CourseTimetable;
@property (weak, nonatomic) IBOutlet UIButton *LoginButton;
@property (weak, nonatomic) IBOutlet UILabel *LoginReminderLabel;
@property (weak, nonatomic) IBOutlet UIStackView *CampusBusStackView;
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
    
#pragma mark -- 跳转到课表的方式应该如下，如果已经有了导航控制器，就不要再新建了
    //UIStoryboard *board = [UIStoryboard storyboardWithName:@"Schedule" bundle:nil];
    //ScheduleViewController *schedule = [board instantiateViewControllerWithIdentifier:@"ScheduleVC"];
    //UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:schedule];
    //[self presentViewController:navi animated:YES completion:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.frame.size.height / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBTCourseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CourseTimetableCellReuseIdentifier"];
    cell.ClassNumberLabel.text = @"第3-4节";
    return cell;
}
/*
#pragma mark -- 这个方法，是实现更新首页课表部分的回调block
- (void)loadScheduleData{
    __weak BBTHomeViewController *wself = self;
    [ScheduleDateManager sharedManager].block = ^(ScheduleDateManager *current, ScheduleDateManager *next){
        //current和next有可能为nil，要在这里更新cell的话，用到self要注意弱引用，所以用wself
        //[wself.CourseTimetable reloadData];
        //current.courseName 课程名称
        //current.dayTime 第几节到第几节
        //current.teacherName 老师
        //current.location 地点
    };
    //账号也要补齐
    [[ScheduleDateManager sharedManager] getTheCurrentAndNextCoursesWithAccount:@""];
}
 */
@end
