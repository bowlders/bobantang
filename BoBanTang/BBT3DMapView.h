//
//  BBT3DMapView.h
//  bobantang
//
//  Created by Bill Bai on 8/31/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//
#import <mapbox.h>
#import "RMMapView.h"

@interface BBT3DMapView : RMMapView

- (instancetype)initWithFrame:(CGRect)frame northTilesource:(RMMBTilesSource *)northTilesource HEMCTilesource:(RMMBTilesSource *)HEMCTilesource;
-(void)zoomToFitAllAnnotationsAnimated:(BOOL)animated;

- (void)displayNorthCampusMap;
- (void)displayHEMCCampusMap;

- (BOOL)hasCampusTileSource;
- (void)setupNorthCampusTilesource:(RMMBTilesSource *)tilesource;
- (void)setupHEMCCampusTilesource:(RMMBTilesSource *)tilesource;

@end
