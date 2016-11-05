//
//  BBTCampusInfoViewController.h
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

@class BBTCampusInfo;

#import <UIKit/UIKit.h>

@interface BBTCampusInfoViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) BBTCampusInfo * info;

@property (assign, nonatomic) BOOL isActivityPage;
@property (strong, nonatomic) NSString *activityPageUrl;

@end
