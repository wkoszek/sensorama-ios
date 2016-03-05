//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "CoreMotion/CoreMotion.h"
#import "UIKit/UIKit.h"
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
@property (strong, nonatomic) UIDevice *srDevice;

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
        self.srDevice = [UIDevice currentDevice];
    }
    return self;
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

- (NSDictionary *)schemaDict {
    NSError *error;
    NSString *schemaFilePath = [[NSBundle mainBundle] pathForResource:@"sensorama.schema" ofType:@"json"];
    NSData *schemaData = [NSData dataWithContentsOfFile:schemaFilePath];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:schemaData
                          options:kNilOptions
                          error:&error];
    NSAssert(jsonDict != nil, @"couldn't serialize JSON file");
    return jsonDict;
}

- (void) updateData {
    BOOL isSIM = true;
    BOOL hasAccelerometer = isSIM || (self.motionManager.accelerometerActive && self.motionManager.accelerometerAvailable);
    BOOL hasMagnetometer = isSIM || (self.motionManager.magnetometerActive && self.motionManager.magnetometerAvailable);
    BOOL hasGyroscope = isSIM || (self.motionManager.gyroActive && self.motionManager.gyroAvailable);

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
    if (self.startDateString == nil || self.startTimeString == nil) {
        // didn't start yet
        return;
    }

    [self.srTimer invalidate];
    self.endTimeString = [self.srCfg sensoramaTimeString];

    NSString *fileName = [NSString stringWithFormat:@"%@_%@-%@.json", self.startDateString, self.startTimeString, self.endTimeString];
    NSString *sampleFilePath = [self.pathDocuments stringByAppendingPathComponent:fileName];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self schemaDict] copyItems:YES];
    [dict setObject:self.srData forKey:@"points"];
    [dict setObject:sampleFilePath forKey:@"date"];
    [dict setObject:@"Sensorama iOS" forKey:@"desc"];
    [dict setObject:@(250) forKey:@"interval"];

    NSError *error = nil;
    NSData *sampleDataJSON = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sampleDataJSON encoding:NSUTF8StringEncoding];
    NSLog(@"dict=%@", jsonString);

    [jsonString writeToFile:sampleFilePath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
    NSLog(@"error=%@", error);

    NSLog(@"dirContents=%@", [self filesRecorded]);
}

- (NSString *) filesPath {


    return self.pathDocuments;
}

- (NSArray *) filesRecorded {
    NSArray *filePaths = [self.fileManager contentsOfDirectoryAtPath:self.pathDocuments error:nil];


    return filePaths;


//
//    NSArray *filePathsSorted = [filePaths sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        NSString *aStr = (NSString *)a;
//        NSString *bStr = (NSString *)b;
//        return false;
//    }];
//    return filePathsSorted;
}


@end
