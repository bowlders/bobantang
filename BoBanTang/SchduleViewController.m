//
//  ViewController.m
//  timeTable1
//
//  Created by zzddn on 2017/8/22.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "ScheduleViewController.h"
#import <AFHTTPSessionManager.h>
#import "TableTextField.h"
#import "ScheduleButton.h"
#import "BBTScheduleDateLocalManager.h"
#import "OITableViewController.h"
#import "ManualImportVC.h"
#import "FloatingWindow.h"
//#import "ManualImportTable.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ScheduleViewController ()<OIDelegate,MIProtocol>
{
    CGFloat colHeight,fieldW,fieldH;
    BOOL showWeekChoice;
    CGRect memuFrame0,memuFrame;
    UIScrollView *memuView;
    UIView *backgroundView,*shadowView;
    NSInteger currentShowWeek;
    NSMutableArray *colorArr;
    UIImageView *moreImageView;
    FloatingWindow *floatWindow;
}
@property (nonatomic,strong) NSMutableArray *btnArr;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSArray *topBtnArr;
@end

@implementation ScheduleViewController

- (NSMutableArray *)btnArr{
    if (_btnArr == nil){
        _btnArr = [NSMutableArray arrayWithCapacity:84];
    }
    return _btnArr;
}
- (UIScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        CGRect frame = CGRectMake(0, 64+fieldH, SCREEN_WIDTH, SCREEN_HEIGHT-64-fieldH);
        _scrollView = [[UIScrollView alloc]initWithFrame:frame];
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)loadTopTitle{
    _topTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    [_topTitle setFrame:CGRectMake(0, 0, 120, 20)];
    
    //设置标题
    _topTitle.titleLabel.textAlignment = NSTextAlignmentRight;
    [_topTitle setTitle:@"课程表第1周" forState:UIControlStateNormal];
    _topTitle.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [_topTitle.titleLabel setFrame:CGRectMake(0, 0, 105, 20)];
    [_topTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //设置下箭头图片
    CGFloat labelWidth = _topTitle.titleLabel.bounds.size.width;
    CGFloat labelHeight = _topTitle.titleLabel.bounds.size.height;
    moreImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"more"]];
    [moreImageView setFrame:CGRectMake(labelWidth+6, labelHeight/4.0*2, 15.294, 7.647)];
    [_topTitle addSubview:moreImageView];
    
    self.navigationItem.titleView = self.topTitle;
    [self.topTitle addTarget:self action:@selector(chooseWeek:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置whitehome
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeBtn setImage:[UIImage imageNamed:@"whitehome"] forState:UIControlStateNormal];
    [homeBtn setFrame:CGRectMake(0, 0, 26, 26)];
    [homeBtn addTarget:self action:@selector(homeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *homeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
    [homeView addSubview:homeBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:homeView];
}
- (void)viewWillAppear:(BOOL)animated{

    if ([BBTScheduleDateLocalManager shardLocalManager].mutCourses == nil){
        [[BBTScheduleDateLocalManager shardLocalManager] fetchCurrentWeek];
    }
}

#pragma mark -- 目前回去首页用的是这个，需要可以改动
- (void)homeBtnDidClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initColor];
    [self createRow];
    [self createColumn];
    [self createScheduleButtons];
    [self createRightBtn];
    showWeekChoice = NO;
    
    [self loadTopTitle];
    
    //先从本地获取当前周,没有本地周数信息的话就默认设置为周一
    BBTScheduleDateLocalManager *localManager = [BBTScheduleDateLocalManager shardLocalManager];
    currentShowWeek = localManager.currentWeek.integerValue;
    //NSLog(@"%@",[NSString stringWithFormat:@"课程表第%@周",localManager.currentWeek]);
    [self.topTitle setTitle:[NSString stringWithFormat:@"课程表第%@周",localManager.currentWeek] forState:UIControlStateNormal];
     
    //获取本地课表
    localManager.mutCourses = [localManager fetchThePrivateScheduleFromDatabase];
    if(localManager.mutCourses && localManager.mutCourses.count != 0){
        [self updateNow];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dealWithRawRecommendScheduleData:) name:@"ThegetScheduleGet" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dealWithRawRecommendScheduleData:) name:@"ThegetScheduleFailed" object:nil];
    
    //获取服务器上的当前周数，同时，不论失败成功，都会去获取一次服务器上的个人课表,但事件流为：先完成周数的获取，然后再去获取更新课表，最后发送通知
    //这样做的理由是，一、课表展示对周数有依赖。二、为了解决两次请求的等待时间过长，所以先进行本地周数、本地课表的展示，最后获取数据后再刷新，从而给一个较好的用户体验
    [[BBTScheduleDateLocalManager shardLocalManager] fetchCurrentWeek];
}

- (void)dealWithRawRecommendScheduleData:(NSNotification *)noti{
    BBTScheduleDateLocalManager *localManger = [BBTScheduleDateLocalManager shardLocalManager];
    [localManger updateLocalScheduleWithNoti:noti.name];
    //更新一下最新的当前周数
    if (localManger.currentWeek != nil){
        [self.topTitle setTitle:[NSString stringWithFormat:@"课程表第%ld周",(long)localManger.currentWeek.integerValue] forState:UIControlStateNormal];
        currentShowWeek = localManger.currentWeek.integerValue;
    }
    [self updateNow];
}

- (void)createRightBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"adding"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 35.0/1.7, 35.0/1.7)];
    [btn addTarget:self action:@selector(addBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35.0/1.7, 35.0/1.7)];
    [btnView addSubview:btn];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc]initWithCustomView:btnView];
    self.navigationItem.rightBarButtonItem = btnItem;
}

- (void)addBtnDidClick:(UIButton *)sender{
    
    //添加阴影遮罩
    shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    shadowView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.35];
    [[[UIApplication sharedApplication] keyWindow]addSubview:shadowView];
    
    //添加点击手势
    [shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)]];
    
    floatWindow = [[FloatingWindow alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-100, (SCREEN_WIDTH-80)/1.33)];
    [floatWindow setCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)];
    [[[UIApplication sharedApplication] keyWindow]addSubview:floatWindow];
    [self shakeToShow:floatWindow];
    
    __weak ScheduleViewController *wself = self;
    floatWindow.block = ^(UIButton *btn){
        if ([btn.titleLabel.text isEqual:@"教务导课"]){
            OITableViewController *OITVC = [OITableViewController new];
            OITVC.delegate = wself;
            [wself.navigationController pushViewController:OITVC animated:YES];
        }else if ([btn.titleLabel.text isEqual:@"手动导课"]){
            //ManualImportTable *table = [ManualImportTable new];
            //[wself.navigationController pushViewController:table animated:YES];
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"Schedule" bundle:[NSBundle mainBundle]];
            ManualImportVC *manualImportVC = [board instantiateViewControllerWithIdentifier:@"ManualImport"];
            manualImportVC.delegate = wself;
            manualImportVC.navigationItem.title = @"手动导课";
            manualImportVC.tagValue = -1;
            [wself.navigationController pushViewController:manualImportVC animated:YES];
        }else if ([btn.titleLabel.text isEqual:@"删除所有课程"]){
            UIAlertController *deleteController = [UIAlertController alertControllerWithTitle:@"你确定要删除所有课程吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[BBTScheduleDateLocalManager shardLocalManager] deleteAllCourses];
                [wself updateNow];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [deleteController addAction:confirmAction];
            [deleteController addAction:cancelAction];
            
            [wself presentViewController:deleteController animated:YES completion:nil];
        }
        [wself remove];
    };
}
- (void)createScheduleButtons{
    for (int x=1; x<=7; x++){
        for (int y=1; y<=11; y++){
            ScheduleButton *btn = [ScheduleButton buttonWithType:UIButtonTypeRoundedRect];
            CGRect frame = CGRectMake(x*(fieldW-0.5)-0.5, (y-1)*(colHeight-0.5)-0.5, fieldW, colHeight);
            [btn setTitle:@"" andFrame:frame];
            [btn setTag:x+7*(y-1)];
            //btn.backgroundColor = colorArr[btn.tag%colorArr.count];
            [self.btnArr addObject:btn];
            [self.scrollView addSubview:btn];
        }
    }
}

- (void)createColumn{
    colHeight = fieldW *130.0f/85.0f+0.4545f;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, fieldW *130.0f/85.0f*11);
    CGFloat y = 0;
    for (int i=0; i<11; i++)
    {
        y = y-0.5;
        TableTextField *textField = [[TableTextField alloc]initWithText:[NSString stringWithFormat:@"%d",i+1] andFrame:CGRectMake(0, y, SCREEN_WIDTH/8.0, colHeight)];
        if (SCREEN_WIDTH>320){
            textField.font = [UIFont fontWithName:@"Arial" size:16.0f];
        }else{
            textField.font = [UIFont fontWithName:@"Arial" size:14.0f];
        }
        y = y+colHeight;
        [self.scrollView addSubview:textField];
    }
}
- (void)createRow{
    NSArray *weekArr = [NSArray arrayWithObjects:@"",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日",nil];
    NSInteger weekIndex = [weekArr indexOfObject:[BBTScheduleDateLocalManager shardLocalManager].whichDay];
    CGFloat x0 = 0;
    fieldW = SCREEN_WIDTH/8.0+0.4375;
    fieldH = fieldW*97.0/85.0;
    
    for (int i=0; i<8; i++){
        x0= x0-0.5;
        TableTextField *field = [[TableTextField alloc]initWithText:[weekArr objectAtIndex:i] andFrame:CGRectMake(x0, 64, fieldW, fieldH)];
        if (i == weekIndex){
            field.backgroundColor = [UIColor colorWithRed:152.0/255.0 green:228.0/255.0 blue:241.0/255.0 alpha:0.5];
        }
        if (SCREEN_WIDTH>320){
            field.font = [UIFont fontWithName:@"Arial" size:15.0f];
        }
        else{
            field.font = [UIFont fontWithName:@"Arial" size:13.0f];
        }
        x0 = x0+fieldW;
        [self.view addSubview:field];
    }
}

- (void)MISetDone{

    [self updateNow];
}
- (void)updateScheduleView{
  
    [self updateNow];
}

- (ScheduleButton *)addTopBtnWithRow:(NSInteger)row andCol:(NSInteger)col andCount:(NSInteger)count andCourseName:(NSString *)courseName{
    ScheduleButton *button = [ScheduleButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *bottomBtn = self.btnArr[row+11*(col-1)-1];
    [button topBtnWithTitle:courseName andFrame:CGRectMake(bottomBtn.frame.origin.x, bottomBtn.frame.origin.y, fieldW, colHeight*count-0.5*(count-1))];
    button.backgroundColor = colorArr[(row+11*(col-1))%colorArr.count];
    [self.scrollView addSubview:button];
    return button;
}

- (void)updateNow{
    //更新的逻辑为，如果已经有了上层的按钮，那么就一次性清除全部，再重新添加
    if (_topBtnArr != nil){
        for (ScheduleButton *button in _topBtnArr) {
            [button removeFromSuperview];
        }
    }
    
    NSMutableArray<BBTScheduleDate *> *mutCouses = [self coursesInCurrentWeek];
    NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:mutCouses.count];
    
    for (BBTScheduleDate *singleData in mutCouses) {
        NSArray *dayArr = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日",nil];
        NSInteger dayInt = [dayArr indexOfObject:singleData.day]+1;
        NSArray *timeArray = [singleData.dayTime componentsSeparatedByString:@"-"];
        NSInteger beginTime = ((NSString *)timeArray[0]).integerValue;
        NSInteger endTime = ((NSString *)timeArray[1]).integerValue;
        
        ScheduleButton *button = [self addTopBtnWithRow:beginTime andCol:dayInt andCount:endTime-beginTime+1 andCourseName:[NSString stringWithFormat:@"%@@%@",singleData.courseName,singleData.location]];
        [button addTarget:self action:@selector(topBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = [[BBTScheduleDateLocalManager shardLocalManager].mutCourses indexOfObject:singleData];
        [mutArr addObject:button];
    }
    self.topBtnArr = mutArr;
}

- (void)topBtnDidClick:(UIButton *)sender{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Schedule" bundle:[NSBundle mainBundle]];
    ManualImportVC *manualImportVC = [board instantiateViewControllerWithIdentifier:@"ManualImport"];
    manualImportVC.delegate = self;
    manualImportVC.tagValue = sender.tag;
    manualImportVC.navigationItem.title = @"详细信息";
    [self.navigationController pushViewController:manualImportVC animated:YES];
}

- (void)chooseWeek:(UIButton *)sender {
    
    showWeekChoice = !showWeekChoice;
    if (showWeekChoice){
        moreImageView.transform = CGAffineTransformMakeRotation(M_PI);
        memuFrame0 = CGRectMake(SCREEN_WIDTH/3, 64, SCREEN_WIDTH/3, 0);
        memuFrame = CGRectMake(SCREEN_WIDTH/3, 64, SCREEN_WIDTH/3, SCREEN_WIDTH*3/4-11);
        [self createMemu];
        [UIView animateWithDuration:0.2 animations:^{
            backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTheBackground)]];
            [self.view addSubview:backgroundView];
            [self.view addSubview:memuView];
            memuView.frame = memuFrame;
        }];
    }else{
        moreImageView.transform = CGAffineTransformMakeRotation(0);
        [backgroundView removeFromSuperview];
        [UIView animateWithDuration:0.2 animations:^{
            memuView.frame = memuFrame0;
        }];
    }
}
- (void)createMemu{
    memuView = [[UIScrollView alloc]initWithFrame:memuFrame0];
    memuView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:180.0/255.0 blue:220.0/255.0 alpha:0.98];
    memuView.contentSize = CGSizeMake(SCREEN_WIDTH/3, 12+25*(SCREEN_WIDTH/12-2));
    for (int i = 1; i<=25; i++) {
        ScheduleButton *btn = [ScheduleButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setMemuTitle:[NSString stringWithFormat:@"课程表第%d周",i] andFrame:CGRectMake(0, 8+(i-1)*(SCREEN_WIDTH/12-2), SCREEN_WIDTH/3, SCREEN_WIDTH/12-2)];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(memuDidchoose:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [memuView addSubview:btn];
    }
}

- (void)tapTheBackground{
    moreImageView.transform = CGAffineTransformMakeRotation(0);
    showWeekChoice = !showWeekChoice;
    [backgroundView removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        memuView.frame = memuFrame0;
    }];
}

- (void)memuDidchoose:(UIButton *)btn{
    moreImageView.transform = CGAffineTransformMakeRotation(0);
    [self tapTheBackground];
    [self.topTitle setTitle:btn.titleLabel.text forState:UIControlStateNormal];
    currentShowWeek = btn.tag;
    
    [self updateNow];
}
-(void)initColor{
    
    colorArr = [NSMutableArray new];
    
    UIColor *blue2 = [UIColor colorWithRed:0.0/255 green:200.0/255 blue:255.0/255 alpha:0.5];
    [colorArr addObject:blue2];
    
    UIColor *blue3 = [UIColor colorWithRed:0.0/255 green:180.0/255 blue:210.0/255 alpha:0.5];
    [colorArr addObject:blue3];
    
    
    UIColor *blue4 = [UIColor colorWithRed:130.0/255 green:140.0/255 blue:255.0/255 alpha:0.5];
    [colorArr addObject:blue4];

    
    UIColor *blue1 = [UIColor colorWithRed:0.0/255.0 green:150.0/255.0 blue:255.0/255.0 alpha:0.5];
    [colorArr addObject:blue1];
    
    UIColor *blue5 = [UIColor colorWithRed:119.0/255.0 green:231.0/255.0 blue:242.0/255.0 alpha:0.5];
    [colorArr addObject:blue5];
    
    UIColor *blue6 = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:0.5];
    [colorArr addObject:blue6];
    
    UIColor *blue7 = [UIColor colorWithRed:0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    [colorArr addObject:blue7];

}
- (void)shakeToShow:(UIView *)view{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [view.layer addAnimation:animation forKey:nil];
}
- (void)remove{
    [shadowView removeFromSuperview];
    [floatWindow removeFromSuperview];
}
- (NSMutableArray<BBTScheduleDate *> *)coursesInCurrentWeek{
    
    NSMutableArray<BBTScheduleDate *> * returnCourses = [NSMutableArray array];
    
    NSString *weekStatusMark = currentShowWeek%2==0?@"2":@"1";
    
    for (BBTScheduleDate *singleCourse in [BBTScheduleDateLocalManager shardLocalManager].mutCourses) {
        if ([singleCourse.weekStatus isEqual:@"0"]||[singleCourse.weekStatus isEqual:weekStatusMark]){
            NSArray *timeArr = [singleCourse.week componentsSeparatedByString:@" "];
            for (NSString *string in timeArr) {
                if ([string containsString:@"-"]){
                    NSArray<NSString *> *tmp = [string componentsSeparatedByString:@"-"];
                    if(tmp[1].integerValue >= currentShowWeek && tmp[0].integerValue <= currentShowWeek){
                        [returnCourses addObject:singleCourse];
                    }
                }else{
                    if (currentShowWeek == string.integerValue){
                        [returnCourses addObject:singleCourse];
                    }
                }
            }
        }
    }
    
    return returnCourses;
}
@end
