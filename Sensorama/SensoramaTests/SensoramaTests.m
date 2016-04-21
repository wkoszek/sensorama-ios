// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTests.m
//  SensoramaTests
//

#import "SREngine.h"
#import "SRDataModel.h"
#import <XCTest/XCTest.h>

@interface SensoramaTests : XCTestCase

@end

@interface SREngine ()

- (void) recordingStopWithPath:(NSString *)path doSync:(BOOL)doSync;
- (void) recordingStartWithUpdates:(BOOL)enableUpdates;
- (void) sampleUpdate;

@end

@implementation SensoramaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self dbTearDown];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)dbTearDown {
    NSFileManager *manager = [NSFileManager defaultManager];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSString *> *realmFilePaths = @[
                                            config.path,
                                            [config.path stringByAppendingPathExtension:@"lock"],
                                            [config.path stringByAppendingPathExtension:@"log_a"],
                                            [config.path stringByAppendingPathExtension:@"log_b"],
                                            [config.path stringByAppendingPathExtension:@"note"]
                                            ];
    for (NSString *path in realmFilePaths) {
        NSError *error = nil;
        [manager removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"error handling dbTearDown! %@", [error localizedDescription]);
        }
    }
}

- (void)testEngineBasic {
    SREngine __block *engine = [SREngine new];
    int i;

    [engine recordingStartWithUpdates:NO];
    for (i = 0; i < 10; i++) {
        [engine sampleUpdate];
    }
    [engine recordingStopWithPath:@"/tmp/data.json.bz2" doSync:NO];
}

- (void)testEngineOneHour {
    SREngine *engine = [SREngine new];

    [engine recordingStartWithUpdates:NO];
    for (int i = 0; i < 60*60*10; i++) {
        [engine sampleUpdate];
    }
    [engine recordingStopWithPath:@"/tmp/data.json.bz2" doSync:NO];
}

- (SRDataPoint *)makeRandomDataPoint {
    SRDataPoint *dp = [SRDataPoint new];
    dp.magX = dp.magY = dp.magZ = @(arc4random());
    dp.accX = dp.accY = dp.accZ = @(arc4random());
    dp.gyroX = dp.gyroY = dp.gyroZ = @(arc4random());
    dp.curTime = arc4random();
    dp.fileId = @(arc4random());
    return dp;
}

- (void)testDatapointBasic {
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (int i = 0; i < 10; i++) {
        SRDataPoint *dp = [self makeRandomDataPoint];
        [realm transactionWithBlock:^{
            [realm addObject:dp];
        }];
    }
}

- (void) helperDataPointTestWithPoints:(int)numberOfPoints batchSize:(int)batchSize
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSInteger transNumber = numberOfPoints / batchSize;

    for (int ti = 0; ti < transNumber; ti++) {

        NSMutableArray *dps = [NSMutableArray new];
        for (NSInteger bi = 0; bi < batchSize; bi++) {
            SRDataPoint *dp = [self makeRandomDataPoint];
            [dps addObject:dp];
        }
        [realm beginWriteTransaction];
        [realm addOrUpdateObjectsFromArray:dps];
        [realm commitWriteTransaction];
        NSLog(@"%d/%d", ti, transNumber);
    }
}

- (void)testDatapointLonger {
    [self helperDataPointTestWithPoints:10*60 batchSize:60];
}


#pragma mark - Basic datastore functionality

- (NSArray *)makeDataPointsWithFileId:(int)fileId howMany:(NSInteger)howMany {
    NSMutableArray *points = [NSMutableArray new];
    for (int pi = 0; pi < howMany; pi++) {
        SRDataPoint *dp = [self makeRandomDataPoint];
        dp.fileId = fileId;
        dp.pointId = fileId + pi;
        [points addObject:dp];
    }
    XCTAssert([points count] == howMany);
    return points;
}

- (void)testDataStoreBasic {
    NSArray *points = [self makeDataPointsWithFileId:13 howMany:10];

    RLMRealm *realm = [[SRDataStore sharedInstance] realm];
    [realm beginWriteTransaction];
#if 0
    [realm addObject:points[0]];
    [realm addObject:points[1]];
    [realm addObject:points[2]];
#else
    [realm addOrUpdateObjectsFromArray:points];
#endif
    [realm commitWriteTransaction];

    RLMResults<SRDataPoint *> *dataPoints = [SRDataPoint objectsWhere:@"fileId = 13"];

    XCTAssert([dataPoints count] == 10);
}


@end
