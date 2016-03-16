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

@property NSUInteger year;
@property NSUInteger month;
@property NSUInteger day;
@property NSUInteger fromHour;
@property NSUInteger fromMin;
@property NSUInteger fromSec;
@property NSUInteger toHour;
@property NSUInteger toMin;
@property NSUInteger toSec;
@property NSUInteger size;

@end
