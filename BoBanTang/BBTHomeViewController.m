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
#import "ScheduleViewController.h"
#import "ScheduleDateManager.h"
#import "BBTScoresTableViewController.h"
#import "UIColor+BBTColor.h"

static NSString*baseURL = @"http://community.100steps.net/information/activities/head_picture";
static NSString * getclub = @"http://community.100steps.net/activities";
static NSString*getinfo = @"http://community.100steps.net/information?type=3";
@interface BBTHomeViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *_scrollerView;
@property (strong, nonatomic) IBOutlet UILabel *infoType;
@property (strong, nonatomic) IBOutlet UILabel *numberInfo;

@property (strong, nonatomic) IBOutlet UILabel *articleInfo;
@property (strong, nonatomic) IBOutlet UILabel *personInfo;

@property (strong, nonatomic) IBOutlet UIImageView *picture_1;
@property (strong, nonatomic) IBOutlet UIImageView *picture_2;
@property (strong, nonatomic) IBOutlet UIImageView *picture_3;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (strong,nonatomic) NSMutableArray *GetArray;
@property (strong,nonatomic) NSMutableArray *clubArray;
@property (strong,nonatomic) NSMutableArray *infoArray;
@property (strong,nonatomic) NSMutableDictionary *club_all;
@property (strong,nonatomic) NSMutableDictionary *info_all;
@property (nonatomic, strong) NSTimer *timer;


@property (weak, nonatomic) IBOutlet UILabel *CurrnetStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *NextStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *DestinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *BusCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *CourseTimetable;
@property (weak, nonatomic) IBOutlet UIButton *LoginButton;
@property (weak, nonatomic) IBOutlet UILabel *LoginReminderLabel;
@property (weak, nonatomic) IBOutlet UIStackView *CampusBusStackView;
@property (strong, nonatomic) NSArray<ScheduleDateManager *> *courseArr;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *TapToSchedule;

- (IBAction)changeDirection:(UIButton *)sender;
- (IBAction)login:(id)sender;
- (IBAction)TapToLostAndFound:(UITapGestureRecognizer *)sender;
- (IBAction)TapToCampusMap:(UITapGestureRecognizer *)sender;
- (IBAction)TapToGradeSearch:(UITapGestureRecognizer *)sender;
- (IBAction)TapToRoomSearch:(UITapGestureRecognizer *)sender;


@end

@implementation BBTHomeViewController

extern NSString * kUserAuthentificationFinishNotifName;

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
    
    if ([[BBTCurrentUserManager sharedCurrentUserManager] userIsActive])
    {
        self.CourseTimetable.hidden = true;
        self.LoginReminderLabel.hidden = false;
        self.LoginButton.hidden = true;
        self.TapToSchedule.enabled = NO;
    }else{
        self.CourseTimetable.hidden = false;
        self.LoginReminderLabel.hidden = true;
        self.LoginButton.hidden = true;
        self.TapToSchedule.enabled = YES;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.CourseTimetable.dataSource = self;
    self.CourseTimetable.delegate = self;
    [self.CourseTimetable registerNib:[UINib nibWithNibName:@"BBTCourseTableViewCell" bundle:nil] forCellReuseIdentifier:@"CourseTimetableCellReuseIdentifier"];
    [self loadData];
    // 设置图片
    
    //获取本地课表数据
    self.courseArr = [[ScheduleDateManager sharedManager] getTheCurrentAndNextCoursesWithAccount:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account];
}


- (void)didReceiveCampusBusNotification
{
    //NSLog(@"Did receive campus bus notification");
    
    //Hide loading hud
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self reloadData];
}

- (void)didReceiveRetriveCampusBusDataFailNotification
{
    //Hide loading hud
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self reloadData];
}

-(void)didReceiveUserAuthenticationNotif{
    if (![[BBTCurrentUserManager sharedCurrentUserManager] userIsActive])
    {
        self.CourseTimetable.hidden = true;
        self.LoginReminderLabel.hidden = false;
        self.LoginButton.hidden = true;
    }else{
        self.CourseTimetable.hidden = false;
        self.LoginReminderLabel.hidden = true;
        self.LoginButton.hidden = true;
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

- (IBAction)TapToLostAndFound:(UITapGestureRecognizer *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tools" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LostAndFound"];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:controller] animated:YES completion:nil];
}

- (IBAction)TapToCampusMap:(UITapGestureRecognizer *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tools" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"BBTMapView"];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:controller] animated:YES completion:nil];
}

- (IBAction)TapToGradeSearch:(UITapGestureRecognizer *)sender {
    if (![[BBTCurrentUserManager sharedCurrentUserManager] userIsActive]){
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"你还没有登录哟" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去登录"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             BBTLoginViewController *loginViewController = [[BBTLoginViewController alloc] init];
                                                             UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                                                             [self presentViewController:navigationController animated:YES completion:nil];
                                                             
                                                         }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tools" bundle:nil];
    BBTScoresTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"BBTScores"];
    NSDictionary *account =@{@"account":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                             @"password":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.password
                             };
    controller.userInfo = [[NSMutableDictionary alloc] initWithDictionary:account];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:controller] animated:YES completion:nil];
}

- (IBAction)TapToRoomSearch:(UITapGestureRecognizer *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tools" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"BBTRoomSearch"];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:controller] animated:YES completion:nil];
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

- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        // 分页控件
        _pageControl = [[UIPageControl alloc] init];
        // 总页数
        _pageControl.numberOfPages =(self.clubArray.count+self.infoArray.count);
        // 控件尺寸
        CGSize size = [_pageControl sizeForNumberOfPages:(self.clubArray.count+self.infoArray.count)];
        
        _pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
        _pageControl.center = CGPointMake((self._scrollerView.bounds.size.width-size.width-5), self._scrollerView.bounds.size.height-10);
        
        // 设置颜色
        _pageControl.pageIndicatorTintColor = [UIColor BBTLightGray];
        _pageControl.currentPageIndicatorTintColor = [UIColor BBTAppGlobalBlue];
        
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
    //NSLog(@"%ld", (long)page.currentPage);
    
    // 根据页数，调整滚动视图中的图片位置 contentOffset
    CGFloat x = page.currentPage * self._scrollerView.bounds.size.width;
    [self._scrollerView setContentOffset:CGPointMake(x, 0) animated:YES];
}

-(void)labelstyle1:(UILabel*)label
{
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Arial" size:12];
    label.numberOfLines = 1;
}
-(void)labelstyle2:(UILabel*)label
{
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Arial" size:25];
    label.numberOfLines = 1;
}
-(void)labelstyle3:(UILabel*)label
{
    
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Arial" size:14];
    label.numberOfLines = 1;
    
}


-(void)loadData
{
    //头图四个label设置
    self.picture_1.image = [UIImage imageNamed:@"author"];
    self.picture_1.contentMode = UIViewContentModeScaleToFill;
    self.picture_2.image = [UIImage imageNamed:@"shortline"];
    self.picture_2.contentMode = UIViewContentModeScaleToFill;
    self.picture_3.image = [UIImage imageNamed:@"vieweye"];
    self.picture_3.contentMode = UIViewContentModeScaleToFill;
    [self labelstyle2:self.articleInfo];
    [self labelstyle1:self.personInfo];
    [self labelstyle1:self.numberInfo];
    [self labelstyle3:self.infoType];
    
    AFHTTPSessionManager *manager_2 = [AFHTTPSessionManager manager];
    [manager_2 GET:getclub parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.club_all = responseObject;
        
        //NSLog(@"%@",self.club_all);
        //NSLog(@"%@",self.club_all[@"data"][@"introduction"]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        
        NSLog(@"%@",error);
        
    }];

    
    AFHTTPSessionManager *manager_1 = [AFHTTPSessionManager manager];
    [manager_1 GET:getinfo parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.info_all = responseObject;
        //NSLog(@"%@",self.info_all);
        NSLog(@"%@",[self.info_all[@"data"][0][@"content"] objectForKey:@"article"]);
        //NSLog(@"%@",self.info_all[@"data"][0][@"id"]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        
        NSLog(@"%@",error);
    }];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:baseURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@",responseObject);
        self.GetArray = responseObject;
        //NSLog(@"%@",self.GetArray[1][0][@"content"][@"picture"]);
        //NSLog(@"%lu",(unsigned long)self.GetArray.count);
        //NSLog(@"%@",self.GetArray[0][0][@"id"]);
        
        //分双数组操作
        self.clubArray = self.GetArray[0];
        NSLog(@"%@",self.clubArray[0][@"id"]);
        self.infoArray = self.GetArray[1];
        
        for (int i = 0; i < self.clubArray.count; i++)
       {
            //头图
           
            UIImageView *imaView = [[UIImageView alloc] initWithFrame:CGRectMake((i*self._scrollerView.bounds.size.width),0, self._scrollerView.bounds.size.width, self._scrollerView.bounds.size.height)];
           
           //添加tag以及tap手势
           imaView.tag = i;
           imaView.userInteractionEnabled = YES;
           UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
           [imaView addGestureRecognizer:singleTap];
           
            NSString *URL =[NSString stringWithFormat:@"%@", self.clubArray[i][@"content"][@"picture"]];
            [imaView sd_setImageWithURL:[NSURL URLWithString:URL]];
            [self._scrollerView addSubview:imaView];
           //由于头图的标题等都是在scrollervie监听中，进去加载的第一个scroller页面无法加载，所以在此先行加载（暂时未想到更好的方法） 之后记得优化一下！！
           self.articleInfo.text = [NSString stringWithFormat:@"%@",self.clubArray[0][@"title"]];
           self.personInfo.text = [NSString stringWithFormat:@"%@",self.clubArray[0][@"content"][@"author"]];
           self.numberInfo.text =@"776";
           self.infoType.text = [NSString stringWithFormat:@"活动"];
        }
        for (int i = 0 ; i < self.infoArray.count; i++)
        {
            
            UIImageView *imaView = [[UIImageView alloc] initWithFrame:CGRectMake(((i+self.clubArray.count)*self._scrollerView.bounds.size.width), 0,self._scrollerView.bounds.size.width,self._scrollerView.bounds.size.height)];
            
            //添加tag以及tap手势
            imaView.tag = (i+self.clubArray.count);
            imaView.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [imaView addGestureRecognizer:singleTap];
            
            NSString *URL =[NSString stringWithFormat:@"%@", self.infoArray[i][@"content"][@"picture"]];
            [imaView sd_setImageWithURL:[NSURL URLWithString:URL]];
            [self._scrollerView addSubview:imaView];
            
            
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
    unsigned long page = (self.pageControl.currentPage + 1) % (self.clubArray.count+self.infoArray.count);
    self.pageControl.currentPage = page;
    
    //NSLog(@"%ld", (long)self.pageControl.currentPage);
    // 调用监听方法，让滚动视图滚动
    [self pageChanged:self.pageControl];
    //NSLog(@"%ld",(long)self.pageControl.currentPage);
    [self ArrangeData:self.pageControl];
    
}

#pragma mark - ScrollView的代理方法
// 滚动视图停下来，修改页面控件的小点（页数）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 停下来的当前页数
    //NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    
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
    //NSLog(@"%s", __func__);
    // 停止时钟，停止之后就不能再使用，如果要启用时钟，需要重新实例化
    [self.timer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"%s", __func__);
    [self startTimer];
}

-(void)ArrangeData:(UIPageControl *)page
{
    //NSLog(@"%ld",(long)self.pageControl.currentPage);
    if((page.currentPage) < (self.clubArray.count))
    {
        self.articleInfo.text = [NSString stringWithFormat:@"%@",self.clubArray[page.currentPage][@"title"]];
        self.personInfo.text = [NSString stringWithFormat:@"%@",self.clubArray[page.currentPage][@"content"][@"author"]];
        self.numberInfo.text =@"776";
        self.infoType.text = [NSString stringWithFormat:@"活动"];
        
        
    }
    if(!((page.currentPage) < (self.clubArray.count)))
    {
        self.articleInfo.text = [NSString stringWithFormat:@"%@",self.infoArray[page.currentPage-self.clubArray.count][@"title"]];
        self.personInfo.text = [NSString stringWithFormat:@"%@",self.infoArray[page.currentPage-self.clubArray.count][@"content"][@"author"]];
        self.numberInfo.text = @"527";
        self.infoType.text = [NSString stringWithFormat:@"资讯"];
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView*touchView = gestureRecognizer.view;
    NSLog(@"%ld",(long)touchView.tag);
    if(touchView.tag < self.clubArray.count)
    {
        //前往self.clubArray[touchView.tag]那个资讯的详情页
        int infoNum = 0;
        int intString = [[self.clubArray[touchView.tag][@"content"] objectForKey:@"article_id"] intValue];
        for(int i = 0 ; i <self.clubArray.count ;i++)
        {
            NSLog(@"%@",[self.club_all[@"data"][i][@"content"] objectForKey:@"article"]);
            int intString_all =[self.club_all[@"data"][i][@"id"] intValue];
            if(intString_all == intString)
            {
                infoNum = i;
            }
        }

        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [webView loadHTMLString:self.club_all[@"data"][infoNum][@"introduction"] baseURL:nil];
        UIView * littleview = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, 50)];
        littleview.backgroundColor = [UIColor colorWithRed:80.0f/255.0f green:234.0f/255.0f blue:255.0f/255.0f alpha:1.0];
        
        UIViewController* InfoView = [[UIViewController alloc]init];
        [InfoView.view addSubview:webView];
        [InfoView.view addSubview:littleview];
        UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 20)];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        backButton.titleLabel.font  = [UIFont systemFontOfSize: 15];
        
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [InfoView.view addSubview:backButton];
        
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIViewController *topRootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
            // 在这里加一个这个样式的循环
        while (topRootViewController.presentedViewController)
        { // 这里固定写法
            topRootViewController = topRootViewController.presentedViewController; }
            // 然后再进行present操作
        [topRootViewController presentViewController:InfoView animated:YES completion:nil];
        
        
          
        
    }else{
        
       //前往self.infoArray[touchView.tag-self.clubArray.count]那个资讯的详情页
        int infoNum = 0;
        int intString = [[self.infoArray[touchView.tag-self.clubArray.count][@"content"] objectForKey:@"article_id"] intValue];
        for(int i = 0 ; i <self.infoArray.count ;i++)
        {
            NSLog(@"%@",[self.info_all[@"data"][i][@"content"] objectForKey:@"article"]);
            int intString_all =[self.info_all[@"data"][i][@"id"] intValue];
            if(intString_all == intString)
            {
                infoNum = i;
            }
        }
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
        [webView loadHTMLString:self.info_all[@"data"][infoNum][@"content"][@"article"] baseURL:nil];
        UIView * littleview = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, 50)];
        littleview.backgroundColor = [UIColor colorWithRed:80.0f/255.0f green:234.0f/255.0f blue:255.0f/255.0f alpha:1.0];
        
        UIViewController* InfoView = [[UIViewController alloc]init];
        [InfoView.view addSubview:webView];
        [InfoView.view addSubview:littleview];
        UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 20)];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        backButton.titleLabel.font  = [UIFont systemFontOfSize: 15];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [InfoView.view addSubview:backButton];
        
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIViewController *topRootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
        // 在这里加一个这个样式的循环
        while (topRootViewController.presentedViewController)
        { // 这里固定写法
            topRootViewController = topRootViewController.presentedViewController; }
        // 然后再进行present操作
        [topRootViewController presentViewController:InfoView animated:YES completion:nil];
        
    }
        
}
- (void)backButtonPressed:(id)sender{
    
[self dismissViewControllerAnimated:true completion:^{
        //返回后执行的事件；
}];
}
@end
