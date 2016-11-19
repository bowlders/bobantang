//
//  BRSMapMetaDataManager.h
//  BRSFlatMap
//
//  Created by Bill Bai on 7/15/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRSPlace.h"
#import "BRSMapSearchHelper.h"

@interface BRSMapMetaDataManager : NSObject

@property (nonatomic, strong, readonly) NSArray *flatMapMetaData;
@property (nonatomic, strong, readonly) MKPolygon *campusBoundaryPolygon;

- (MKPolyline *)northCampusPolyline;
- (MKPolyline *)HEMCCampusPolyline;

- (NSArray *)placesForCoordinate:(CLLocationCoordinate2D)coord maxCount:(NSUInteger)max;
@end
