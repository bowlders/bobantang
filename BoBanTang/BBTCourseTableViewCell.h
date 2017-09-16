//
//  BBTCourseTableViewCell.h
//  波板糖
//
//  Created by Authority on 2017/9/14.
//  Copyright © 2017年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTCourseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ClassNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *CourseLabel;
@property (weak, nonatomic) IBOutlet UILabel *TeacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *ClassroomLabel;

@end
