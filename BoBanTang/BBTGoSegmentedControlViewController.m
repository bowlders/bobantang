//
//  SegmentedControlViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/11/10.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTGoSegmentedControlViewController.h"
#import "BBTCampusBusViewController.h"
#import "BBTSpecialRailwayContainerViewController.h"
#import "BBTSouthSpecialRailwayTwoViewController.h"
#import "BBTAppDelegate.h"
#import <Masonry.h>
#import <KGModal.h>

@interface BBTGoSegmentedControlViewController ()

@property (strong, nonatomic) UIView            *       contentViewContainer;           //Acts as a view container
@property (strong, nonatomic) NSArray           *       contentViewControllers;         //Stores the content view controllers
@property (assign, nonatomic) NSUInteger                currentControllerIndex;         //Currently displayed view controller's index in the array

@end

@implementation BBTGoSegmentedControlViewController

- (void)viewDidLoad {
 
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    BBTCampusBusViewController *campusBusVC = [[BBTCampusBusViewController alloc] init];
    
    BBTSpecialRailwayContainerViewController *specRailVC = [[BBTSpecialRailwayContainerViewController alloc] init];
    
    self.contentViewControllers = @[
                                    campusBusVC,
                                    specRailVC
                                    ];
    
    self.contentViewContainer = [UIView new];
    self.contentViewContainer.backgroundColor = [UIColor whiteColor];
    self.contentViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    UIBarButtonItem *timeTableBarButton = [[UIBarButtonItem alloc]
                                           initWithImage:[UIImage imageNamed:@"clock"]
                                           style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(popUpTimeTable)];
    self.navigationItem.rightBarButtonItem = timeTableBarButton;
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
                                      
    self.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)backToHome
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    NSLog(@"index %ld is selected", (long)sender.selectedSegmentIndex);
    [self changeToViewControllerAtIndex:sender.selectedSegmentIndex animated:NO];
}

- (void)changeToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
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

- (void)popUpTimeTable
{
    UIImageView *timeTableImageView;
    if (!self.currentControllerIndex)
    {
        timeTableImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timetable_bus"]];
    }
    else
    {
        timeTableImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timetable_line"]];
    }
    [KGModal sharedInstance].modalBackgroundColor = [UIColor whiteColor];
    [[KGModal sharedInstance] showWithContentView:timeTableImageView andAnimated:YES];
}

@end
