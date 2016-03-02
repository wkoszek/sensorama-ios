//
//  SRUsageStats.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRUsageStats : NSObject

+ (void)eventAppOpened;
+ (void)eventAppRecord;
+ (void)eventAppFiles;
+ (void)eventAppSettings;
+ (void)eventAppSettingsAbout;
+ (void)eventAppSettingsPrivacy;

@end
