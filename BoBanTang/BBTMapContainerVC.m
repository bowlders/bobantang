//
//  BBTMapViewController.m
//  bobantang
//
//  Created by Bill Bai on 8/26/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//
#import "BBTTilesourceDownloadVC.h"
#import "BBTMapViewController.h"
#import "BRSFlatMapViewController.h"
#import "BBT3DMapViewController.h"
#import "UIButton+ASANUserTrackingButton.h"
#import "UIColor+BBTColor.h"
#import "BBTTileSourceManager.h"
#import "BBTMapContainerVC.h"
#import <Masonry/Masonry.h>
#import "BBTRouteManagerView.h"
#import <AVOSCloud.h>

NSString *const kNorthCampusButtonTitle = @"N";
NSString *const kHEMCCampusButtonTitle = @"S";
NSString *const kFlatMapButtonTitle = @"2.5D";
NSString *const k3DMapButtonTitle = @"2.5D";

@interface BBTMapContainerVC() <UIAlertViewDelegate>
{
    BRSFlatMapViewController *_flatMapViewController;
    BBT3DMapViewController *_threeDMapViewController;
    int _campus;
    int _mapType;
}

@property (nonatomic, readwrite) CGRect buttonGroupRect;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIButton *campusbutton;
@property (strong, nonatomic) UIButton *mapTypeButton;
@property (strong, nonatomic) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIBarButtonItem *routeButton;

/* map view container, note this is only the  CONTAINER */
@property (strong, nonatomic) UIView *mapViewContainer;

/* search and display */
@property (nonatomic, strong) UISearchDisplayController *searchDisplayContrl;
@property (nonatomic, strong) UISearchBar *searchBar;

/* map view controller */
@property (weak, nonatomic) BBTMapViewController *mapViewController;

@property (strong, nonatomic)BBTRouteManagerView *routeManagerView;
- (IBAction)BackToHome:(UIButton *)sender;

@end


@implementation BBTMapContainerVC

#define MAP_TOOL_BAR_HEIGHT 44.0
- (void) loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    view.backgroundColor = [UIColor whiteColor];
    view.opaque = YES;
    self.view = view;
    
    //Set up container and its constraints
    self.mapViewContainer = ({
        UIView *mapViewContainer = [[UIView alloc] initWithFrame:appFrame];
        mapViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mapViewContainer;
    });
    [self.view addSubview:self.mapViewContainer];
    
    CGFloat buttonSize = 40.0f;
    CGFloat innerSpacing = 10.0f;
    CGFloat searchbarHeight = 20.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    //CGFloat navigationBarAndSearchBarHeight = self.navigationController.navigationBar.frame.size.height + searchbarHeight + 2 * innerSpacing;
    
    //set search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(2 * innerSpacing);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    //set buttons
    NSString *mapTypeButtonTitle = [BBTPreferences sharedInstance].flatMap ? kFlatMapButtonTitle : k3DMapButtonTitle;
    self.mapTypeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.mapTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mapTypeButton setTitle:mapTypeButtonTitle forState:UIControlStateNormal];
    [self.view addSubview:self.mapTypeButton];
    [self.mapTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight + 3.5 * innerSpacing);
        make.right.equalTo(self.view.mas_right).offset( - innerSpacing);
        make.width.equalTo(@(buttonSize));
        make.height.equalTo(@(buttonSize));
    }];
    [self.mapTypeButton addTarget:self action:@selector(mapTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *campusButtonTitle = [BBTPreferences sharedInstance].northCampus ? kNorthCampusButtonTitle : kHEMCCampusButtonTitle;
    self.campusbutton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.campusbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([campusButtonTitle isEqualToString:@"N"]) {
        [self.campusbutton setBackgroundImage:[UIImage imageNamed:@"校区-北校"] forState:UIControlStateNormal];
        _campus = 0;
    } else {
        [self.campusbutton setBackgroundImage:[UIImage imageNamed:@"校区-南校"] forState:UIControlStateNormal];
        _campus = 1;
    }
    [self.view addSubview:self.campusbutton];
    [self.campusbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapTypeButton.mas_bottom).offset(innerSpacing);
        make.right.equalTo(self.view.mas_right).offset( - innerSpacing);
        make.width.equalTo(@(buttonSize));
        make.height.equalTo(@(buttonSize));
    }];
    [self.campusbutton addTarget:self action:@selector(campusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.homeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.homeButton setBackgroundImage:[UIImage imageNamed:@"地标"] forState:UIControlStateNormal];
    [self.view addSubview:self.homeButton];
    [self.homeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.campusbutton.mas_bottom).offset(innerSpacing);
        make.right.equalTo(self.view.mas_right).offset( - innerSpacing);
        make.width.equalTo(@(buttonSize));
        make.height.equalTo(@(buttonSize));
    }];
    [self.homeButton addTarget:self action:@selector(homeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    self.searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"搜索"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(startSearch)];
    
    self.routeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(toogleDirectionFromDelegate)];
    
    NSArray *rightBarButtonItemsGroup = @[self.searchButton, self.routeButton];
    self.navigationItem.rightBarButtonItems = rightBarButtonItemsGroup;
   
    self.navigationItem.title = @"地图";
    
    /* search display controller */
    
    self.searchDisplayContrl = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBar.barTintColor = [UIColor BBTAppGlobalBlue];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    
    /* init map view controller  */
    _flatMapViewController = [[BRSFlatMapViewController alloc] init];
    _threeDMapViewController = [[BBT3DMapViewController alloc] init];
    _threeDMapViewController.mapContainerVC = self;
    [_flatMapViewController setContainerSearchDisplayController:self.searchDisplayContrl containVC:self];
    [_threeDMapViewController setContainerSearchDisplayController:self.searchDisplayContrl containVC:self];
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    if (preferences.flatMap) {
        _mapType = 2;
        [self.mapTypeButton setBackgroundImage:[UIImage imageNamed:@"grayRect"] forState:UIControlStateNormal];
        self.homeButton.hidden = NO;
        self.mapViewController = _flatMapViewController;
        self.searchBar.delegate = _flatMapViewController;
        self.searchDisplayContrl.delegate = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _flatMapViewController;
    } else {
        self.homeButton.hidden = YES;
        _mapType = 3;
        [self.routeButton setEnabled:NO];
        [self.routeButton setTintColor:[UIColor clearColor]];
        [self.mapTypeButton setBackgroundImage:[UIImage imageNamed:@"blueRect"] forState:UIControlStateNormal];
        self.mapViewController = _threeDMapViewController;
        self.searchBar.delegate = _threeDMapViewController;
        self.searchDisplayContrl.delegate = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _threeDMapViewController;
    }
    
    /* bring map view controller to front */
    [self addChildViewController:self.mapViewController];
    [self.mapViewContainer addSubview:self.mapViewController.view];
    [self.mapViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [AVAnalytics beginLogPageView:@"iOS_Map"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"iOS_Map"];
}

- (void)mapTypeButtonClicked:(UIButton *)sender
{
    if (_mapType == 2) {
        // trans to 3D map
        if ([BBTTileSourceManager hasDownloadTilesource]) {
            NSLog(@"3d map tilesource downloaded");
            [sender setTitle:k3DMapButtonTitle forState:UIControlStateNormal];
            [sender setBackgroundImage:[UIImage imageNamed:@"blueRect"] forState:UIControlStateNormal];
            _mapType = 3;
            [self changeMapType];
            self.homeButton.hidden = YES;
        } else {
            //TODO: ask user to download mbtiles
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"2.5D 地图包尚未下载" message:@"2.5D地图功能需要下载额外的地图包才能使用，现在去下载？\n(也可稍后在“设置-2.5D地图包下载”中下载)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去下载", nil];
            [alert show];
            
        }
    } else {
        [sender setTitle:kFlatMapButtonTitle forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"grayRect"] forState:UIControlStateNormal];
        _mapType = 2;
        self.homeButton.hidden = NO;
        [self changeMapType];
    }
}

- (void)campusButtonClicked:(UIButton *)sender
{
    if (_campus == 0) {
        [sender setBackgroundImage:[UIImage imageNamed:@"校区-南校"] forState:UIControlStateNormal];
        _campus = 1;
        [self.mapViewController changeMapCampusRegion];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"校区-北校"] forState:UIControlStateNormal];
        _campus = 0;
        [self.mapViewController changeMapCampusRegion];
    }
}

- (void)homeButtonTapped:(UIButton *)sender
{
    [self.mapViewController resetMapRegion];
}

- (void)changeMapType
{
    //remove current map view controller first
    [self.mapViewController willMoveToParentViewController:nil];
    [self.mapViewController.view removeFromSuperview];
    [self.mapViewController removeFromParentViewController];
    
    //change prefered map type
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    preferences.flatMap = !preferences.flatMap;
    //init new map view controller
    if (preferences.flatMap) {
        [self.routeButton setEnabled:YES];
        [self.routeButton setTintColor:nil];
        self.mapViewController = _flatMapViewController;
        self.searchBar.delegate = _flatMapViewController;
        self.searchDisplayContrl.delegate = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _flatMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _flatMapViewController;
    } else {
        [self.routeButton setEnabled:NO];
        [self.routeButton setTintColor:[UIColor clearColor]];
        self.mapViewController = _threeDMapViewController;
        self.searchBar.delegate = _threeDMapViewController;
        self.searchDisplayContrl.delegate = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDataSource = _threeDMapViewController;
        self.searchDisplayContrl.searchResultsDelegate = _threeDMapViewController;
    }
    [self addChildViewController:self.mapViewController];
    [self.mapViewContainer addSubview:self.mapViewController.view];
    [self.mapViewController didMoveToParentViewController:self];
}

- (void)fallbackToFlatMap
{
    /* change prefered map type */
    BBTPreferences *preferences = [BBTPreferences sharedInstance];
    if (preferences.flatMap) {
        return; // already flat map, don't need to fallback
    }
    
    /* remove current map view controller first */
    [self.mapViewController willMoveToParentViewController:nil];
    [self.mapViewController.view removeFromSuperview];
    [self.mapViewController removeFromParentViewController];
    
    self.mapViewController = _flatMapViewController;
    self.searchBar.delegate = _flatMapViewController;
    self.searchDisplayContrl.delegate = _flatMapViewController;
    self.searchDisplayContrl.searchResultsDataSource = _flatMapViewController;
    self.searchDisplayContrl.searchResultsDelegate = _flatMapViewController;
    [self addChildViewController:self.mapViewController];
    [self.mapViewContainer addSubview:self.mapViewController.view];
    [self.mapViewController didMoveToParentViewController:self];
    preferences.flatMap = YES;
    self.homeButton.hidden = NO;
    [self.mapTypeButton setTitle:kFlatMapButtonTitle forState:UIControlStateNormal];
}

- (void)startSearch
{
    [self.searchBar becomeFirstResponder];
    
    [self.searchDisplayContrl setActive:YES animated:YES];
}

-(void)toogleDirectionFromDelegate
{
    [self.delegate toogleDirection];
}

#pragma mark - UIAlertViewDelegte


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 for cancle
    // 1 for go to download
    if (buttonIndex == 1) {
        BBTTilesourceDownloadVC *tilesourceDownloadVC = [[BBTTilesourceDownloadVC alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:tilesourceDownloadVC];
        [self presentViewController:navigationVC animated:YES completion:NULL];
    }
}


- (IBAction)BackToHome:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
