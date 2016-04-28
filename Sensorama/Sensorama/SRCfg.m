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

+ (SRCfg *) defaultConfiguration {
    static SRCfg *sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [[self alloc] init];
    });
    return sharedConfiguration;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.dateFormatter = [self makeFormatterWithString:SENSORAMA_DATE_FORMAT];
        self.sampleInterval = SRCFG_DEFAULT_SAMPLE_INTERVAL;
        self.fileManager = [NSFileManager defaultManager];
        self.pathForDataFiles = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return self;
}

- (NSDateFormatter *) makeFormatterWithString:(NSString *)formatString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatString];
    return dateFormatter;
}

- (NSString *)stringFromDate:(NSDate *)date {
    return [self.dateFormatter stringFromDate:date];
}

@end
