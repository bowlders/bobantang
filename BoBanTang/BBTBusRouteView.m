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
@end


@implementation BBTBusRouteView

- (void)setGreenCircles:(NSMutableArray *)greenDots
{
    _greenCircles = greenDots;
    [self setNeedsLayout];
}

- (void)setVioetDots:(NSMutableArray *)violetDots
{
    _violetCircles = violetDots;
    [self setNeedsLayout];
}

#define ROUTE_VIEW_TAG 42
- (instancetype)initWithFrame:(CGRect)frame Count:(NSUInteger)count
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.count = count;
    
    UIView *routeWrapper = [[UIView alloc] initWithFrame:self.bounds];
    routeWrapper.tag = ROUTE_VIEW_TAG;
    UIImage *routeElement = [UIImage imageNamed:@"route-element"];
    for (NSUInteger i = 0; i < count; i++) {
        if (i == 0) {
            UIImage *routeHead = [UIImage imageNamed:@"route-head"];
            UIImageView *routeHeadView = [[UIImageView alloc] initWithImage:routeHead];
            [routeWrapper addSubview:routeHeadView];
        } else if (i == count - 1) {
            UIImage *routeTail = [UIImage imageNamed:@"route-tail"];
            UIImageView *routeTailView = [[UIImageView alloc] initWithImage:routeTail];
            [routeWrapper addSubview:routeTailView];
        } else {
            UIImageView *routeElementView = [[UIImageView alloc] initWithImage:routeElement];
            [routeWrapper addSubview:routeElementView];
        }
    }
    [self addSubview:routeWrapper];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];

    return self;
}


#define CIRCLE_INIT_WIDTH 25.0f
- (void)layoutSubviews
{
    const CGFloat circleWidth = self.frame.size.width;
    const CGFloat elementHeight = self.frame.size.height / self.count;
    const CGFloat upPadding = 5.0f * (circleWidth / CIRCLE_INIT_WIDTH);
    for (UIView *thisView in self.subviews) {
        if (thisView.tag != ROUTE_VIEW_TAG) {
            [thisView removeFromSuperview];
        }
    }
    
    for (id dotIndex in self.greenCircles) {
        if ([dotIndex isKindOfClass:[NSNumber class]] &&
            [(NSNumber *)dotIndex integerValue] <= self.count
            ) {
            UIImageView *circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenCircle"]];
            [self addSubview:circle];
        }
    }
    
    for (id dotIndex in self.violetCircles) {
        if ([dotIndex isKindOfClass:[NSNumber class]] &&
            [(NSNumber *)dotIndex integerValue] <= self.count) {
            UIImageView *circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetCircle"]];
            [self addSubview:circle];
        }
    }
    
}

- (void)updateConstraints
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
