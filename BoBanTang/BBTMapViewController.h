//
//  BBTMapViewController.h
//  bobantang
//
//  Created by Bill Bai on 8/31/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTMapContainerVC.h"

/* abstruct class */
@interface BBTMapViewController : UIViewController

/* override these method in concreat class */
- (void)changeMapCampusRegion;
- (void)setContainerSearchDisplayController:(UISearchDisplayController *)searchDisplayController containVC:(BBTMapContainerVC *)mapContainerVC;
- (void)resetMapRegion;


@end
