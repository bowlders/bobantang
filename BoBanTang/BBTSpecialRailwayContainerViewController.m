//
//  BBTSpecialRailwayContainerViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/14.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTSpecialRailwayContainerViewController.h"
#import "BBTSouthSpecialRailwayTwoViewController.h"
#import "BBTNorthSpecialRailwayTwoViewController.h"
#import "BBTSpecRailway2BusManager.h"
#import <Masonry.h>
#import <AVOSCloud.h>

@interface BBTSpecialRailwayContainerViewController ()

@property (strong, nonatomic) UIView            *       contentViewContainer;           //Acts as a view container
@property (strong, nonatomic) NSArray           *       contentViewControllers;         //Stores the content view controllers
@property (assign, nonatomic) NSUInteger                currentControllerIndex;         //Currently displayed view controller's index in the array
@property (strong, nonatomic) UIButton          *       invertButton;
@property (strong, nonatomic) UIButton          *       refreshButton;

@end

@implementation BBTSpecialRailwayContainerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"ios_SpecialLine"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    BBTSouthSpecialRailwayTwoViewController *southRailVC = [[BBTSouthSpecialRailwayTwoViewController alloc] init];
    
    BBTNorthSpecialRailwayTwoViewController *northRailVC = [[BBTNorthSpecialRailwayTwoViewController alloc] init];
    
    self.contentViewControllers = @[
                                    southRailVC,
                                    northRailVC
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
    
    self.invertButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"invert"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(clickInvertButton)
         forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.numberOfLines = 1;
        button.titleLabel.textAlignment = NSTextAlignmentRight;
        button.titleLabel.adjustsFontSizeToFitWidth = NO;
        button.alpha = 1.0;
        button;
    });
    
    self.refreshButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(clickRefreshButton)
         forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.numberOfLines = 1;
        button.titleLabel.textAlignment = NSTextAlignmentRight;
        button.titleLabel.adjustsFontSizeToFitWidth = NO;
        button.alpha = 1.0;
        button;
    });
    
    [self.view addSubview:self.invertButton];
    [self.view addSubview:self.refreshButton];
    
    CGFloat buttonOffset = 10.0f;
    CGFloat buttonSideLength = 50.0f;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view.mas_right).offset(-buttonOffset);
        make.bottom.equalTo(self.view.mas_bottom).offset(- tabBarHeight - buttonOffset);
        make.width.equalTo(@(buttonSideLength));
        make.height.equalTo(@(buttonSideLength));
    }];
    
    [self.invertButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.refreshButton.mas_right);
        make.bottom.equalTo(self.refreshButton.mas_top).offset(-buttonOffset);
        make.width.equalTo(@(buttonSideLength));
        make.height.equalTo(@(buttonSideLength));
    }];
    
}

- (void)clickInvertButton
{
    NSUInteger targetVCIndex = (self.currentControllerIndex == 1) ? 0 : 1;
    [self changeToViewControllerAtIndex:targetVCIndex animated:NO];
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

- (void)clickRefreshButton
{
    [[BBTSpecRailway2BusManager sharedBusManager] refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"ios_SpecialLine"];
}

@end
