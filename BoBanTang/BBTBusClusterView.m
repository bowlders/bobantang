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
//@property (nonatomic)         CGFloat                       elementHeight;
//@property (nonatomic)         CGFloat                       elementY;
@property (nonatomic)         NSUInteger                    count;
@property (nonatomic)         BOOL                          didSetupConstrains;
@property (strong, nonatomic) NSArray               *       stationNames;

@property (strong, nonatomic) NSMutableDictionary   *       busViews;
@property (strong, nonatomic) NSMutableArray        *       buttonArray;

@property (strong, nonatomic) NSMutableArray        *       busViewArray;

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
        
        //CGFloat elementHeight = self.frame.size.height / self.count;
        //self.elementHeight = elementHeight;
        //self.elementY = 0.0f;
        
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
    }
    
    return self;
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

- (NSMutableArray *)busViewArray
{
    if (!_busViewArray)
    {
        _busViewArray = [NSMutableArray array];
    }
    return _busViewArray;
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
    
    //int i = 0;
    
    for (NSString *key in busKeys) {
        BBTBusView *busView = self.busViews[key];
        if (!busView) {
            busView = [[BBTBusView alloc] initWithFrame:CGRectZero direction:YES];//CGRectMake(BUS_INIT_X, BUS_INIT_Y, BUS_WIDTH, BUS_HEIGHT) direction:YES];
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
                //busView.frame = [self frameForBusPosition:position];
                [self setNeedsUpdateConstraints];
                [self updateConstraintsIfNeeded];
                [self layoutIfNeeded];
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
    /*
    for (NSString *key in [self.busViews allKeys])
    {
        BBTBusView *busView = self.busViews[key];

    }
     */
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

/*
- (CGRect)frameForBusPosition:(BBTBusViewPosition)position
{
    CGFloat directionFactor = position.direction == BBTBusDirectionSourth ? -1.0f : 1.0f;
    //CGFloat y = self.frame.size.height - self.elementY - (position.stationIndex * self.elementHeight + directionFactor * position.percent * self.elementHeight);
    //CGFloat y = self.frame.size.height - self.elementY - (position.stationIndex * self.elementHeight + directionFactor * position.percent * self.elementHeight);
    
    //NSLog(@"elementY = %f",self.elementY);
    //NSLog(@"elementH = %f",self.elementHeight);
    
    return CGRectMake(BUS_INIT_X, y, BUS_WIDTH, BUS_HEIGHT);
}
*/

- (void)stationButtonTapped:(UIButton *)button
{
    [self.delegate BBTBusClusterView:self didTapButtonAtIndex:button.tag];
}

- (void)updateConstraints
{
    for (NSString *key in [self.busViews allKeys])
    {
        BBTBusView *busView = self.busViews[key];
        BBTBusViewPosition position = [self.delegate BBTBusClusterView:self locationForBus:key];
        CGFloat directionFactor = position.direction == BBTBusDirectionSourth ? -1.0f : 1.0f;
        CGFloat elementHeight = self.frame.size.height / self.count;
        [busView mas_makeConstraints:^(MASConstraintMaker *make) {
           if (!busView.hidden)
           {
               //make.top.lessThanOrEqualTo(self.routeView);
               //make.bottom.lessThanOrEqualTo(self.routeView);
               make.size.equalTo(self.routeView.circleStickArray[0]);
               make.centerX.equalTo(self.routeView).offset(50);
               make.bottom.equalTo(self.routeView).offset(- (float)position.stationIndex * elementHeight - directionFactor * position.percent * elementHeight);
           }
        }];
    }
    [super updateConstraints];
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
