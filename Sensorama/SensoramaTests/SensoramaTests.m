// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTests.m
//  SensoramaTests
//

#import "SREngine.h"
#import "SRDataPoint.h"
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
            NSLog(@"error hanlding dbTearDown! %@", [error localizedDescription]);
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
    dp.index = @(arc4random());
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

- (void)testDatapointOneDay {
    [self helperDataPointTestWithPoints:10*60*60*24 batchSize:600];
}


@end
