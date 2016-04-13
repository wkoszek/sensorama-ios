//
//  SRCfg.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SRCfg : NSObject

#define SENSORAMA_MAIN_COLOR 0xc51162
#define SENSORAMA_DATE_FORMAT @"YYYYMMdd-HHmmss"

- (NSString *)stringFromDate:(NSDate *)date;

@end
