//
//  BRSMapSearchController.h
//  BRSFlatMap
//
//  Created by Bill Bai on 7/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//
@import MapKit;
#import <Foundation/Foundation.h>

@protocol BRSMapSearchDelegate;

@interface BRSMapSearchHelper : NSObject

@property (nonatomic, strong) NSMutableArray *saerchResult;
@property (nonatomic, weak) id<BRSMapSearchDelegate> delegate;

- (void)startSearch:(NSString *)searchString forLocation:(CLLocationCoordinate2D)location;
- (void)updateSearchResultForKeyword:(NSString *) keyword;
@end

@protocol BRSMapSearchDelegate

- (NSArray *)mapDataForSearchHelper:(BRSMapSearchHelper *)searchHelper;
- (void)mapSearchController:(BRSMapSearchHelper *)searchHelper didGetSearchResponse:(MKLocalSearchResponse *)response;

@end