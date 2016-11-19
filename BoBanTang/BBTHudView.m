//
//  BBTHudView.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 23/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTHudView.h"

@implementation BBTHudView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated
{
    BBTHudView *hudView = [[BBTHudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;
    
    [hudView showAnimated:animated];
    return hudView;
}

+ (instancetype)removeHudInView:(UIView *)view withHudView:(BBTHudView *)hudView
{
    view.userInteractionEnabled = YES;
    
    [hudView removeAnimated:YES];
    [hudView removeFromSuperview];
    
    return hudView;
}

- (void)showAnimated:(BOOL)animated
{
    if (animated) {
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0f;
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)removeAnimated:(BOOL)animated
{
    if (animated) {
        self.alpha = 1.0f;
        self.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0f;
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    CGRect boxRect = CGRectMake(
                                roundf(self.bounds.size.width - boxWidth) / 2.0f,
                                roundf(self.bounds.size.height - boxHeight) / 2.0f,
                                boxWidth,
                                boxHeight);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.3f alpha:0.8f] setFill];
    [roundedRect fill];
    
    /*
    UIImage *image = [UIImage imageNamed:@""];
    
    CGPoint imagePoint = CGPointMake(
                                     self.center.x - roundf(image.size.width / 2.0f),
                                     self.center.y - roundf(image.size.height / 2.0f) - boxHeight / 8.0f);
    
    [image drawAtPoint:imagePoint];
     */
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    
    CGSize textSize = [@"Loading..." sizeWithAttributes:attributes];
    
    CGPoint textPoint = CGPointMake(
                                    self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 4.0f);
    
    [@"Loading..." drawAtPoint:textPoint withAttributes:attributes];
}


@end
