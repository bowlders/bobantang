//
//  BBTBusRouteView.m
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import "BBTBusRouteView.h"
#import <Masonry.h>

@interface BBTBusRouteView()

@property (nonatomic) NSUInteger count;
@property (nonatomic) BOOL didSetupConstrains;

@property (strong, nonatomic) UIImageView    * routeHeadView;
@property (strong, nonatomic) UIImageView    * routeTailView;
@property (strong, nonatomic) NSMutableArray * routeElementViewArray;               //用于储存routeElementView
@property (strong, nonatomic) NSMutableArray * greenCircleViewArray;                //用于储存greenCircle的views
@property (strong, nonatomic) NSMutableArray * violetCircleViewArray;               //用于储存violetCircle的views

@end


@implementation BBTBusRouteView

- (void)setGreenCircles:(NSMutableArray *)greenDots
{
    _greenCircles = greenDots;
    [self setNeedsLayout];
}

- (void)setVioletDots:(NSMutableArray *)violetDots
{
    _violetCircles = violetDots;
    [self setNeedsLayout];
}

#define ROUTE_VIEW_TAG 42

- (instancetype)initWithCount:(NSUInteger)count
{
    return [self initWithFrame:CGRectZero Count:count];
}

- (instancetype)initWithFrame:(CGRect)frame Count:(NSUInteger)count
{
    
    self = [super initWithFrame:frame];

    if (self)
    {
        self.count = count;
        [self addSubview:self.routeHeadView];
        [self addSubview:self.routeTailView];
        for (UIImageView * routeElement in self.routeElementViewArray)
        {
            [self addSubview:routeElement];
        }

        for (UIImageView * greenCircle in self.greenCircleViewArray)
        {
            [self addSubview:greenCircle];
        }
        for (UIImageView * violetCircle in self.violetCircleViewArray)
        {
            [self addSubview:violetCircle];
        }

        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    }

    return self;

}

- (UIImageView *)routeHeadView
{
    if (!_routeHeadView)
    {
        UIImage * routeHead = [UIImage imageNamed:@"route-head"];
        _routeHeadView = [[UIImageView alloc] initWithImage:routeHead];
    }
    return _routeHeadView;
}

- (UIImageView *)routeTailView
{
    if (!_routeTailView)
    {
        UIImage * routeTail = [UIImage imageNamed:@"route-tail"];
        _routeTailView = [[UIImageView alloc] initWithImage:routeTail];
    }
    return _routeTailView;
}

- (NSMutableArray *)routeElementViewArray
{
    if (!_routeElementViewArray)
    {
        for (int i = 1;i < self.count - 1;i++)
        {
            UIImage * routeElement = [UIImage imageNamed:@"route-element"];
            UIImageView * routeElementView = [[UIImageView alloc] initWithImage:routeElement];
            [_routeElementViewArray insertObject:routeElementView atIndex:i];
        }
    }
    return _routeElementViewArray;
}

- (NSMutableArray *)greenCircleViewArray
{
    if (!_greenCircleViewArray)
    {
        int i = 0;
        for (id dotIndex in _greenCircleViewArray)
        {
            if ([dotIndex isKindOfClass:[NSNumber class]] && [(NSNumber *)dotIndex integerValue] <= self.count)
            {
                UIImageView * greenCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenCircle"]];
                [_greenCircleViewArray insertObject:greenCircle atIndex:i];
                i++;
            }
        }
    }
    return _greenCircleViewArray;
}

- (NSMutableArray *)violetCircleViewArray
{
    if (!_violetCircleViewArray)
    {
        int i = 0;
        for (id dotIndex in _violetCircleViewArray) {
            if ([dotIndex isKindOfClass:[NSNumber class]] && [(NSNumber *)dotIndex integerValue] <= self.count)
            {
                UIImageView * violetCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetCircle"]];
                [_violetCircleViewArray insertObject:violetCircle atIndex:i];
                i++;
            }
        }
    }
    return _violetCircleViewArray;
}

#define CIRCLE_INIT_WIDTH 25.0f
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
    [self.routeHeadView mas_makeConstraints:^(MASConstraintMaker * make){
        make.centerX.equalTo(self);
    }];
    [self.routeTailView mas_makeConstraints:^(MASConstraintMaker * make){
        make.centerX.equalTo(self);
    }];

}

/*
 - (void)updateConstraints
 {
 
 for (UIImageView *greenCircle in self.greenCircleViewArray)
 {
 [greenCircle mas_makeConstraints:^(MASConstraintMaker *make) {
 
 }]
 }
 
 
 for (UIImageView *routeHead in self.routeHeadViewArray)
 {
 [routeHead mas_makeConstraints:^(MASConstraintMaker *make) {
 make.center.equalTo(self);
 }];
 }
 
 for (UIImageView *routeTail in self.routeTailViewArray)
 {
 [routeTail mas_makeConstraints:^(MASConstraintMaker *make) {
 make.center.equalTo(self);
 }];
 }
 
 for (UIImageView *routeElement in self.routeElementViewArray)
 {
 [routeElement mas_makeConstraints:^(MASConstraintMaker *make) {
 make.center.equalTo(self);
 }];
 }
 
 [super updateConstraints];
 
 }
 */

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
