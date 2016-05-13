//
//  SRDataPoint.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import QuartzCore;
@import CoreMotion;
@import Foundation;

#import "Realm/Realm.h"

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

@property NSNumber<RLMInt> *activity;


@property NSInteger fileId;
@property NSInteger pointId;
@property NSNumber<RLMDouble> *curTime;

- (instancetype) initWithTime:(NSTimeInterval)timeVal;
- (instancetype) init;
- (NSDictionary *)toDict;
+ (CMMotionManager *)motionManager;
+ (CMPedometer *)pedometerInstance;
+ (CMPedometerData *)pedometerDataUpdate:(CMPedometerData *)data;
+ (CMMotionActivityManager *)activityManager;
+ (CMMotionActivity *)motionActivityUpdate:(CMMotionActivity *)data;

@end
RLM_ARRAY_TYPE(SRDataPoint)

