//
//  MKPolygon+PointInPolygon.h
//  BRSFlatMap
//
//  Created by Bill Bai on 8/14/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolygon (PointInPolygon)
-(BOOL)coordInPolygon:(CLLocationCoordinate2D)coord;
-(BOOL)pointInPolygon:(MKMapPoint)point;
@end
