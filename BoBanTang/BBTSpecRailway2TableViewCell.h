//
//  BBTSpecRailway2TableViewCell.h
//  BoBanTang
//
//  Created by Caesar on 15/11/22.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTSpecRailway2TableViewCell : UITableViewCell

- (void)initCellContent:(NSString *)stationName;            //In initialization phase actually only stationName is different
- (void)initCellContent;
- (void)changeCellImage;

@end