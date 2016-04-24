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
#import "SRSync.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"
#import "SRDataFile.h"
#import "SRDataPoint.h"

#if 0
#import "ObjCBSON/BSONSerialization.h"
#endif


@interface SREngine ()

@property (nonatomic) SRCfg *configuration;
@property (nonatomic) SRDataFile *dataFile;
@property (nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSMutableArray *srData;
@property (strong, nonatomic) NSDictionary *srContent;


@end

@implementation SREngine

- (instancetype) initWithConfiguration:(SRCfg *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _dataFile = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] userName:[SRAuth emailHashed]];
    }
//
//        self.fileManager = [NSFileManager defaultManager];
//        self.pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        self.srData = [NSMutableArray new];

    return self;
}

- (instancetype) init {
    return [self initWithConfiguration:[SRCfg defaultConfiguration]];
}

- (void) recordingStartWithUpdates:(BOOL)enableUpdates {
    [self startSensors];
    [self.dataFile startWithDate:[NSDate date]];

    self.timer = nil;
    if (enableUpdates) {
        [NSTimer scheduledTimerWithTimeInterval:self.configuration.sampleInterval / 1000
                                         target:self
                                       selector:@selector(recordingUpdate)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)recordingUpdate {
    [self.dataFile updateWithPoint:[SRDataPoint new]];
}

- (void) recordingStart {
    [self recordingStartWithUpdates:YES];
}

- (void) recordingStopWithSync:(BOOL)doSync {
    [self.timer invalidate];
    [self.dataFile finalizeWithDate:[NSDate date]];
    [self.dataFile saveWithSync:doSync];
}

- (void) recordingStop {
    [self recordingStopWithSync:YES];
}

- (void)startSensors {
    [[SRDataPoint motionManager] stopAccelerometerUpdates];
    [[SRDataPoint motionManager] stopMagnetometerUpdates];
    [[SRDataPoint motionManager] stopGyroUpdates];
    [[SRDataPoint motionManager] startAccelerometerUpdates];
    [[SRDataPoint motionManager] startMagnetometerUpdates];
    [[SRDataPoint motionManager] startGyroUpdates];
}

- (NSArray<SRDataFile *> *) allRecordedFiles {
    NSMutableArray *array = [NSMutableArray new];
    for (SRDataFile *file in [[SRDataFile allObjects] sortedResultsUsingProperty:@"fileId" ascending:YES]) {
        [array addObject:file];
    }
    return array;
}

@end
