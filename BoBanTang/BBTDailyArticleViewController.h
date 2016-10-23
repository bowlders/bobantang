//
//  BBTDailyArticleViewController.h
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

@class BBTDailyArticle;

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
@protocol PersonJSExport <JSExport>
- (void)getPlayOrNot;
- (void) startFullScreen;
- (void) exitFullScreen;
@end

@interface BBTDailyArticleViewController : UIViewController<UIGestureRecognizerDelegate, UIWebViewDelegate,PersonJSExport>

@property (strong, nonatomic) BBTDailyArticle * article;
@property (assign, nonatomic) int isEnteredFromArticleTableVC;   //Set to 1 if detail VC is entered from BBTDailyArticleTableViewController.
@end
