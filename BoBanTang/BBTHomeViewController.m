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
#import <AFNetworking.h>
#import "UIImageView+WebCache.h"
//#import "ScheduleViewController.h"
//#import "ScheduleDateManager.h"
static NSString*baseURL = @"http://community.100steps.net/information/activities/head_picture";
@interface BBTHomeViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (strong,nonatomic) NSMutableArray *GetArray;
@property (strong,nonatomic) NSMutableArray *clubArray;
@property (strong,nonatomic) NSMutableArray *infoArray;
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UIScrollView *headFigure;
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
    [self.view sendSubviewToBack:self.scrollView];
    self.CourseTimetable.dataSource = self;
    self.CourseTimetable.delegate = self;
    [self.CourseTimetable registerNib:[UINib nibWithNibName:@"BBTCourseTableViewCell" bundle:nil] forCellReuseIdentifier:@"CourseTimetableCellReuseIdentifier"];
    [self loadData];
    // 设置图片
    
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
- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, 414, 300)];//130
        _scrollView.backgroundColor = [UIColor blackColor];
        
        [self.view addSubview:_scrollView];
        
        // 取消弹簧效果
        _scrollView.bounces = NO;
        
        // 取消水平滚动条
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        // 要分页
        _scrollView.pagingEnabled = YES;
        
        // contentSize
        _scrollView.contentSize = CGSizeMake(self.GetArray.count * _scrollView.bounds.size.width, 0);
        
        // 设置代理
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}
- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        // 分页控件
        _pageControl = [[UIPageControl alloc] init];
        // 总页数
        _pageControl.numberOfPages = self.GetArray.count;
        // 控件尺寸
        CGSize size = [_pageControl sizeForNumberOfPages:self.GetArray.count];
        
        _pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
        _pageControl.center = CGPointMake(350, 200);
        
        // 设置颜色
        _pageControl.pageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        
        [self.view addSubview:_pageControl];
        
        // 添加监听方法
        /** 在OC中，绝大多数"控件"，都可以监听UIControlEventValueChanged事件，button除外" */
        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}
// 分页控件的监听方法
- (void)pageChanged:(UIPageControl *)page
{
    NSLog(@"%ld", (long)page.currentPage);
    
    // 根据页数，调整滚动视图中的图片位置 contentOffset
    CGFloat x = page.currentPage * self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

-(void)loadData
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:baseURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@",responseObject);
        self.GetArray = responseObject;
        NSLog(@"%@",self.GetArray[1][0][@"content"][@"picture"]);
        NSLog(@"%lu",(unsigned long)self.GetArray.count);
        self.clubArray = self.GetArray[0];
        self.infoArray = self.GetArray[1];
        
        for (int i = 0; i < self.clubArray.count; i++)
        {
            //头图
            //NSString *imageName = [NSString stringWithFormat:@"img_0%d", i + 1];//%02d
            //UIImage *image = [UIImage imageNamed:imageName];
            UIImageView *imaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 210)];
            //imaView.image = image;
            NSString *URL =[NSString stringWithFormat:@"%@", self.GetArray[0][i][@"content"][@"picture"]];
            [imaView sd_setImageWithURL:[NSURL URLWithString:URL]];
            [self.scrollView addSubview:imaView];
            CGRect Imageframe = imaView.frame;
            Imageframe.origin.x = (i * Imageframe.size.width / 2);
            imaView.frame = Imageframe;
            
            
            UIImage *infoImage = [UIImage imageNamed:@"headInfo"];
            UIImageView *infoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 210, self.scrollView.bounds.size.width, 90)];
            infoView.image =infoImage ;
            [self.scrollView addSubview:infoView];
            CGRect Infomaframe = infoView.frame;
            Infomaframe.origin.x = (i * Infomaframe.size.width / 2);
            infoView.frame = Infomaframe;
            
            //标题
            UILabel* mainlabel = [[UILabel alloc]initWithFrame:CGRectMake((50+(i*self.scrollView.bounds.size.width)),230,300,30)];
            mainlabel.tag = i;
            mainlabel.text = [NSString stringWithFormat:@"%@",self.GetArray[0][i][@"title"]];
            mainlabel.textColor = [UIColor whiteColor];
            mainlabel.backgroundColor = [UIColor clearColor];
            mainlabel.textAlignment = NSTextAlignmentCenter;
            mainlabel.font = [UIFont fontWithName:@"Arial" size:25];
            mainlabel.numberOfLines = 1;
            [self.view addSubview:mainlabel];
            
            
            //小头图
            /*UIImage *smallImage = [UIImage imageNamed:@"headInfo"];
            UIImageView *infoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 210, self.scrollView.bounds.size.width, 90)];
            infoView.image =infoImage ;
            [self.scrollView addSubview:infoView];
            CGRect Infomaframe = infoView.frame;
            Infomaframe.origin.x = (i * Infomaframe.size.width / 2);
            infoView.frame = Infomaframe;
*/
        }
        for (int i = 0 ; i < self.clubArray.count; i++)
        {
            //NSString *imageName = [NSString stringWithFormat:@"img_0%d", i + 1];//%02d
            //UIImage *image = [UIImage imageNamed:imageName];
            UIImageView *imaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.scrollView.bounds.size.width, 210)];
            //imaView.image = image;
            NSString *URL =[NSString stringWithFormat:@"%@", self.GetArray[1][i][@"content"][@"picture"]];
            [imaView sd_setImageWithURL:[NSURL URLWithString:URL]];
            [self.scrollView addSubview:imaView];
            CGRect Imageframe = imaView.frame;
            Imageframe.origin.x = ((i+self.clubArray.count) * Imageframe.size.width / 2);
            imaView.frame = Imageframe;
            
            UIImage *infoImage = [UIImage imageNamed:@"headInfo"];
            UIImageView *infoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 210,self.scrollView.bounds.size.width, 90)];
            infoView.image =infoImage ;
            [self.scrollView addSubview:infoView];
            CGRect Infomaframe = infoView.frame;
            Infomaframe.origin.x = ((i+self.clubArray.count)* Infomaframe.size.width / 2);
            infoView.frame = Infomaframe;
            
            UILabel* mainlabel = [[UILabel alloc]initWithFrame:CGRectMake((50+((i+self.clubArray.count)*self.scrollView.bounds.size.width)),230,300,30)];
            mainlabel.tag = i;
            mainlabel.text = [NSString stringWithFormat:@"%@",self.GetArray[1][i][@"title"]];
            mainlabel.textColor = [UIColor whiteColor];
            mainlabel.backgroundColor = [UIColor clearColor];
            mainlabel.textAlignment = NSTextAlignmentCenter;
            mainlabel.font = [UIFont fontWithName:@"Arial" size:25];
            mainlabel.numberOfLines = 1;
            [self.view addSubview:mainlabel];
            
        }

        
        
        //    NSLog(@"%@", self.scrollView.subviews)
        
        // 分页初始页数为0
        self.pageControl.currentPage = 0;
        
        // 启动时钟
        [self startTimer];
        
    }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             
             NSLog(@"%@",error);  //这里打印错误信息
             
         }];
    
}
- (void)startTimer
{
    self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    // 添加到运行循环
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimer
{
    // 页号发生变化
    // (当前的页数 + 1) % 总页数
    unsigned long page = (self.pageControl.currentPage + 1) % self.GetArray.count;
    self.pageControl.currentPage = page;
    
    NSLog(@"%ld", (long)self.pageControl.currentPage);
    // 调用监听方法，让滚动视图滚动
    [self pageChanged:self.pageControl];
    
}

#pragma mark - ScrollView的代理方法
// 滚动视图停下来，修改页面控件的小点（页数）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 停下来的当前页数
    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    
    // 计算页数
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    self.pageControl.currentPage = page;
}

/**
 修改时钟所在的运行循环的模式后，抓不住图片
 
 解决方法：抓住图片时，停止时钟，送售后，开启时钟
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
    // 停止时钟，停止之后就不能再使用，如果要启用时钟，需要重新实例化
    [self.timer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"%s", __func__);
    [self startTimer];
}

-(void)ArrangeData:(UIPageControl *)page
{
    for(int i = 0; i<self.GetArray.count; i++)
    {
        UILabel* mainlabel = [[UILabel alloc]initWithFrame:CGRectMake((50+(page.currentPage * self.scrollView.bounds.size.width)),230,300,30)];
        mainlabel.tag = page.currentPage;
        mainlabel.text = [NSString stringWithFormat:@"%@",self.GetArray[0][page.currentPage][@"title"]];
        mainlabel.textColor = [UIColor whiteColor];
        mainlabel.backgroundColor = [UIColor clearColor];
        mainlabel.textAlignment = NSTextAlignmentCenter;
        mainlabel.font = [UIFont fontWithName:@"Arial" size:25];
        mainlabel.numberOfLines = 1;
        [self.view addSubview:mainlabel];
    }
}
@end
