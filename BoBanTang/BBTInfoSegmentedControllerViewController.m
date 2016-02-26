//
//  BBTInfoSegmentedControllerViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTInfoSegmentedControllerViewController.h"
#import "BBTCampusInfoTableViewController.h"
#import "BBTDailyArticleViewController.h"
#import "UIColor+BBTColor.h"
#import <Masonry.h>

@interface BBTInfoSegmentedControllerViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl   *          segmentedControl;
@property (strong, nonatomic) UIView                        *          contentViewContainer;
@property (strong, nonatomic) NSArray                       *          contentViewControllers;
@property (assign, nonatomic) NSUInteger                               currentControllerIndex;

@end

@implementation BBTInfoSegmentedControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    BBTCampusInfoTableViewController * campusInfoVC = [[BBTCampusInfoTableViewController alloc] init];
    
    BBTDailyArticleViewController * dailyArticleVC = [[BBTDailyArticleViewController alloc] init];
    
    self.contentViewControllers = @[
                                    campusInfoVC,
                                    dailyArticleVC
                                    ];
    
    self.contentViewContainer = [UIView new];
    self.contentViewContainer.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.contentViewContainer];
    
    [self.contentViewContainer mas_makeConstraints:^(MASConstraintMaker *make){
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];

    self.currentControllerIndex = 0;
    UIViewController *currentVC = self.contentViewControllers[self.currentControllerIndex];
    
    [self addChildViewController:currentVC];
    currentVC.view.frame = self.contentViewContainer.bounds;
    [self.contentViewContainer addSubview:currentVC.view];
    [currentVC didMoveToParentViewController:self];

    // Do any additional setup after loading the view.
}
- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    NSLog(@"Index %ld is selected", (long)sender.selectedSegmentIndex);
    [self changeToViewControllerAtIndex:sender.selectedSegmentIndex animated:NO];
}
 
- (void)changeToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    UIViewController *currentVC = self.contentViewControllers[self.currentControllerIndex];

    [currentVC willMoveToParentViewController:self];
    [currentVC.view removeFromSuperview];
    [currentVC removeFromParentViewController];

    UIViewController *destinationVC = self.contentViewControllers[index];

    [self addChildViewController:destinationVC];
    destinationVC.view.frame = self.contentViewContainer.bounds;
    [self.contentViewContainer addSubview:destinationVC.view];
    [destinationVC didMoveToParentViewController:self];
    [self addChildViewController:destinationVC];
    
    self.currentControllerIndex = index;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
