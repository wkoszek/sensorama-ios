//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import UIKit;
@import CoreMotion;

#import "SREngine.h"
#import "SRCfg.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"
#import "SRDataFile.h"
#import "SRDataPoint.h"

@interface SREngine ()

@property (nonatomic) SRCfg *configuration;
@property (nonatomic) SRDataFile *dataFile;
@property (nonatomic) NSTimer *timer;
@end

@implementation SREngine

- (instancetype) initWithConfiguration:(SRCfg *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _dataFile = nil;
    }
    return self;
}

- (instancetype) init {
    return [self initWithConfiguration:[SRCfg defaultConfiguration]];
}

- (void) recordingStartWithUpdates:(BOOL)enableUpdates {
    [self startSensors];

    self.dataFile = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] userName:[SRAuth emailHashed]];
    [self.dataFile startWithDate:[NSDate date]];

    self.timer = nil;
    if (enableUpdates) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(0.001 * self.configuration.sampleInterval)
                                         target:self
                                       selector:@selector(recordingUpdate)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)recordingUpdate {
    static int updateCount = 0;

    SRPROBE0();

    SRDataPoint *newPoint = [[SRDataPoint alloc] initWithConfiguration:self.configuration];
    updateCount++;
    //NSLog(@"newPoint=%@", newPoint);
    [self.dataFile updateWithPoint:newPoint];


    if (![SRUtils isDeveloperMode]) {
        return;
    }
    NSDictionary *userInfo = @{ @"text": [NSString stringWithFormat:@"point %d", updateCount] };
    [SRUtils notifyDebugWithUserInfo:userInfo];
}

- (void) recordingStart {
    [self recordingStartWithUpdates:YES];
}

- (void) recordingStopWithExport:(BOOL)doExport {
    [self.timer invalidate];
    self.timer = nil;
    [self.dataFile finalizeWithDate:[NSDate date]];
    [self.dataFile saveWithExport:doExport];
}

- (void) recordingStop {
    [self recordingStopWithExport:YES];
}



- (CMPedometerHandler)pedometerUpdateHandler {
    void (^handler)(CMPedometerData *, NSError *) = ^(CMPedometerData *d, NSError *error) {
        [SRDataPoint pedometerDataUpdate:d];
    };
    return handler;
}

- (CMMotionActivityHandler)motionActivityUpdateHandler {
    void (^handler)(CMMotionActivity *) = ^(CMMotionActivity *activity) {
        [SRDataPoint motionActivityUpdate:activity];

        NSString *activityString = [SRUtils activityString:activity];
        NSLog(@"activity Update: %@", activityString);
    };
    return handler;
}

- (void)startSensors {
    [[SRDataPoint motionManager] stopAccelerometerUpdates];
    [[SRDataPoint motionManager] stopMagnetometerUpdates];
    [[SRDataPoint motionManager] stopGyroUpdates];
    [[SRDataPoint pedometerInstance] stopPedometerUpdates];
    [[SRDataPoint activityManager] stopActivityUpdates];

    [[SRDataPoint motionManager] startAccelerometerUpdates];
    [[SRDataPoint motionManager] startMagnetometerUpdates];
    [[SRDataPoint motionManager] startGyroUpdates];
    [[SRDataPoint pedometerInstance] startPedometerUpdatesFromDate:[NSDate date]
                                                       withHandler:self.pedometerUpdateHandler];
    [[SRDataPoint activityManager] startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                                   withHandler:[self motionActivityUpdateHandler]];
}

- (NSArray<SRDataFile *> *) allRecordedFiles {
    NSMutableArray *array = [NSMutableArray new];
    for (SRDataFile *file in [[SRDataFile allObjects] sortedResultsUsingProperty:@"fileId" ascending:NO]) {
        [array addObject:file];
    }
    return array;
}

@end
