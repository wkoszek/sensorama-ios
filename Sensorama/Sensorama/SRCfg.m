//
//  SRCfg.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#include <time.h>
#include <xlocale.h>


#import "SRCfg.h"

@interface SRCfg ()

@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation SRCfg

- (NSDateFormatter *) makeFormatterWithString:(NSString *)formatString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatString];
    return dateFormatter;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.dateFormatter = [self makeFormatterWithString:SENSORAMA_DATE_FORMAT];
        self.timeFormatter = [self makeFormatterWithString:SENSORAMA_TIME_FORMAT];
    }
    return self;
}

- (NSString *)sensoramaTimeString {
    return [self.timeFormatter stringFromDate:[NSDate date]];
}

- (NSString *)sensoramaDateString {
    return [self.dateFormatter stringFromDate:[NSDate date]];
}

@end
