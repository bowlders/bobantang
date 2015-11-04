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
        self.circleStickArray = [NSMutableArray array];
        
        for (int i = 0;i < self.count;i++)
        {
            [self addSubview:self.circleViewArray[i]];
            [self.circleStickArray insertObject:self.circleViewArray[i] atIndex:2 * i];
            if (i < self.count - 1)
            {
                [self addSubview:self.stickViewArray[i]];
                [self.circleStickArray insertObject:self.stickViewArray[i] atIndex:2 * i + 1];
            }
        }
        
        for (UIImageView *greenCircle in self.greenCircleViewArray)
        {
            [self addSubview:greenCircle];
        }
        
        for (UIImageView *violetCircle in self.violetCircleViewArray)
        {
            [self addSubview:violetCircle];
        }
    
        for (int i = 0;i < 2 * self.count - 1;i++)
        {
            [self.circleStickArray[i] mas_makeConstraints:^(MASConstraintMaker * make){
                //This time it's a circle
                if (i % 2 == 0)
                {
                    make.width.equalTo(((UIImageView *)self.circleStickArray[0]).mas_height);
                    make.height.equalTo(self).multipliedBy((float)4 / (5 * self.count - 1));
                }
                //This time it's a stick
                else
                {
                    make.width.equalTo(self).multipliedBy(0.3);
                    make.height.equalTo(self).multipliedBy(0.25 * (float)4 / (5 * self.count - 1));
                }
                
                make.centerX.equalTo(self);
                
                if (i == 0)
                {
                    make.bottom.equalTo(self).offset(-15);
                }
                else
                {
                    make.bottom.equalTo(((UIImageView *)self.circleStickArray[i-1]).mas_top).offset(1);
                }
            }];
        }
        
        for (int i = 0;i < self.count;i++)
        {
            [self.greenCircleViewArray[i] mas_makeConstraints:^(MASConstraintMaker * make){
                make.size.equalTo([self.circleStickArray firstObject]);
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.circleStickArray[i * 2]);
            }];
            
        }
        
        for (int i = 0;i < self.count;i++)
        {
            [self.violetCircleViewArray[i] mas_makeConstraints:^(MASConstraintMaker * make){
                make.size.equalTo([self.circleStickArray firstObject]);
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.circleStickArray[i * 2]);
            }];
        }
    }

    return self;

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

        for (int i = 0;i < self.count;i++)
        {
            UIImageView * violetCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violetCircle"]];
            violetCircle.hidden = YES;
            [_violetCircleViewArray addObject:violetCircle];
        }

    }
    return _violetCircleViewArray;
}

- (NSMutableArray *)greenCircleViewArray
{
    if (!_greenCircleViewArray)
    {
        _greenCircleViewArray = [NSMutableArray array];

        for (int i = 0;i < self.count;i++)
        {
            UIImageView * greenCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenCircle"]];
            greenCircle.hidden = YES;
            [_greenCircleViewArray addObject:greenCircle];
        }
    }
    return _greenCircleViewArray;
}

#define CIRCLE_INIT_WIDTH 25.0f

@end
