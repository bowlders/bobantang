//
//  BBTBusView.h
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTBus.h"


@interface BBTBusView : UIView

@property (nonatomic) BBTBusDirection direction;
@property (strong, nonatomic) UIImageView *busPic, *arrowView, *slashView;

@property (strong, nonatomic) CAAnimation *animationViewPosition;

- (id)initWithFrame:(CGRect)frame direction:(BBTBusDirection)direction;
@end
