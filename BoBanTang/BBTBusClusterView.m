//
//  BBTBusClusterView.m
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <Masonry.h>
#import "UIButton+BBTStationButton.h"
#import "BBTBusClusterView.h"
#import "BBTBusView.h"

@interface BBTBusClusterView()
@property (nonatomic)         CGFloat                       elementHeight;
@property (nonatomic)         CGFloat                       elementY;
@property (nonatomic)         NSUInteger                    count;
@property (nonatomic)         BOOL                          didSetupConstrains;
@property (strong, nonatomic) NSArray               *       stationNames;

@property (strong, nonatomic) NSMutableDictionary   *       busViews;
@property (strong, nonatomic) NSMutableArray        *       buttonArray;

@end

@implementation BBTBusClusterView

#define ROUTE_VIEW_X 160.f
#define ROUTE_VIEW_INIT_WIDTH 25.0f
#define ROUTE_VIEW_INIT_HEIGHT 420.f
#define STATION_BUTTON_X 76.0f
#define UP_PADDING 6.0f
#define STATION_BUTTON_WIDTH 67.f
#define STATION_BUTTON_HEIGHT 20.0f

#define BUS_INIT_X 196.0f
#define BUS_INIT_Y 0.0f
#define BUS_WIDTH 32.0f
#define BUS_HEIGHT 38.0f
#define BUS_MOVE_ANIMATION_DURATION 0.5f

- (instancetype)initWithStationNames:(NSArray *)stationNames
{
    return [self initWithFrame:CGRectZero stationNames:stationNames];
}

- (instancetype)initWithFrame:(CGRect)frame stationNames:(NSArray *)stationNames
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.stationNames = stationNames;
        self.count = [self.stationNames count];
        
        const float offsetBetweenButtonAndCircle = 60;
        
        [self addSubview:self.routeView];
        [self bringSubviewToFront:self.routeView];
        for (int i = 0;i < self.count; i++)
        {
            [self addSubview:self.buttonArray[i]];
        }
        
        [self.routeView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self);
            make.width.equalTo(self).multipliedBy((float)1/11);
            make.height.equalTo(self);
        }];
        
        for (int i = 0;i < self.count;i++)
        {
            [self.buttonArray[i] mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerX.equalTo(self.routeView).offset(-offsetBetweenButtonAndCircle);
                make.centerY.equalTo(self.routeView.circleViewArray[i]);
                make.height.equalTo(self.routeView.circleStickArray[0]);
                make.width.equalTo(@100);
            }];
        }

        //[self setNeedsUpdateConstraints];
        //[self updateConstraintsIfNeeded];
    }
    
    return self;

/*
    self.stationNames = stationNames;

    NSUInteger count = [self.stationNames count];
    CGFloat elementHeight = self.frame.size.height / count;
    self.elementHeight = elementHeight;
    self.elementY = 0.0f;


    CGFloat routeViewFactor = self.frame.size.height / ROUTE_VIEW_INIT_HEIGHT;
    CGFloat routeViewWidth = ROUTE_VIEW_INIT_WIDTH * routeViewFactor;
    CGFloat routeViewOriginX = self.bounds.size.width/2;
    
    //CGRect routeViewFrame = CGRectMake(routeViewOriginX, 0.0f, routeViewWidth, self.frame.size.height);
    //self.routeView = [[BBTBusRouteView alloc] initWithFrame:routeViewFrame Count:count];
    self.routeView = [[BBTBusRouteView alloc] initWithCount:count];
    [self addSubview:self.routeView];
    [self bringSubviewToFront:self.routeView];
    
    //Add stationName buttons
    for (NSUInteger i = 0; i < count; i++) {
        UIButton *stationButton = [UIButton stationButtonWithName:self.stationNames[i]];
        stationButton.tag = i;
        [stationButton addTarget:self action:@selector(stationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat buttonY = ((NSNumber *)(self.routeView.circlesOriginYArray[i])).floatValue + ((NSNumber *)(self.routeView.circlesHeightArray[i])).floatValue * 0.3;
        stationButton.frame = CGRectMake(routeViewOriginX - STATION_BUTTON_WIDTH - 15, buttonY, STATION_BUTTON_WIDTH, STATION_BUTTON_HEIGHT);
        [self addSubview:stationButton];
    }
*/
}

- (NSMutableDictionary *)busViews
{
    if (!_busViews) {
        _busViews = [NSMutableDictionary dictionary];
    }
    return _busViews;
}

- (BBTBusRouteView *)routeView
{
    if (!_routeView)
    {
        _routeView = [[BBTBusRouteView alloc] initWithCount:self.count];
    }
    return _routeView;
}

- (NSMutableArray *)buttonArray
{
    if (!_buttonArray)
    {
        _buttonArray = [NSMutableArray array];
        for (int i = 0;i < self.count;i++)
        {
            UIButton *stationButton = [UIButton stationButtonWithName:self.stationNames[self.count - i - 1]];
            stationButton.tag = self.count - i - 1;
            [stationButton addTarget:self action:@selector(stationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonArray insertObject:stationButton atIndex:i];
        }
    }
    return _buttonArray;
}

- (void)updateBusPosition
{
    NSArray *busKeys = [self.delegate busKeysForBBTBusClusterView:self];
    if ([busKeys count] == 0) {
        return;
    }
    
    for (NSString *key in busKeys) {
        BBTBusView *busView = self.busViews[key];
        if (!busView) {
            busView = [[BBTBusView alloc] initWithFrame:CGRectMake(BUS_INIT_X, BUS_INIT_Y, BUS_WIDTH, BUS_HEIGHT) direction:YES];
            busView.hidden = YES;
            [self.busViews setObject:busView forKey:key];
            [self addSubview:busView];
        }
    }
    
    NSMutableArray *greenCircles = [NSMutableArray array];
    NSMutableArray *violetCircles = [NSMutableArray array];
    for (NSString *key in busKeys) {
        BBTBusView *busView = self.busViews[key];
        if ([self.delegate BBTBusClusterView:self shouldDisplayBus:key]) {
            BBTBusViewPosition position = [self.delegate BBTBusClusterView:self locationForBus:key];
            if (position.direction == BBTBusDirectionSourth) {
                [violetCircles addObject:@(position.stationIndex)];
            } else {
                [greenCircles addObject:@(position.stationIndex)];
            }
            busView.hidden = NO;
            busView.direction = position.direction;
            [UIView animateWithDuration:BUS_MOVE_ANIMATION_DURATION animations:^(void) {
                busView.frame = [self frameForBusPosition:position];
            }];
        } else {
            busView.hidden = YES;
            continue;
        }
    }
    self.routeView.greenCircles = greenCircles;
    self.routeView.violetCircles = violetCircles;
    
}

- (void)restartBusAnimation
{
    for (NSString *key in [self.busViews allKeys])
    {
        BBTBusView *busView = self.busViews[key];
        [busView setNeedsLayout];
    }
}

- (CGRect)frameForBusPosition:(BBTBusViewPosition)position
{
    CGFloat directionFactor = position.direction == BBTBusDirectionSourth ? -1.0f : 1.0f;
    CGFloat y = self.frame.size.height - self.elementY - (position.stationIndex * self.elementHeight + directionFactor * position.percent * self.elementHeight);
    return CGRectMake(BUS_INIT_X, y, BUS_WIDTH, BUS_HEIGHT);
}

- (void)stationButtonTapped:(UIButton *)button
{
    [self.delegate BBTBusClusterView:self didTapButtonAtIndex:button.tag];
}

/*
#pragma mark - autolayout methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsLayout];
}

- (void)updateConstraints
{
    if (!self.didSetupConstrains)
    {
        [self setupConstrains];
    }
    [super updateConstraints];
}

- (void)setupConstrains
{
    
}
*/
 
@end
