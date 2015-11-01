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

@property (nonatomic)         NSUInteger            count;
@property (nonatomic)         BOOL                  didSetupConstrains;

@property (strong, nonatomic) NSMutableArray    *   greenCircleViewArray;                //用于储存greenCircle的views
@property (strong, nonatomic) NSMutableArray    *   violetCircleViewArray;               //用于储存violetCircle的views

@end


@implementation BBTBusRouteView

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
        
        for (UIImageView * stick in self.stickViewArray)
        {
            [self addSubview:stick];
        }

        for (UIImageView * circle in self.circleViewArray)
        {
            [self addSubview:circle];
        }

        for (int i = 0;i < self.count;i++)
        {
            [self.circleViewArray[i] mas_makeConstraints:^(MASConstraintMaker * make){
                make.width.equalTo(self);
                make.height.equalTo(self).multipliedBy((float)4 / (5 * self.count - 1));
                make.centerX.equalTo(self);
                make.bottom.equalTo(self).with.offset(-i * (((UIImageView *)[self.circleViewArray firstObject]).bounds.size.height + ((UIImageView *)[self.stickViewArray firstObject]).bounds.size.height));
            }];
        }
        
        for (int i = 0;i < self.count - 1;i++)
        {
            [self.stickViewArray[i] mas_makeConstraints:^(MASConstraintMaker * make){
                make.width.equalTo(self);
                make.height.equalTo([self.circleViewArray firstObject]).multipliedBy(0.25);
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.circleViewArray[i]).with.offset(-((UIImageView *)[self.circleViewArray firstObject]).bounds.size.height);
            }];
        }
        
        for (id dotIndex in self.greenCircles)
        {
            if ([dotIndex isKindOfClass:[NSNumber class]] && [(NSNumber *)dotIndex integerValue] <= self.count)
            {
                [self.greenCircleViewArray[((NSNumber *)dotIndex).integerValue] mas_makeConstraints:^(MASConstraintMaker * make){
                    make.size.equalTo([self.circleViewArray firstObject]);
                    make.centerX.equalTo(self);
                    make.bottom.equalTo(self.circleViewArray[((NSNumber *)dotIndex).integerValue]);
                }];
            }
        }
        
        for (id dotIndex in self.violetCircles)
        {
            if ([dotIndex isKindOfClass:[NSNumber class]] && [(NSNumber *)dotIndex integerValue] <= self.count)
            {
                [self.violetCircleViewArray[((NSNumber *)dotIndex).integerValue] mas_makeConstraints:^(MASConstraintMaker * make){
                    make.size.equalTo([self.circleViewArray firstObject]);
                    make.centerX.equalTo(self);
                    make.bottom.equalTo(self.circleViewArray[((NSNumber *)dotIndex).integerValue]);
                }];
            }
        }
    }

    return self;

}

- (void)setGreenCircles:(NSMutableArray *)greenDots
{
    _greenCircles = greenDots;
    //[self setNeedsLayout];
}

- (void)setVioletDots:(NSMutableArray *)violetDots
{
    _violetCircles = violetDots;
    //[self setNeedsLayout];
}

- (NSMutableArray *)stickViewArray
{
    if (!_stickViewArray)
    {
        _stickViewArray = [NSMutableArray array];
        for (int i = 0;i < self.count - 1;i++)
        {
            UIImage * stick = [UIImage imageNamed:@"stick"];
            UIImageView * stickView = [[UIImageView alloc] initWithImage:stick];
            [_stickViewArray insertObject:stickView atIndex:i];
        }
    }
    return _stickViewArray;
}

- (NSMutableArray *)circleViewArray
{
    if (!_circleViewArray)
    {
        _circleViewArray = [NSMutableArray array];
        //NSLog(@"%d",self.count);
        for (int i = 0;i < self.count;i++)
        {
            UIImage * circle = [UIImage imageNamed:@"circle"];
            UIImageView * circleView = [[UIImageView alloc] initWithImage:circle];
            [_circleViewArray insertObject:circleView atIndex:i];
        }
    }
    return _circleViewArray;
}


- (NSMutableArray *)violetCircleViewArray
{
    if (!_violetCircleViewArray)
    {
        _violetCircleViewArray = [NSMutableArray array];
        for (id dotIndex in _violetCircles)
        {
            if ([dotIndex isKindOfClass:[NSNumber class]] && [(NSNumber *)dotIndex integerValue] <= self.count)
            {
                UIImageView * violetCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetCircle"]];
                [_violetCircleViewArray insertObject:violetCircle atIndex:((NSNumber *)dotIndex).integerValue];
            }
        }
    }
    return _violetCircleViewArray;
}

- (NSMutableArray *)greenCircleViewArray
{
    if (!_greenCircleViewArray)
    {
        _greenCircleViewArray = [NSMutableArray array];
        for (id dotIndex in _greenCircles)
        {
            if ([dotIndex isKindOfClass:[NSNumber class]] && [(NSNumber *)dotIndex integerValue] <= self.count)
            {
                UIImageView * greenCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenCircle"]];
                [_greenCircleViewArray insertObject:greenCircle atIndex:((NSNumber *)dotIndex).integerValue];
            }
        }
    }
    return _greenCircleViewArray;
}

#define CIRCLE_INIT_WIDTH 25.0f

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
    //CGFloat circleHeight = (4 * self.bounds.size.height) / (5 * self.count - 1);

    
}
 */

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
