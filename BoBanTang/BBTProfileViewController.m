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


@interface BBTProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *SexLabel;
@property (weak, nonatomic) IBOutlet UILabel *StudentNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *GradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *CollegeLabel;

@end

@implementation BBTProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[BBTCurrentUserManager sharedCurrentUserManager]fetchCurrentUserProfile];
    BBTUser * user = [BBTCurrentUserManager sharedCurrentUserManager].currentUser;
    self.NameLabel.text = [NSString stringWithFormat:@"姓名：%@",user.userName];
    if (user.sex == 0) {
        self.SexLabel.text = @"性别：男";
    }
    else if (user.sex == 1){
        self.SexLabel.text = @"性别：女";
    }
    else{
        self.SexLabel.text = @"性别：";
    }
    self.StudentNumberLabel.text = [NSString stringWithFormat:@"学号：%@", user.account];
    self.GradeLabel.text = [NSString stringWithFormat:@"年级：%@", user.grade];
    self.CollegeLabel.text = @"学院：";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
