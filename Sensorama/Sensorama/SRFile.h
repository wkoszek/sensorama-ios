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
- (instancetype) initWithFileName:(NSString *)fileName;

@property (nonatomic) NSNumber *year;
@property (nonatomic) NSNumber *month;
@property (nonatomic) NSNumber *day;
@property (nonatomic) NSNumber *fromHour;
@property (nonatomic) NSNumber *fromMin;
@property (nonatomic) NSNumber *fromSec;
@property (nonatomic) NSNumber *toHour;
@property (nonatomic) NSNumber *toMin;
@property (nonatomic) NSNumber *toSec;
@property (nonatomic) NSNumber *size;

@end
