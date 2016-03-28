//
//  SRFile.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/5/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRFile : NSObject

- (NSString *)printableLabel;
- (NSString *)printableLabelDetails;
- (instancetype) initWithFileName:(NSString *)fileName;

@property int year;
@property int month;
@property int day;
@property int fromHour;
@property int fromMin;
@property int fromSec;
@property int toHour;
@property int toMin;
@property int toSec;
@property int size;

@end
