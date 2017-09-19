//
//  ManualImportVC.m
//  timeTable1
//
//  Created by zzddn on 2017/8/30.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "ManualImportVC.h"
#import "ScheduleButton.h"
#import "ScheduleDateManager.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ManualImportVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIView *add,*shadowView;
    CGRect frameFirst,frameShow;
    CGFloat w0,chooseWeeksViewH;
    NSMutableArray *addNum,*tmpArr;
    NSArray *sortedArr;
    NSArray *weekArr,*beginTimeArr,*endTimeArr;
}
@end

@implementation ManualImportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    w0 = SCREEN_WIDTH/17;
    chooseWeeksViewH = w0*12.5+20;
    
    frameFirst = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, chooseWeeksViewH);
    frameShow = CGRectMake(0,SCREEN_HEIGHT-chooseWeeksViewH-64, SCREEN_WIDTH,chooseWeeksViewH);
    
    [self.weekCell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChooseWeeksView)]];
    [self.dayTimeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(createPickerView)]];
    [self.deleteCell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteCourse:)]];
    
    addNum = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",nil];
    weekArr = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日",nil];
    
    beginTimeArr = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",nil];
    endTimeArr = [NSArray arrayWithObjects:@"到1",@"到2",@"到3",@"到4",@"到5",@"到6",@"到7",@"到8",@"到9",@"到10",@"到11",@"到12",nil];
    
    UIButton *right;
    UIButton *left;
    if ([self.navigationItem.title isEqual:@"详细信息"]){
        right = [self createLeftOrRightBtnWithTitle:@"编辑"];
        left = [self createLeftOrRightBtnWithTitle:@"返回"];
        
        //把详细数据加载到页面上
        ScheduleDateManager * manager = [ScheduleDateManager sharedManager].mutCourseArray[self.tagValue];
        self.courseName.text = manager.courseName;
        self.teacher.text = manager.teacherName;
        self.classroom.text = manager.location;
        NSString *dayText = manager.day;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %@节",dayText,manager.dayTime];
        self.weekLabel.text = [NSString stringWithFormat:@"第%@周",manager.week];
        
        self.courseName.enabled =NO;
        self.teacher.enabled = NO;
        self.classroom.enabled = NO;
        self.weekCell.userInteractionEnabled =NO;
        self.dayTimeLabel.userInteractionEnabled = NO;
        
    }else{
        right = [self createLeftOrRightBtnWithTitle:@"完成"];
        left = [self createLeftOrRightBtnWithTitle:@"取消"];
    }
    
    [right addTarget:self action:@selector(completeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:right];
    
    
    [left addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:left];
}
- (void)deleteCourse:(UIButton *)sender{
    [[ScheduleDateManager sharedManager].mutCourseArray removeObjectAtIndex:self.tagValue];
    [[ScheduleDateManager sharedManager] writeToDatabase];
    [[ScheduleDateManager sharedManager] updateThePrivateScheduleToServerWithAccount:[ScheduleDateManager sharedManager].account];
    
    if ([self.delegate respondsToSelector:@selector(MISetDone)]){
        [self.delegate MISetDone];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancelBtnDidClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)completeBtnDidClick:(UIButton *)sender{
    if ([sender.titleLabel.text isEqual:@"编辑"]){
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        UIButton *button = self.navigationItem.leftBarButtonItem.customView;
        [button setTitle:@"取消" forState:UIControlStateNormal];
        self.courseName.enabled =YES;
        self.teacher.enabled = YES;
        self.classroom.enabled = YES;
        self.weekCell.userInteractionEnabled =YES;
        self.dayTimeLabel.userInteractionEnabled = YES;
        self.deleteCell.hidden = NO;
        return;
    }
    if (!([self checkTheLabelText:self.courseName.text] && [self checkTheLabelText:self.timeLabel.text] && [self checkTheLabelText:self.weekLabel.text])){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"失败" message:@"名称、节数、周数为必填" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    NSArray *timeArr = [self.timeLabel.text componentsSeparatedByString:@" "];
    NSString *weekStr = [self.weekLabel.text substringWithRange:NSMakeRange(1,self.weekLabel.text.length - 2)];
    NSString *dayTimeStr;
    if([(NSString *)timeArr[1] containsString:@"-"]){
        dayTimeStr = [timeArr[1] stringByReplacingOccurrencesOfString:@"节" withString:@""];
    }else{
        NSString *tmp = [[timeArr[1] stringByReplacingOccurrencesOfString:@"节" withString:@""] stringByReplacingOccurrencesOfString:@"第" withString:@""];
        dayTimeStr = [NSString stringWithFormat:@"%@-%@",tmp,tmp];
    }
    NSDictionary *dic = @{@"location":self.classroom.text,
                          @"day":timeArr[0],
                          @"week":weekStr,
                          @"teacherName":self.teacher.text,
                          @"dayTime":dayTimeStr,
                          @"weekStatus":@"0",
                          @"courseName":self.courseName.text
                          };
    if ([self.navigationItem.title isEqual:@"详细信息"]){
        ScheduleDateManager *manager = [ScheduleDateManager sharedManager].mutCourseArray[self.tagValue];
        [manager setValuesForKeysWithDictionary:dic];
        [[ScheduleDateManager sharedManager] writeToDatabase];
        [[ScheduleDateManager sharedManager] updateThePrivateScheduleToServerWithAccount:[ScheduleDateManager sharedManager].account];
    }else{
        [[ScheduleDateManager sharedManager] insertOnePieceWithDic:dic];
        ScheduleDateManager *tmpManager = [ScheduleDateManager new];
        [tmpManager setValuesForKeysWithDictionary:dic];
        [[ScheduleDateManager sharedManager].mutCourseArray addObject:tmpManager];
        [[ScheduleDateManager sharedManager] updateThePrivateScheduleToServerWithAccount:[ScheduleDateManager sharedManager].account];
    }
    if ([self.delegate respondsToSelector:@selector(MISetDone)]){
        [self.delegate MISetDone];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showChooseWeeksView{
    add = [[UIView alloc]initWithFrame:frameFirst];
    add.backgroundColor = [UIColor whiteColor];
    
    //添加左边取消按钮
    UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(w0, w0/2-5, 46, 30)];
    [left setTitle:@"取消" forState:UIControlStateNormal];
    [left setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:normal];
    left.titleLabel.font = [UIFont systemFontOfSize:15];
    [left addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    [add addSubview:left];
    
    //添加右边确定按钮
    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-w0-46, w0/2-5, 46, 30)];
    [right setTitle:@"确定" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:normal];
    right.titleLabel.font = [UIFont systemFontOfSize:15];
    [right addTarget:self action:@selector(addDone) forControlEvents:UIControlEventTouchUpInside];
    [add addSubview:right];
    
    //添加分割线
    UIView *dividingLine = [[UIView alloc]init];
    dividingLine.frame = CGRectMake(0, w0+20, SCREEN_WIDTH, 1);
    dividingLine.backgroundColor = [UIColor colorWithRed:221 / 255.0 green:221 / 255.0 blue:221 / 255.0 alpha:1];
    [add addSubview:dividingLine];
    
    for (int i=1; i<=5; i++){
        for(int j=1; j<=5; j++){
            
            ScheduleButton *btn = [ScheduleButton new];
            [btn weekBtnWithTitle:[NSString stringWithFormat:@"%d",(i-1)*5+j] andFrame:CGRectMake(w0+(j-1)*w0*3, w0+20+w0*3/4+(i-1)*w0*2, w0*3, w0*2)];
            [add addSubview:btn];
            [btn addTarget:self action:@selector(addNum:) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.tagValue != -1){
                tmpArr = [NSMutableArray array];
                ScheduleDateManager *manager = [ScheduleDateManager sharedManager].mutCourseArray[self.tagValue];
                NSArray *timeArr = [manager.week componentsSeparatedByString:@" "];
                for (NSString *string in timeArr) {
                    if ([string containsString:@"-"]){
                        NSArray<NSString *> *tmp = [string componentsSeparatedByString:@"-"];
                        for (int i=tmp[0].intValue; i<= tmp[1].intValue; i++){
                            [tmpArr addObject:[NSString stringWithFormat:@"%d",i]];
                        }
                    }else{
                            [tmpArr addObject:string];
                        }
                    }
            }else{
                tmpArr = addNum.mutableCopy;
            }
            if([tmpArr containsObject:btn.titleLabel.text]){
                    btn.selected = YES;
                    btn.backgroundColor = [UIColor colorWithRed:70/255.0 green:200/255.0 blue:60/255.0 alpha:1];
            }
        }
    }
    [self showAddZhou];
}
- (void)showAddZhou{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.classroom resignFirstResponder];
        [self.courseName resignFirstResponder];
        [self.teacher resignFirstResponder];
        
        //添加阴影遮罩
        shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.35];
        [self.view addSubview:shadowView];
        //添加点击手势
        [shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)]];
        
        //添加选择周数的页面，此时，add页面位于遮罩上面
        [self.view addSubview:add];
        
        //运行动画
        [add setFrame:frameShow];
    } completion:nil];
}
- (void)addDone{
    [shadowView removeFromSuperview];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [add setFrame:frameFirst];
    } completion:^(BOOL finished) {
        [add removeFromSuperview];
        addNum = tmpArr;
        sortedArr = [addNum sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1 intValue]>[obj2 intValue]){
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }];
        NSString *labelStr = [self changetype:sortedArr];
        self.weekLabel.text = [NSString stringWithFormat:@"第%@周",labelStr];
    }];
}

-(NSString*)changetype:(NSArray *)zhouArr{
    NSString *x,*y,*result = [NSString new];
    x = [zhouArr objectAtIndex:0];
    result = [result stringByAppendingString:[NSString stringWithFormat:@"%@",x]];
    for (int i = 0; i<zhouArr.count-1; i++) {
        
        if ([[zhouArr objectAtIndex:i+1]intValue] - [[zhouArr objectAtIndex:i]intValue] ==1) {
            y = [zhouArr objectAtIndex:i+1];
        }
        else{
            if ([[zhouArr objectAtIndex:i]intValue] == [x intValue]) {
                
                x = [zhouArr objectAtIndex:i+1];
                result = [result stringByAppendingString:[NSString stringWithFormat:@" %@",x]];
            }
            else{
                result = [result stringByAppendingString:[NSString stringWithFormat:@"-%@",y]];
                x = [zhouArr objectAtIndex:i+1];
                result = [result stringByAppendingString:[NSString stringWithFormat:@" %@",x]];
                
            }
        }
    }
    if (y!=nil && [y intValue]>[x intValue]) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"-%@",y]];
    }
    
    return result;
}

- (void)addNum:(UIButton *)btn{
    btn.selected = !btn.selected;
    if(btn.selected){
        btn.backgroundColor = [UIColor colorWithRed:70/255.0 green:200/255.0 blue:60/255.0 alpha:1];
        [tmpArr addObject:btn.titleLabel.text];
    }else{
        btn.backgroundColor = [UIColor whiteColor];
        if([tmpArr containsObject:btn.titleLabel.text]){
            [tmpArr removeObject:btn.titleLabel.text];
        }
    }
}

-(void)remove{
    [shadowView removeFromSuperview];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [add setFrame:frameFirst];
    }completion:^(BOOL finished){
        [add removeFromSuperview];
    }];
}

- (void)createPickerView{
    [self.classroom resignFirstResponder];
    [self.courseName resignFirstResponder];
    [self.teacher resignFirstResponder];
    
    //添加阴影遮罩
    shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    shadowView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.35];
    [self.view addSubview:shadowView];
    
    //添加点击手势
    [shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)]];
    
    //白色底面
    add = [[UIView alloc]initWithFrame:frameFirst];
    add.backgroundColor = [UIColor whiteColor];
    
    //初始化选择器
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, w0+20, SCREEN_WIDTH, chooseWeeksViewH-w0-20)];
    self.pickerView.delegate = self;
    self.pickerView.alpha = 1.0;
    [add addSubview:self.pickerView];
    
    //添加右边确定按钮
    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-w0-46, w0/2+5, 46, 30)];
    [right setTitle:@"确定" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:normal];
    right.titleLabel.font = [UIFont systemFontOfSize:16];
    [right addTarget:self action:@selector(addDone2) forControlEvents:UIControlEventTouchUpInside];
    [add addSubview:right];
    
    [self.view addSubview:add];
    
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [add setFrame:frameShow];
    } completion:^(BOOL finished) {
        if (self.timeLabel.text != nil && (![self.timeLabel.text isEqual:@""])){
            [self setPickerView:self.pickerView withInfo:self.timeLabel.text];
        }
    }];
}
- (void)setPickerView:(UIPickerView *)timePickerView withInfo:(NSString *)information{
    NSArray *infoArr = [information componentsSeparatedByString:@" "];
    [timePickerView selectRow:[weekArr indexOfObject:infoArr[0]] inComponent:0 animated:YES];
    NSString *timeInfo = infoArr[1];
    infoArr = [timeInfo componentsSeparatedByString:@"-"];
    if (infoArr.count == 1){
        NSScanner *scanner = [NSScanner scannerWithString:timeInfo];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
        int number;
        [scanner scanInt:&number];
        [timePickerView selectRow:number-1 inComponent:1 animated:YES];
        [timePickerView selectRow:number-1 inComponent:2 animated:YES];
    }else{
        NSString *endInfo = [infoArr[1] stringByReplacingOccurrencesOfString:@"节" withString:@""];
        [timePickerView selectRow:[beginTimeArr indexOfObject:infoArr[0]] inComponent:1 animated:YES];
        [timePickerView selectRow:[beginTimeArr indexOfObject:endInfo] inComponent:2 animated:YES];
    }
}
- (void)addDone2{
    if ([self.pickerView selectedRowInComponent:1] > [self.pickerView selectedRowInComponent:2]){
        return;
    }
    NSString *weekStr = weekArr[[self.pickerView selectedRowInComponent:0]];
    NSString *beginStr = beginTimeArr[[self.pickerView selectedRowInComponent:1]];
    NSString *endStr = [endTimeArr[[self.pickerView selectedRowInComponent:2]] substringFromIndex:1];
    NSString *labelStr;
    if ([beginStr isEqual:endStr]){
        labelStr = [NSString stringWithFormat:@"%@ 第%@节",weekStr,beginStr];
    }else{
        labelStr = [NSString stringWithFormat:@"%@ %@-%@节",weekStr,beginStr,endStr];
    }
    self.timeLabel.text = labelStr;
    [self remove];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return weekArr.count;
            break;
        case 1:
            return beginTimeArr.count;
            break;
        case 2:
            return endTimeArr.count;
            break;
        default:
            break;
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return weekArr[row];
            break;
        case 1:
            return beginTimeArr[row];
            break;
        case 2:
            return endTimeArr[row];
            break;
        default:
            break;
    }
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component != 0 && [pickerView selectedRowInComponent:2] < [pickerView selectedRowInComponent:1]){
        [pickerView selectRow:[pickerView selectedRowInComponent:1] inComponent:2 animated:YES];
    }
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
- (BOOL)checkTheLabelText:(NSString *)text{
    if ([text isEqual:@""] || text == nil){
        return NO;
    }
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
