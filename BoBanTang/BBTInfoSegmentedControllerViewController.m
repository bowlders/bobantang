//
//  BBTInfoSegmentedControllerViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTInfoSegmentedControllerViewController.h"
#import "BBTCampusInfoTableViewController.h"
#import "BBTDailyArticleTableViewController.h"
#import "UIColor+BBTColor.h"
#import <HMSegmentedControl.h>
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
    
    /*
    //Add segmented Controller
    self.segmentedControl = [[UISegmentedControl alloc] initWithSectionTitles:@[@"校内资讯", @"每日一文"]];
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat segmentedControlHeight = 44.0;
    CGFloat segmentedControlY = navigationBarHeight + statusBarHeight;
    CGFloat segmentedControlWidth = CGRectGetWidth(self.view.frame);
    CGRect segmentedFrame = CGRectMake(0.0, segmentedControlY, segmentedControlWidth, segmentedControlHeight);
    self.segmentedControl.frame = segmentedFrame;
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorColor = [UIColor BBTInfoSegmentedControlIndicatorBlue];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:self.segmentedControl];
     */
    
    BBTCampusInfoTableViewController * campusInfoVC = [[BBTCampusInfoTableViewController alloc] init];
    BBTDailyArticleTableViewController * dailyArticleVC = [[BBTDailyArticleTableViewController alloc] init];
    
    self.contentViewControllers = @[
                                    campusInfoVC,
                                    dailyArticleVC
                                    ];
    
    self.contentViewContainer = [UIView new];
    self.contentViewContainer.backgroundColor = [UIColor whiteColor];
    
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat segmentedControlY = self.segmentedControl.frame.origin.y;
    CGFloat segmentedControlHeight = CGRectGetHeight(self.segmentedControl.frame);
    CGFloat containerY = segmentedControlY + segmentedControlHeight;
    CGFloat containerWidth = CGRectGetWidth(self.view.frame);
    CGFloat containerHeight = CGRectGetHeight(self.view.frame) - navigationBarHeight - statusBarHeight - segmentedControlHeight;
    CGRect containerFrame = CGRectMake(0.0f, containerY, containerWidth, containerHeight);
    self.contentViewContainer.frame = containerFrame;
    [self.view addSubview:self.contentViewContainer];
    
    self.currentControllerIndex = 0;
    UIViewController *currentVC = self.contentViewControllers[self.currentControllerIndex];
    
    [self addChildViewController:currentVC];
    [self.contentViewContainer addSubview:currentVC.view];
    [currentVC didMoveToParentViewController:self];

    
    // Do any additional setup after loading the view.
}
- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    NSLog(@"Index %ld is selected", (long)sender.selectedSegmentIndex);
    [self changeToViewControllerAtIndex:sender.selectedSegmentIndex animated:NO];
}

/*
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    NSLog(@"Index %ld is selected", (long)segmentedControl.selectedSegmentIndex);
    [self changeToViewControllerAtIndex:segmentedControl.selectedSegmentIndex animated:NO];
}
*/
 
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
