//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataPoint.h
//  Sensorama

@import QuartzCore;
@import CoreMotion;
@import Foundation;

#import "Realm/Realm.h"
#import "SRCfg.h"

@interface SRDataPoint : RLMObject

@property NSNumber<RLMFloat> *accX;
@property NSNumber<RLMFloat> *accY;
@property NSNumber<RLMFloat> *accZ;

@property NSNumber<RLMFloat> *magX;
@property NSNumber<RLMFloat> *magY;
@property NSNumber<RLMFloat> *magZ;

@property NSNumber<RLMFloat> *gyroX;
@property NSNumber<RLMFloat> *gyroY;
@property NSNumber<RLMFloat> *gyroZ;

@property NSNumber<RLMFloat> *numberOfSteps;
@property NSNumber<RLMFloat> *distance;
@property NSNumber<RLMFloat> *currentPace;
@property NSNumber<RLMFloat> *currentCadence;
@property NSNumber<RLMFloat> *floorsAscended;
@property NSNumber<RLMFloat> *floorsDescended;

@property NSNumber<RLMFloat> *batteryLevel;
@property NSNumber<RLMFloat> *batteryState;

@property NSNumber<RLMInt> *activity;


@property NSInteger fileId;
@property NSInteger pointId;
@property NSNumber<RLMDouble> *curTime;

- (instancetype) initWithConfiguration:(SRCfg *)configuration;
- (instancetype) initWithConfiguration:(SRCfg *)config time:(NSTimeInterval)timeVal;
- (NSDictionary *)toDict;
+ (CMMotionManager *)motionManager;
+ (CMPedometer *)pedometerInstance;
+ (CMPedometerData *)pedometerDataUpdate:(CMPedometerData *)data;
+ (CMMotionActivityManager *)activityManager;
+ (CMMotionActivity *)motionActivityUpdate:(CMMotionActivity *)data;

@end
RLM_ARRAY_TYPE(SRDataPoint)

