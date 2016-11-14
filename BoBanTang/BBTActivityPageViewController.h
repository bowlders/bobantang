//
//  BBTActivityPageViewController.h
//  波板糖
//
//  Created by Xu Donghui on 07/11/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTActivityPageViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *activityPageUrl;
@property (strong, nonatomic) IBOutlet UILabel *activityTitle;

@end
