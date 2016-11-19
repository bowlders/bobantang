//
//  BBTSpecRailway2Bus.h
//  BoBanTang
//
//  Created by Caesar on 15/11/19.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

typedef enum : NSUInteger {
    BBTSpecHasDepartedYes = 0,                                                    //The bus has departed the current station
    BBTSpecHasDepartedNo = 1                                                      //The bus hasn't departed the current station
} BBTSpecHasDeparted;

@interface BBTSpecRailway2Bus : JSONModel

@property (readwrite, nonatomic) NSUInteger stationSeq;                           //Count from the first station ( whose index is 0 ), so the same station has different indexes if direction is different
@property (readwrite, nonatomic) BBTSpecHasDeparted adflag;                       //Whether the bus has departed the current station

@end
