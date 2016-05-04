//
//  MKPolygon+PointInPolygon.m
//  BRSFlatMap
//
//  Created by Bill Bai on 8/14/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import "MKPolygon+PointInPolygon.h"

@implementation MKPolygon (PointInPolygon)
-(BOOL)coordInPolygon:(CLLocationCoordinate2D)coord {
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    return [self pointInPolygon:mapPoint];
}

-(BOOL)pointInPolygon:(MKMapPoint)mapPoint {
    
    MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:self];
    CGPoint polygonViewPoint = [polygonRenderer pointForMapPoint:mapPoint];
    return CGPathContainsPoint(polygonRenderer.path, NULL, polygonViewPoint, NO);
}

@end
