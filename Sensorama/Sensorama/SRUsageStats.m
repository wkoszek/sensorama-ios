//
//  SRUsageStats.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRUsageStats.h"
#import "Fabric/Fabric.h"
#import "Crashlytics/Crashlytics.h"

@implementation SRUsageStats

+ (void)eventAppOpened {
    [Answers logCustomEventWithName:@"Sensorama Opened" customAttributes:nil];
}

+ (void)eventAppRecord {
    [Answers logCustomEventWithName:@"Sensorama Record View" customAttributes:nil];
}

+ (void)eventAppFiles {
    [Answers logCustomEventWithName:@"Sensorama Files View" customAttributes:nil];
}

+ (void)eventAppSettings {
    [Answers logCustomEventWithName:@"Sensorama Settings View" customAttributes:nil];
}

+ (void)eventAppSettingsAbout {
    [Answers logCustomEventWithName:@"Sensorama About View" customAttributes:nil];
}

+ (void)eventAppSettingsPrivacy {
    [Answers logCustomEventWithName:@"Sensorama Privacy View" customAttributes:nil];
}

@end
