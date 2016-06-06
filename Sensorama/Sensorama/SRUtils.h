//
//  SRUtils.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreMotion;

@interface SRUtils : NSObject

+ (UIColor *)mainColor;
+ (NSDictionary *)deviceInfo;
+ (NSString*)computeSHA256DigestForString:(NSString*)input;
+ (BOOL)isSimulator;
+ (NSString *)activityString:(CMMotionActivity *)activity;
+ (NSInteger)activityInteger:(CMMotionActivity *)activity;

+ (NSInteger)batteryInteger:(UIDeviceBatteryState)state;
+ (NSString *)batteryLevelString:(UIDeviceBatteryState)state;


+ (NSString *)bundleVersionString;
+ (NSString *)bundleShortVersionString;
+ (NSString *)humanSensoramaVersionString;

+ (BOOL) hasWifi;
+ (BOOL) isDeveloperMode;

+ (void) notifyOK:(NSString *)string;
+ (void) notifyWarn:(NSString *)string;
+ (void) notifyError:(NSString *)string;
+ (void) notifyDebugWithUserInfo:(NSDictionary *)userInfo;

@end
