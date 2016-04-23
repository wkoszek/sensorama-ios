//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "BZipCompression/BZipCompression.h"
#import <MPMessagePack/MPMessagePack.h>
#if 0
#import "ObjCBSON/BSONSerialization.h"
#endif
#import "CoreMotion/CoreMotion.h"
#import "UIKit/UIKit.h"
#import "SREngine.h"
#import "SRCfg.h"
#import "SRSync.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"
#import "SRDataModel.h"

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

@property (nonatomic) int datapointNumber;
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
    self.datapointNumber = 0;
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
    SRDataFile *dataFile = [self sampleFinalize];
    [self sampleExportWithFileId:dataFile.fileId doSync:doSync];
}

- (void) recordingStop {
    [self recordingStopWithPath:[self samplePath] doSync:YES];
}

- (void)startSensors {


    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopGyroUpdates];

    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startMagnetometerUpdates];
    [self.motionManager startGyroUpdates];
}



- (void) sampleStart {
    self.startDate = [NSDate new];
}

- (void) sampleEnd {
    self.endDate = [NSDate new];
}

- (void) sampleUpdate {
    SRDataPoint *point = [SRDataPoint new];
    [self.srData addObject:point];
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

- (SRDataFile *) sampleFinalize {
    SRPROBE0();

    NSString *timezoneString = [[NSTimeZone localTimeZone] name];

    SRDataFile *dataFile = [SRDataFile new];

    dataFile.username = [SRAuth emailHashed];
    dataFile.desc = @"Sensorama_iOS";
    dataFile.timezone = timezoneString;
    /* do something about device_info */

    dataFile.sampleInterval = 250;
    /* sensor states */

    dataFile.dateStart = self.startDate;
    dataFile.dateEnd = self.endDate;
    dataFile.fileId = [[NSDate date] timeIntervalSince1970];

    SRDataStore *datastore = [SRDataStore sharedInstance];
    [datastore insertDataFile:dataFile];

    [self sampleFinalizeDataFile:dataFile points:self.srData];
    return dataFile;
}

- (void) sampleFinalizeDataFile:(SRDataFile *)dataFile points:(NSArray *)dataPointsArray
{
    SRDataStore *datastore = [SRDataStore sharedInstance];
    [datastore insertDataPoints:dataPointsArray];
}

- (void) sampleExportWithFileId:(NSInteger)fileId doSync:(BOOL)doSync {
    SRPROBE0();

    RLMResults<SRDataFile *> *dataFile = [SRDataFile objectsWhere:@"fileId = %d", fileId];
    NSAssert([dataFile count] == 1, @"more than one file with the same ID!");
    NSMutableDictionary *wholeFile = [[NSMutableDictionary alloc] initWithDictionary:[dataFile[0] toDict]];
    RLMResults<SRDataPoint *> *points = [SRDataFile objectsWhere:@"fileId = %d", fileId];
    [wholeFile setObject:points forKey:@"points"];

    NSError *error = nil;
    NSData *sampleDataJSON = [NSJSONSerialization dataWithJSONObject:wholeFile
                                                             options:NSJSONWritingPrettyPrinted error:&error];

    NSLog(@"%@", [[NSString alloc] initWithData:sampleDataJSON encoding:NSUTF8StringEncoding]);
    NSData *compressedDataJSON = [BZipCompression compressedDataWithData:sampleDataJSON
                                                           blockSize:BZipDefaultBlockSize
                                                          workFactor:BZipDefaultWorkFactor
                                                               error:&error];
    SRPROBE1(@([sampleDataJSON length]));
    SRPROBE1(@([compressedDataJSON length]));

    NSData *sampleDataMP = [self.srContent mp_messagePack];
    NSData *compressedDataMP = [BZipCompression compressedDataWithData:sampleDataMP
                                                            blockSize:BZipDefaultBlockSize
                                                           workFactor:BZipDefaultWorkFactor
                                                                error:&error];
    SRPROBE1(@([sampleDataMP length]));
    SRPROBE1(@([compressedDataMP length]));


#if 0
    NSError *errorBSON = nil;
    NSData *sampleDataBSON = [BSONSerialization BSONDataWithDictionary:self.srContent error:&errorBSON];
    NSData *compressedDataBSON = [BZipCompression compressedDataWithData:sampleDataBSON
                                                             blockSize:BZipDefaultBlockSize
                                                            workFactor:BZipDefaultWorkFactor
                                                                 error:&error];
    SRPROBE1(@([sampleDataBSON length]));
    SRPROBE1(@([compressedDataBSON length]));
#endif

#if 0
    [compressedDataJSON writeToFile:pathString atomically:NO];

    if (doSync) {
        SRSync *syncFile = [[SRSync alloc] initWithPath:pathString];
        [syncFile syncStart];
    }
#endif
}

- (void) sampleExportWithId:(NSInteger)fileId {
    [self sampleExportWithFileId:fileId doSync:YES];
}

- (NSString *) filesPath {
    return self.pathDocuments;
}

- (NSArray *) filesRecorded {
    NSArray *filePaths = [self.fileManager contentsOfDirectoryAtPath:self.pathDocuments error:nil];


    return filePaths;
}

@end
