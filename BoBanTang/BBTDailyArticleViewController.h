//
//  BBTDailyArticleViewController.h
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

@class BBTDailyArticle;

#import <UIKit/UIKit.h>

@interface BBTDailyArticleViewController : UIViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) BBTDailyArticle * article;

@end
