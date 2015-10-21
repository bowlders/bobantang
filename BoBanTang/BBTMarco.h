//
//  BBTMarco.h
<<<<<<< HEAD
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#ifndef bobantang_BBTMarco_h
#define bobantang_BBTMarco_h


typedef enum : NSUInteger {
    BBTBusManagerStateNormal,
    BBTBusManagerStateAllStop,
    BBTBusManagerStateNetWorkError
} BBTBusManagerState;

typedef enum : NSUInteger {
    BBTBusDirectionNorth,
    BBTBusDirectionSourth
} BBTBusDirection;
=======
//  BoBanTang
//
//  Created by Hsu Tung Hui on 13/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#ifndef BBTMarco_h
#define BBTMarco_h
>>>>>>> origin/Tools

typedef NS_ENUM(NSInteger, SCUTCampus) {
    SCUTCampusNorth,
    SCUTCampusHEMC
};

<<<<<<< HEAD
typedef struct {
    BBTBusDirection direction;
    NSUInteger stationIndex;
    double percent;
} BBTBusViewPosition;

#endif
=======

#endif /* BBTMarco_h */
>>>>>>> origin/Tools
