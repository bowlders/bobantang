//
//  SegmentedControlViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/11/10.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <Masonry.h>
#import "BBTSegmentedControlViewController.h"
#import "BBTBusViewController.h"
#import "BBTSpecialRailwayLineTwoViewController.h"

@interface BBTSegmentedControlViewController ()

@property (strong, nonatomic) UIView            *       contentViewContainer;           //Acts as a view container
@property (strong, nonatomic) NSArray           *       contentViewControllers;         //Stores the content view controllers
@property (assign, nonatomic) NSUInteger                currentControllerIndex;         //Currently displayed view controller's index in the array

@end

@implementation BBTSegmentedControlViewController

- (void)viewDidLoad {
 
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    BBTBusViewController *campusBusVC = [[BBTBusViewController alloc] init];
    BBTSpecialRailwayLineTwoViewController *specRailVC = [[BBTSpecialRailwayLineTwoViewController alloc] init];
    
    self.contentViewControllers = @[
                                    campusBusVC,
                                    specRailVC
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
    [self.contentViewContainer addSubview:currentVC.view];
    [currentVC didMoveToParentViewController:self];
    /*
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
     */
}

- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    NSLog(@"index %ld is selected", (long)sender.selectedSegmentIndex);
    [self changeToViewController:sender.selectedSegmentIndex animated:NO];
}

- (void)changeToViewController:(NSUInteger)index animated:(BOOL)animated
{
    UIViewController *currentVC = self.contentViewControllers[self.currentControllerIndex];
    [currentVC willMoveToParentViewController:nil];
    [currentVC.view removeFromSuperview];
    [currentVC removeFromParentViewController];
    
    UIViewController *destinationVC = self.contentViewControllers[index];
    [self addChildViewController:destinationVC];
    destinationVC.view.frame = self.contentViewContainer.bounds;
    [self.contentViewContainer addSubview:destinationVC.view];
    [destinationVC didMoveToParentViewController:self];
    
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
