//
//  UIViewController+ViewForTransitionContext.h
//  bobantang
//
//  Created by Bill Bai on 9/10/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ViewForTransitionContext)

- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
