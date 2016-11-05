//
//  AppDelegate.m
//  BoBanTang
//
//  Created by Caesar on 15/10/13.
//  Copyright © 2015年 BBT. All rights reserved.
//

@class BBTCampusInfo;

#import "BBTAppDelegate.h"
#import "APService.h"
#import "UIColor+BBTColor.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudCrashReporting.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <UserNotifications/UserNotifications.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
//#import "WeiboSDK.h"

//Mapbox header
#import "Mapbox.h"

//XHLaunchImage Header
#import "XHLaunchAd.h"

#import "BBTActivityPageManager.h"
#import "BBTCampusInfoManager.h"
#import "BBTCampusInfoViewController.h"

static NSString * activityPageDetailsUrlFront = @"http://babel.100steps.net/news/index.php?ID=";
static NSString * activityPageDetailsUrlEnd = @"&articleType=schoolInformation";

@interface BBTAppDelegate ()

@end

@implementation BBTAppDelegate

extern NSString *kActivityPageAvaliable;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    //Set Mapbox Accesstoken
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoicHl0cmFkZSIsImEiOiJjaW53eGJxZDExNnNidTJtM3N4OHZkZG9jIn0.XPkApL2UVxIpndilZMOsdQ"];
    
    //Enable Crash Reporting.This line of code must be placed before next `setApplicationId:clientKey`
    [AVOSCloudCrashReporting enable];
    //Lean Cloud Settings
    [AVOSCloud setApplicationId:@"Bfwj1TJ6hcSFBPgMRzGYQOr3"
                      clientKey:@"HRAIPGFlzSurUky1YcoYBYS5"];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Share SDK Settings
    [ShareSDK registerApp:@"fa23f1c0fa81"
     
          activePlatforms:@[
                            //@(SSDKPlatformTypeSinaWeibo),
                            //@(SSDKPlatformTypeMail),
                            //@(SSDKPlatformTypeSMS),
                            @(SSDKPlatformTypeCopy),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                            //@(SSDKPlatformTypeRenren),
                            //@(SSDKPlatformTypeGooglePlus)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
             break;
                 
             //case SSDKPlatformTypeSinaWeibo:
             //    [ShareSDKConnector connectWeibo:[WeiboSDK class]];
             //    break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             //case SSDKPlatformTypeSinaWeibo:
             //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
             //    [appInfo SSDKSetupSinaWeiboByAppKey:@"1301926040"
             //                              appSecret:@"1ef58ea2f974b287083ae9c502167c88"
             //                            redirectUri:@"http://www.sharesdk.cn"
             //                               authType:SSDKAuthTypeBoth];
             //    break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx84f6adbf91dd72b0"
                                       appSecret:@"14fdc2690ffa3ae5f4f02c9114614863"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1105125779"
                                      appKey:@"thnaiJcR82WdcFGQ"
                                    authType:SSDKAuthTypeBoth];
                 break;

             default:
                 break;
         }
     }];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor BBTAppGlobalBlue]];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [self registerForRemoteNotification];
    
    //Set activity page if needed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivityPage) name:kActivityPageAvaliable object:nil];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchedResultsController *fetchedResultsController;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BBTActivityPage"];
    NSString *cacheName = [@"Activity" stringByAppendingString:@"Cache"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:context
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:cacheName];
    NSError *error;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Error: %@", error);
    }
    
    if ([fetchedResultsController.fetchedObjects count] != 0)
    {
        //Redundant Design: In case of multiple local activity pages infomation
        for (int i = 0; i < [fetchedResultsController.fetchedObjects count]; i++)
        {
            BBTActivityPage *activityPageInfo = fetchedResultsController.fetchedObjects[i];;
            
            NSDate *currentTime = [NSDate date];
            BOOL start = ([currentTime compare:activityPageInfo.startTime] == NSOrderedDescending);
            BOOL end = ([currentTime compare:activityPageInfo.endTime] == NSOrderedAscending);
            if (start && end)
            {
                [XHLaunchAd showWithAdFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height) setAdImage:^(XHLaunchAd *launchAd) {
                    
                    NSInteger duration = 3;
                    __weak __typeof(launchAd) weakLaunchAd = launchAd;
                    [launchAd setImageUrl:activityPageInfo.imageUrl duration:duration skipType:SkipTypeTimeText options:XHWebImageDefault completed:^(UIImage *image, NSURL *url) {
                        
                    } click:^{
                        
                        if (![activityPageInfo.articleID isEqualToString:@"0"])
                        {
                            NSString *appendingUrlString = [activityPageInfo.articleID stringByAppendingString:activityPageDetailsUrlEnd];
                            NSString *url = [activityPageDetailsUrlFront stringByAppendingString:appendingUrlString];
                            
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                        }
                        
                        //TODO: Bugs exists if call BBTCampusInfoViewController, showFinish will excute right away before user tap the screen
                        //Suggestions: Consult XHLaunchAd code and write our own activity page class
                        
                        /*
                         BBTCampusInfoViewController *destinationVC = [[BBTCampusInfoViewController alloc] init];
                         destinationVC.isActivityPage = YES;
                         destinationVC.activityPageUrl = url;
                         
                         [weakLaunchAd presentViewController:destinationVC animated:YES completion:nil];
                         */
                    }];
                    
                } showFinish:^{
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    self.window.rootViewController = [storyBoard instantiateInitialViewController];
                }];
            }
        }
    }
    
    [[BBTActivityPageManager sharedActivityPageManager] retriveActivityPageInfo];

    return YES;
}


/**
 * 初始化UNUserNotificationCenter
 */
- (void)registerForRemoteNotification {
    // iOS10 兼容
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
        // 监听回调事件
        [uncenter setDelegate:self];
        //iOS10 使用以下方法注册，才能得到授权
        [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                    //TODO:授权状态改变
                                    NSLog(@"%@" , granted ? @"授权成功" : @"授权失败");
                                }];
        // 获取当前的通知授权状态, UNNotificationSettings
        [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"%s\nline:%@\n-----\n%@\n\n", __func__, @(__LINE__), settings);
            /*
             UNAuthorizationStatusNotDetermined : 没有做出选择
             UNAuthorizationStatusDenied : 用户未授权
             UNAuthorizationStatusAuthorized ：用户已授权
             */
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                NSLog(@"未选择");
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                NSLog(@"未授权");
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                NSLog(@"已授权");
            }
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
#pragma clang diagnostic pop
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@",deviceToken);
    [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)showActivityPage
{
    NSLog(@"Activity Page Info Received!");
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "BBT.BoBanTang" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BoBanTang" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BoBanTang.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
