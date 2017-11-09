//
//  OITableViewController.m
//  timeTable1
//
//  Created by zzddn on 2017/8/28.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "OITableViewController.h"
#import "OITableViewCell.h"
#import "ScheduleDateManager.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface OITableViewController ()
@property (nonatomic,strong)ScheduleDateManager *manager;
@end

@implementation OITableViewController
- (ScheduleDateManager *)manager{
    if (_manager == nil){
        _manager = [ScheduleDateManager new];
    }
    return _manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOneCell:) name:@"deleteCell" object:nil];
    
    //设置导航栏字体和颜色
    self.navigationItem.title = @"教务导课";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    //设置右按钮
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right setImage:[UIImage imageNamed:@"donev"] forState:UIControlStateNormal];
    [right setFrame:CGRectMake(0, 0, 47.0/2.0, 34.0/2.0)];
    [right addTarget:self action:@selector(completeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:right];
    
    //设置左按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setImage:[UIImage imageNamed:@"cancelx"] forState:UIControlStateNormal];
    [left setFrame:CGRectMake(0, 0, 35.0/2.0, 35.0/2.0)];
    [left addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:left];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findTJGet:) name:@"ThefindTJScheduleGet" object:nil];
    [self.manager getTheScheduleWithAccount:self.manager.account andPassword:nil andType:@"findTJ"];
    
}
- (void)findTJGet:(NSNotification *)noti{
    [self.tableView reloadData];
}
- (void)completeBtnDidClick:(UIButton *)sender{
    if (self.manager.mutCourseArray != nil){
        if ([ScheduleDateManager sharedManager].mutCourseArray != nil){
            NSMutableArray *selectWrong = [NSMutableArray array];
            bool isInArray = NO;
            //教务网导课的时候对本地课表进行一一检索，如果发现本地课表已经有这个课了，那么就不进行导入
            for (ScheduleDateManager *oneManger in self.manager.mutCourseArray) {
                for (ScheduleDateManager *originManager in [ScheduleDateManager sharedManager].mutCourseArray){
                    if ([originManager.courseName isEqual:oneManger.courseName] && [originManager.teacherName isEqualToString:oneManger.teacherName] && [originManager.dayTime isEqualToString:oneManger.dayTime] && [originManager.day isEqualToString:oneManger.day] && [originManager.week isEqualToString:oneManger.week]){
                        isInArray = YES;
                        break;
                    }
                }
                if (!isInArray){
                    [selectWrong addObject:oneManger];
                }else{
                    isInArray = NO;
                }
            }
            [[ScheduleDateManager sharedManager].mutCourseArray addObjectsFromArray:selectWrong];
        }else{
            [ScheduleDateManager sharedManager].mutCourseArray = self.manager.mutCourseArray;
        }
    [[ScheduleDateManager sharedManager] updateLocalScheduleWithNoti:@"ThefindTJScheduleGet"];
    if ([self.delegate respondsToSelector:@selector(updateScheduleView)]){
        [self.delegate updateScheduleView];
     }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancelBtnDidClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIButton *)createLeftOrRightBtnWithTitle:(NSString *)title{
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.frame = CGRectMake(0, 0, 65, 30);
    completeBtn.backgroundColor = [UIColor whiteColor];
    [completeBtn setTitle:title forState:UIControlStateNormal];
    [completeBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [completeBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:191/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    completeBtn.layer.cornerRadius = 4;
    completeBtn.layer.masksToBounds = YES;
    completeBtn.showsTouchWhenHighlighted = YES;
    return completeBtn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCREEN_WIDTH/10.0*3.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.manager.mutCourseArray == nil){
        return 0;
    }else{
        return self.manager.mutCourseArray.count;
    }
}

- (OITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OICell"];
    if(!cell){
        [tableView registerNib:[UINib nibWithNibName:@"OITableViewCell" bundle:nil] forCellReuseIdentifier:@"OICell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OICell"];
    }
    
     ScheduleDateManager *single = self.manager.mutCourseArray[indexPath.row];
    cell.courseLabel.text = single.courseName;
    cell.timeLabel.text = [NSString stringWithFormat:@"时间 | %@ %@节", single.day,single.dayTime];
    cell.locationLabel.text = [NSString stringWithFormat:@"@%@",single.location];
    cell.teacherLabel.text = [NSString stringWithFormat:@"任课老师 | %@",single.teacherName];
    return cell;
}
- (void)deleteOneCell:(NSNotification *)noti{
    UIButton *sender = [noti object];
    OITableViewCell *cell = (OITableViewCell *)[[sender superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView beginUpdates];
    [self.manager.mutCourseArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}
@end
