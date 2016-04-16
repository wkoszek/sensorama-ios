//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BZipCompression/BZipCompression.h"
#import "CoreMotion/CoreMotion.h"
#import "UIKit/UIKit.h"
#import "SREngine.h"
#import "SRCfg.h"
#import "SRSync.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"

@interface SREngine ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *pathDocuments;
@property (strong, nonatomic) SRCfg *srCfg;
@property (strong, nonatomic) NSThread *srThread;
@property (strong, nonatomic) NSTimer *srTimer;
@property (strong, nonatomic) NSMutableArray *srData;
@property (strong, nonatomic) NSDictionary *srContent;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (nonatomic) BOOL isSim;

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
        self.isSim = [SRUtils isSimulator];
        self.startDate = nil;
        self.endDate = nil;
    }
    return self;
}

- (void) recordingStartWithUpdates:(BOOL)enableUpdates {
    [self startSensors];
    [self sampleStart];
    self.srTimer = nil;
    if (enableUpdates) {
        [NSTimer scheduledTimerWithTimeInterval:0.25
                                         target:self
                                       selector:@selector(sampleUpdate)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void) recordingStart {
    [self recordingStartWithUpdates:YES];
}

- (void) recordingStopWithPath:(NSString *)path doSync:(BOOL)doSync {
    if (self.startDate == nil) {
        // didn't start yet
        return;
    }
    [self.srTimer invalidate];

    [self sampleEnd];
    [self sampleFinalize];
    [self sampleExportWithPath:path doSync:doSync];
}

- (void) recordingStop {
    [self recordingStopWithPath:[self samplePath] doSync:YES];
}

- (void)startSensors {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.motionManager = [CMMotionManager new];
    });

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

- (NSMutableDictionary *) newDataPoint {
    NSMutableDictionary *oneDataPoint = [NSMutableDictionary new];

    CFTimeInterval curTime = CACurrentMediaTime();
    [oneDataPoint setObject:@(curTime) forKey:@"t"];
    [oneDataPoint setObject:@(arc4random()) forKey:@"i"];


    CMAcceleration  acc = [self curAccData];
    CMMagneticField mag = [self curMagData];
    CMRotationRate gyro = [self curGyroData];

    [oneDataPoint setObject:@[  @(acc.x),  @(acc.y), @(acc.z)]  forKey:@"acc"];
    [oneDataPoint setObject:@[  @(mag.x),  @(mag.y), @(mag.z)]  forKey:@"mag"];
    [oneDataPoint setObject:@[ @(gyro.x), @(gyro.y), @(gyro.z)] forKey:@"gyro"];

    return oneDataPoint;
}

- (CMAcceleration) curAccData {
    CMAcceleration vals;
    if (!self.isSim) {
        return [[self.motionManager accelerometerData] acceleration];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (CMMagneticField) curMagData {
    CMMagneticField vals;
    if (!self.isSim) {
        return [[self.motionManager magnetometerData] magneticField];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (CMRotationRate) curGyroData {
    CMRotationRate vals;
    if (!self.isSim) {
        return [[self.motionManager gyroData] rotationRate];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (void) sampleStart {
    self.startDate = [NSDate new];
}

- (void) sampleEnd {
    self.endDate = [NSDate new];
}

- (void) sampleUpdate {
    NSMutableDictionary *oneDataPoint = [self newDataPoint];
    [self.srData addObject:oneDataPoint];
}

- (NSString *)samplePath {
    SRPROBE0();

    NSString *dateString = [NSString stringWithFormat:@"%@_%@",
                            [self.srCfg stringFromDate:self.startDate],
                            [self.srCfg stringFromDate:self.endDate]];
    NSString *fileName = [NSString stringWithFormat:@"%@.json.bz2", dateString];
    NSString *sampleFilePath = [self.pathDocuments stringByAppendingPathComponent:fileName];

    return sampleFilePath;
}

- (void) sampleFinalize {
    SRPROBE0();

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self schemaDict] copyItems:YES];
    [dict setObject:[SRAuth emailHashed] forKey:@"username"];
    [dict setObject:[self.srCfg stringFromDate:self.startDate] forKey:@"date_start"];
    [dict setObject:[self.srCfg stringFromDate:self.startDate] forKey:@"date_end"];
    [dict setObject:[SRUtils deviceInfo] forKey:@"device_info"];
    [dict setObject:self.srData forKey:@"points"];
    [dict setObject:@"Sensorama_iOS" forKey:@"desc"];
    [dict setObject:@(250) forKey:@"interval"];
    self.srContent = dict;
}

- (void) sampleExportWithPath:(NSString *)pathString doSync:(BOOL)doSync {
    SRPROBE0();
    NSError *error = nil;
    NSData *sampleDataJSON = [NSJSONSerialization dataWithJSONObject:self.srContent options:NSJSONWritingPrettyPrinted error:&error];
    NSData *compressedData = [BZipCompression compressedDataWithData:sampleDataJSON
                                                           blockSize:BZipDefaultBlockSize
                                                          workFactor:BZipDefaultWorkFactor
                                                               error:&error];
    SRPROBE1(@([compressedData length]));
    [compressedData writeToFile:pathString atomically:NO];

    if (doSync) {
        SRSync *syncFile = [[SRSync alloc] initWithPath:pathString];
        [syncFile syncStart];
    }
}

- (void) sampleExportWithPath:(NSString *)pathString {
    [self sampleExportWithPath:pathString doSync:YES];
}


- (NSString *) filesPath {
    return self.pathDocuments;
}

- (NSArray *) filesRecorded {
    NSArray *filePaths = [self.fileManager contentsOfDirectoryAtPath:self.pathDocuments error:nil];


    return filePaths;
}

@end
