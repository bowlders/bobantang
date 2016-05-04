//
//  BBTMapViewController.h
//  bobantang
//
//  Created by Bill Bai on 8/26/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTMapContainerVC : UIViewController
@property (nonatomic, readonly) CGRect buttonGroupRect;
- (void)fallbackToFlatMap;
@end
