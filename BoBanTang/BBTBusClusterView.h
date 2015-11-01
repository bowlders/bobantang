//
//  BBTBusClusterView.h
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
<<<<<<< HEAD
#import "BBTMarco.h"
#import "BBTBusRouteView.h"

=======
#import "BBTBusView.h"
>>>>>>> adb86443ec6d5f8074dd0209532a65cfb9fcfa3f

@protocol BBTBusClusterViewDelegate;

@interface BBTBusClusterView : UIView

@property (weak, nonatomic) id<BBTBusClusterViewDelegate> delegate;
@property (strong, nonatomic) BBTBusRouteView       *       routeView;

- (instancetype)initWithFrame:(CGRect)frame stationNames:(NSArray *)stationNames;
- (void)updateBusPosition;
- (void)restartBusAnimation;

@end


@protocol BBTBusClusterViewDelegate <NSObject>

- (void)BBTBusClusterView:(BBTBusClusterView *)clusterView didTapButtonAtIndex:(NSUInteger)index;

- (NSArray *)busKeysForBBTBusClusterView:(BBTBusClusterView *)clusterView;
- (BOOL)BBTBusClusterView:(BBTBusClusterView *)clusterView shouldDisplayBus:(NSString *)busKey;
- (BBTBusViewPosition)BBTBusClusterView:(BBTBusClusterView *)clusterView locationForBus:(NSString *)busKey;

@end