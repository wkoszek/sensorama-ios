// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRUsageStats.h
//  Sensorama


#import <Foundation/Foundation.h>

@interface SRUsageStats : NSObject

+ (void)eventAppOpened;
+ (void)eventAppRecord;
+ (void)eventAppFiles;
+ (void)eventAppSettings;
+ (void)eventAppSettingsAbout;
+ (void)eventAppSettingsPrivacy;

@end
