// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTests.m
//  SensoramaTests
//

#import <XCTest/XCTest.h>
#import "JSONModel/JSONModel.h"

#import "SRCfg.h"
#import "SREngine.h"
#import "SRDataStore.h"
#import "SRDataPoint.h"
#import "SRDataFile.h"
#import "SRUnitTestLoop.h"


@interface SensoramaTests : XCTestCase
@property (nonatomic) dispatch_queue_t waitQueue;
@end

@interface SREngine ()

- (void) recordingStartWithUpdates:(BOOL)enableUpdates;
- (void) sampleUpdate;

@end

@implementation SensoramaTests

- (void)setUp {
    [super setUp];
    self.waitQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self dbTearDown];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self dbTearDown];
}


- (void)dbTearDown {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

#pragma mark - Simple file tests

- (void) testSRDataFile1 {
    
    SRDataFile *file = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] fileId:__LINE__ userName:@""];
    [file save];

    RLMResults<SRDataFile *> *files = [SRDataFile allObjects];
    XCTAssert([files count] == 1);
}


- (void) testSRDataFile3 {
    RLMResults<SRDataFile *> *files = [SRDataFile allObjects];
    NSLog(@"save1=%@", files);
    XCTAssert([files count] == 0);

    SRDataFile *file1 = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] fileId:11 userName:@""];
    SRDataFile *file2 = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] fileId:12 userName:@""];
    SRDataFile *file3 = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] fileId:13 userName:@""];

    [file1 save];
    [file2 save];
    [file3 save];

    RLMResults<SRDataFile *> *files2 = [SRDataFile allObjects];
    NSLog(@"save=%@", files2);
    XCTAssert([files2 count] == 3);

    int fid = 11;
    for (SRDataFile *dataFile in files) {
        XCTAssert(dataFile.fileId == fid++);
    }
}

- (SRDataFile *) helperMakeDataFileWithPoints {
    SRCfg *srCfg = [SRCfg defaultConfiguration];
    SRDataFile *file = [SRDataFile new];

    [file updateWithPoint:[[SRDataPoint alloc] initWithConfiguration:srCfg time:10250]];
    [file updateWithPoint:[[SRDataPoint alloc] initWithConfiguration:srCfg time:10500]];
    [file updateWithPoint:[[SRDataPoint alloc] initWithConfiguration:srCfg time:10750]];

    return file;
}

- (void) testSRDataFileWithPoints {
    SRDataFile *file = [self helperMakeDataFileWithPoints];
    [file saveWithExport:NO];

    RLMResults<SRDataFile *> *files = [SRDataFile allObjects];
    XCTAssert([files count] == 1);

    RLMResults<SRDataPoint *> *points = [SRDataPoint allObjects];
    XCTAssert([points count] == 3);
}

- (void) testSRDataFileSync {
    SRDataFile *dataFile = [self helperMakeDataFileWithPoints];
    [dataFile saveWithExport:YES];
}

- (void)testBasicPointMake {
    SRDataPoint *dp = [SRDataPoint new];
    RLMRealm *realm = [RLMRealm defaultRealm];

    WAIT_INIT();
    dispatch_sync(self.waitQueue, ^{
        [realm beginWriteTransaction];
        [realm addObject:dp];
        [realm commitWriteTransaction];
        WAIT_DONE();
    });
    WAIT_LOOP();
}

- (void)testEngineBasic {
    SREngine __block *engine = [SREngine new];

    [engine recordingStartWithUpdates:NO];
    for (int i = 0; i < 10; i++) {
        [engine recordingUpdate];
    }
    [engine recordingStopWithExport:NO];
}

- (void)testEngineOneHour {
    SREngine *engine = [SREngine new];

    WAIT_INIT();
    [engine recordingStartWithUpdates:NO];
    for (int i = 0; i < 60*60*10; i++) {
        [engine recordingUpdate];
    }
    dispatch_sync(self.waitQueue, ^{
        [engine recordingStopWithExport:NO];
        WAIT_DONE();
    });

    WAIT_LOOP();
}

- (void)testDatapointBasic {
    RLMRealm *realm = [RLMRealm defaultRealm];
    WAIT_INIT();
    for (int i = 0; i < 10; i++) {
        SRDataPoint *dp = [SRDataPoint new];

        dispatch_sync(self.waitQueue, ^{
            [realm transactionWithBlock:^{
                [realm addObject:dp];
            }];
            WAIT_DONE();
        });
    }
    WAIT_LOOP();
}

- (void) helperDataPointTestWithPoints:(int)numberOfPoints batchSize:(int)batchSize
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSInteger transNumber = numberOfPoints / batchSize;

    WAIT_INIT();
    for (int ti = 0; ti < transNumber; ti++) {

        NSMutableArray *dps = [NSMutableArray new];
        for (NSInteger bi = 0; bi < batchSize; bi++) {
            SRDataPoint *dp = [SRDataPoint new];
            [dps addObject:dp];
        }
        dispatch_sync(self.waitQueue, ^{
            [realm beginWriteTransaction];
            [realm addOrUpdateObjectsFromArray:dps];
            [realm commitWriteTransaction];
            WAIT_DONE();
        });

        NSLog(@"%d/%d", (int)ti, (int)transNumber);
    }
    WAIT_LOOP();
}

- (void)testDatapointLonger {
    [self helperDataPointTestWithPoints:10*60 batchSize:60];
}


#pragma mark - Basic datastore functionality

- (NSArray *)makeDataPointsWithFileId:(NSInteger)fileId howMany:(NSInteger)howMany {
    NSMutableArray *points = [NSMutableArray new];
    for (int pi = 0; pi < howMany; pi++) {
        SRDataPoint *dp = [SRDataPoint new];
        dp.fileId = fileId;
        [points addObject:dp];
    }
    XCTAssert([points count] == howMany);
    return points;
}

- (int)helpHowManyPointsWithFileId:(NSInteger)fileId
{
    RLMResults<SRDataPoint *> *dataPoints = [SRDataPoint objectsWhere:@"fileId = %ld", fileId];

    return ((int)[dataPoints count]);
}

- (void)helperFileMakerWithId:(NSInteger)fileId howManyPoints:(NSInteger)howManyPoints {

    SRDataFile *file = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration]
                                                          fileId:fileId
                                                        userName:@""];
    [file save];

    NSArray *points = [self makeDataPointsWithFileId:fileId howMany:howManyPoints];
    RLMRealm *realm = [RLMRealm defaultRealm];
    dispatch_sync(self.waitQueue, ^{
        [realm beginWriteTransaction];
        [realm addOrUpdateObjectsFromArray:points];
        [realm commitWriteTransaction];
    });

    XCTAssert([self helpHowManyPointsWithFileId:fileId] == howManyPoints);
}

- (void)testDataStoreBasic {
    [self helperFileMakerWithId:13 howManyPoints:10];
}

- (void)testMake3Files {
    [self helperFileMakerWithId:17 howManyPoints:10];
    [self helperFileMakerWithId:18 howManyPoints:11];
    [self helperFileMakerWithId:19 howManyPoints:12];
}

- (void)testMake3FilesRemove1 {
    [self helperFileMakerWithId:17 howManyPoints:10];
    [self helperFileMakerWithId:18 howManyPoints:11];
    [self helperFileMakerWithId:19 howManyPoints:12];

    RLMResults<SRDataFile *> *files_before = [SRDataFile objectsWhere:@"fileId = 18"];
    XCTAssertEqual([files_before count], 1);

    [[SRDataStore sharedInstance] removeDataFile:files_before[0]];

    RLMResults<SRDataFile *> *files_after = [SRDataFile objectsWhere:@"fileId = 18"];
    XCTAssertEqual([files_after count], 0);
}

- (void)testBasicPointJSONSerialize {
    SRDataPoint *dp = [[SRDataPoint alloc] initWithConfiguration:[SRCfg defaultConfiguration]];
    NSLog(@"dp=%@", [dp toDict]);
}

@end
