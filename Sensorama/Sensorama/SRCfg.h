// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRCfg.h
//  Sensorama

@import Foundation;

#define SENSORAMA_MAIN_COLOR 0xc51162
#define SENSORAMA_DATE_FORMAT @"YYYYMMdd-HHmmss"

@interface SRCfg : NSObject

@property (nonatomic) NSFileManager *fileManager;
@property (nonatomic) NSString *pathForDataFiles;
@property (nonatomic) NSInteger sampleInterval;
#define SRCFG_DEFAULT_SAMPLE_INTERVAL 250

+ (SRCfg *) defaultConfiguration;
- (NSString *)stringFromDate:(NSDate *)date;

@end
