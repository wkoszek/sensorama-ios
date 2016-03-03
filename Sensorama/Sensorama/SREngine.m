//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "CoreMotion/CoreMotion.h"

#import "SREngine.h"
#import "SRCfg.h"

@interface SREngine ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *pathDocuments;
@property (strong, nonatomic) SRCfg *srCfg;
@property (strong, nonatomic) NSThread *srThread;
@property (strong, nonatomic) NSTimer *srTimer;
@property (strong, nonatomic) NSMutableArray *srData;

@property (strong, nonatomic) NSString *startDateString;
@property (strong, nonatomic) NSString *startTimeString;
@property (strong, nonatomic) NSString *endTimeString;

@end

@implementation SREngine

- (instancetype) init {
    self = [super init];
    if (self) {
        self.fileManager = [NSFileManager defaultManager];
        self.pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.srCfg = [SRCfg new];
        self.srThread = [NSThread new];
        self.srData = [NSMutableArray new];
    }
    return self;
}

- (void)storageDebug {

}

- (void) recordingStart {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.motionManager = [CMMotionManager new];
    });

    [self startSensors];

    self.startDateString = [self.srCfg sensoramaDateString];
    self.startTimeString = [self.srCfg sensoramaTimeString];

    self.srTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                     target:self
                                   selector:@selector(updateData)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)startSensors {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopGyroUpdates];

    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startMagnetometerUpdates];
    [self.motionManager startGyroUpdates];
}

- (void) updateData {
    BOOL hasAccelerometer = self.motionManager.accelerometerActive && self.motionManager.accelerometerAvailable;
    BOOL hasMagnetometer = self.motionManager.magnetometerActive && self.motionManager.magnetometerAvailable;
    BOOL hasGyroscope = self.motionManager.gyroActive && self.motionManager.gyroAvailable;

    NSLog(@"loop");

    if (hasAccelerometer) {
        CMAccelerometerData *accData = [self.motionManager accelerometerData];
        NSLog(@"acc:%@", accData);
        CMAcceleration acc = [accData acceleration];
        [self.srData addObject:@{@"acc": @[ @(acc.x), @(acc.y), @(acc.z) ] }];
    }
    if (hasMagnetometer) {
        CMMagnetometerData *magData = [self.motionManager magnetometerData];
        NSLog(@"mag:%@", magData);
        CMMagneticField mag = [magData magneticField];
        [self.srData addObject:@{@"mag": @[ @(mag.x), @(mag.y), @(mag.z) ] }];
    }
    if (hasGyroscope) {
        CMGyroData *gyroData = [self.motionManager gyroData];
        NSLog(@"gyro:%@", gyroData);
        CMRotationRate gyro = [gyroData rotationRate];
        [self.srData addObject:@{@"gyro": @[ @(gyro.x), @(gyro.y), @(gyro.z) ] }];
    }
}

- (void) recordingStop {
    self.endTimeString = [self.srCfg sensoramaTimeString];

    NSString *fileName = [NSString stringWithFormat:@"%@_%@-%@", self.startDateString, self.startTimeString, self.endTimeString];
    NSString *sampleFilePath = [self.pathDocuments stringByAppendingPathComponent:fileName];
    NSLog(@"fileName: %@", sampleFilePath);

    [self.srTimer invalidate];

    NSLog(@"data: %@", self.srData);
}


@end
