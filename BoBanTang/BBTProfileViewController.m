//
//  BBTProfileViewController.m
//  波板糖
//
//  Created by Authority on 2017/9/15.
//  Copyright © 2017年 100steps. All rights reserved.
//

#import "BBTProfileViewController.h"
#import "BBTCurrentUserManager.h"
#import "BBTUser.h"
#import <JGProgressHUD.h>

@interface BBTProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *StudentNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *gradeTextField;
@property (weak, nonatomic) IBOutlet UITextField *collegeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *dormitoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *qqTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;



@end

@implementation BBTProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateCurrentUserInformationFinish:) name:@"UpdateCurrentUserInformationFinish" object:nil];

    BBTUser * user = [BBTCurrentUserManager sharedCurrentUserManager].currentUser;
    self.NameLabel.text = user.name;
    
    if ([user.sex isEqualToNumber:@0]) {
        self.sexTextField.text = @"男";
    }
    else if ([user.sex isEqualToNumber:@1]){
        self.sexTextField.text = @"女";
    }
    
    self.StudentNumberLabel.text = user.account;
    self.gradeTextField.text = [NSString stringWithFormat:@"%@",!isNull(user.grade)?user.grade:@""];
    self.collegeTextField.text = [NSString stringWithFormat:@"%@",!isNull(user.college)?user.college:@""];
    self.phoneTextField.text = [NSString stringWithFormat:@"%@",!isNull(user.phone)?user.phone:@""];
    self.dormitoryTextField.text = [NSString stringWithFormat:@"%@",!isNull(user.dormitory)?user.dormitory:@""];
    self.qqTextField.text = [NSString stringWithFormat:@"%@",!isNull(user.qq)?user.qq:@""];
    
}

- (IBAction)editBtnIsTapped:(UIButton *)sender {
    if(self.sexTextField.enabled == NO){
        self.sexTextField.enabled = YES;
        self.gradeTextField.enabled = YES;
        self.collegeTextField.enabled = YES;
        self.phoneTextField.enabled = YES;
        self.dormitoryTextField.enabled = YES;
        self.qqTextField.enabled = YES;
        self.confirmBtn.enabled = YES;
    }
    
}

- (IBAction)confirmBtnIsTapped:(UIButton *)sender {
    self.sexTextField.enabled = NO;
    self.gradeTextField.enabled = NO;
    self.collegeTextField.enabled = NO;
    self.phoneTextField.enabled = NO;
    self.dormitoryTextField.enabled = NO;
    self.qqTextField.enabled = NO;
    self.confirmBtn.enabled = NO;
    
    self.view.userInteractionEnabled = NO;
    
    NSDictionary *parameters = @{
                                 @"grade":[NSNumber numberWithInteger:(self.gradeTextField.text.intValue)],
                                 @"college":self.collegeTextField.text,
                                 @"phone":self.phoneTextField.text,
                                 @"dormitory":self.dormitoryTextField.text,
                                 @"qq":self.qqTextField.text,
                                 };
    
    BBTUser *currentUser = [BBTCurrentUserManager sharedCurrentUserManager].currentUser;
    NSDictionary *currentUserDictionary = [currentUser toDictionary];
    
    NSMutableDictionary *changedParam = [NSMutableDictionary dictionaryWithCapacity:7];
    
    for (NSString *keyName in [parameters allKeys]) {
        if ([[currentUserDictionary allKeys] containsObject:keyName]){
            if (![currentUserDictionary[keyName] isEqual:parameters[keyName]]){
                changedParam[keyName] = parameters[keyName];
            }
        }
    }
    [[BBTCurrentUserManager sharedCurrentUserManager] updateUserInformationThroughPathMethodWith:changedParam.copy];
}

- (void)UpdateCurrentUserInformationFinish:(NSNotification *)notification{
    
    BOOL isError = [notification.userInfo[@"status"] isEqual:@"fail"];
    self.view.userInteractionEnabled = YES;
    //通知用户
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = isError?@"修改信息失败":@"修改信息成功";
    HUD.indicatorView = isError?[[JGProgressHUDErrorIndicatorView alloc]init]:[[JGProgressHUDSuccessIndicatorView alloc] init];
    
    HUD.square = YES;
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:1.7];
    
    //Dismiss current VC 0.5 sec after HUD disappears.
    if (!isError){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else{
        self.confirmBtn.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
