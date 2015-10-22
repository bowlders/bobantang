//
//  BBTCountView.h
//  bobantang
//
//  Created by Bill Bai on 8/22/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger{
    BBTCountViewStateCounting = 0,
    BBTCountViewStateAlarm,
    BBTCountViewStateOff
} BBTCountViewState;

@interface BBTCountView : UIView

@property (nonatomic) BBTCountViewState state;
@property (strong, nonatomic) UIImageView *statePic;
@property (strong, nonatomic) UILabel *countLabel;
@property (nonatomic) NSUInteger count;

- (void)performFlashAnimation;
- (void)setState:(BBTCountViewState)state Count:(NSUInteger)count;

@end