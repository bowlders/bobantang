//
//  BBTDailyArticleViewController.h
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

@class BBTDailyArticle;

#import <UIKit/UIKit.h>

@interface BBTDailyArticleViewController : UIViewController<UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) BBTDailyArticle * article;
@property (assign, nonatomic) int isEnteredFromArticleTableVC;   //Set to 1 if detail VC is entered from BBTDailyArticleTableViewController.

@end
