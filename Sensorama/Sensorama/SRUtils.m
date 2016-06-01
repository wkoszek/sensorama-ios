//
//  SRUtils.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//
// computeSHA256DigestForString method came from:
// https://www.raywenderlich.com/6475/basic-security-in-ios-5-tutorial-part-1

@import UIKit;
@import CoreMotion;

#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import <GBDeviceInfo/GBDeviceInfo.h>
#import "GCNetworkReachability/GCNetworkReachability.h"

#import "SRUtils.h"
#import "SRCfg.h"

@implementation SRUtils

+ (UIColor *)colorFromHex:(uint32_t)rgb {
    CGFloat r = ((rgb   >>  16) & 0xff) / 255.0;
    CGFloat g = ((rgb   >>   8) & 0xff) / 255.0;
    CGFloat b = ((rgb   & 0xff) & 0xff) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *)mainColor {
    return [SRUtils colorFromHex:SENSORAMA_MAIN_COLOR];
}

+ (NSString *)orientationString {
    NSString *orientString = @"unsupported";
    UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
    switch (orient) {
        case UIDeviceOrientationPortrait:
            orientString = @"portrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientString = @"portraitupsidedown";
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientString = @"landscapeleft";
            break;
        case UIDeviceOrientationLandscapeRight:
            orientString = @"landscaperight";
            break;
        case UIDeviceOrientationFaceUp:
            orientString = @"faceup";
            break;
        case UIDeviceOrientationFaceDown:
            orientString = @"facedown";
            break;
        case UIDeviceOrientationUnknown:
        default:
            orientString = @"unknown";
            break;
    }
    return orientString;
}

+ (NSDictionary *)deviceInfo {
    NSDictionary *info = @{
                           @"name" : [[UIDevice currentDevice] name],
                           @"systemName" : [[UIDevice currentDevice] systemName],
                           @"systemVersion" : [[UIDevice currentDevice] systemVersion],
                           @"model" : [[UIDevice currentDevice] model],
                           @"localizedModel" : [[UIDevice currentDevice] localizedModel],
                           @"hw": [[GBDeviceInfo deviceInfo] modelString],
                           @"orientation" : [SRUtils orientationString],
                           };
    return info;
}

+ (NSString*)computeSHA256DigestForString:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return true;
#else
    return false;
#endif
}


+ (NSString *)activityStringAndInt:(CMMotionActivity *)activity integer:(NSInteger *)returnInt
{
    NSString *retStr = @"";
    NSInteger actInt = -1;
    if (activity.unknown)    { retStr = @"unknown"; actInt = 0; }
    if (activity.stationary) { retStr = @"stat";    actInt = 1; }
    if (activity.walking)    { retStr = @"walk";    actInt = 2; }
    if (activity.running)    { retStr = @"run";     actInt = 3; }
    if (activity.cycling)    { retStr = @"bike";    actInt = 4; }
    if (activity.automotive) { retStr = @"car";     actInt = 5; }
    if (returnInt != NULL) {
        *returnInt = actInt;
    }
    return retStr;
}

+ (NSString *)activityString:(CMMotionActivity *)activity
{
    return [SRUtils activityStringAndInt:activity integer:NULL];
}


+ (NSInteger)activityInteger:(CMMotionActivity *)activity
{
    NSInteger retInt = -1;
    [SRUtils activityStringAndInt:activity integer:&retInt];
    return retInt;
}

+ (NSString *)bundleVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)bundleShortVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)humanSensoramaVersionString {
    return [NSString stringWithFormat:@"Sensorama %@ (build:%@)",
            [SRUtils bundleShortVersionString], [SRUtils bundleVersionString]];
}

+ (BOOL) hasWifi {
    GCNetworkReachability *reachability = [GCNetworkReachability reachabilityForInternetConnection];

    return [reachability isReachableViaWiFi];
}

+ (void)notifyDebugWithUserInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SensoramaDebug"
                                                        object:nil
                                                      userInfo:userInfo];
}


+ (void)notifyWithUserInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Sensorama"
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void) notifyOK:(NSString *)string {
    NSDictionary *userInfo = @{ @"type": @"notify", @"text": string };
    [SRUtils notifyWithUserInfo:userInfo];
}

+ (void) notifyWarn:(NSString *)string {
    NSDictionary *userInfo = @{ @"type": @"warn", @"text": string };
    [SRUtils notifyWithUserInfo:userInfo];
}

+ (void) notifyError:(NSString *)string {
    NSDictionary *userInfo = @{ @"type": @"error", @"text": string };
    [SRUtils notifyWithUserInfo:userInfo];
}


@end
