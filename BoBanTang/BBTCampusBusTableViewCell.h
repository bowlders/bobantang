//
//  BBTCampusBusTableViewCell.h
//  BoBanTang
//
//  Created by Caesar on 16/1/28.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTCampusBusTableViewCell : UITableViewCell

- (void)initCellContent:(NSString *)stationName;            //In initialization phase actually only stationName is different
- (void)initCellContent;
- (void)changeCellImageAtSide:(BOOL)side;                   //0 for left (image), 1 for right (image).

@end
