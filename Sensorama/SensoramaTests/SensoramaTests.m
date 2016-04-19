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
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self dbTearDown];
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

- (void)testPerformanceEngineOneHour {
    SREngine __block *engine = [SREngine new];

    [engine recordingStartWithUpdates:NO];
    [self measureBlock:^{
        for (int i = 0; i < 60*60*10; i++) {
            [engine sampleUpdate];
        }
    }];
    [engine recordingStopWithPath:@"/tmp/data.json.bz2" doSync:NO];
}

- (void)testPerformanceDatapointBasic {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [self measureBlock:^{
        for (int i = 0; i < 10; i++) {
            SRDataPoint *dp = [SRDataPoint new];

            dp.magX = @(10);
            dp.magY = @(12);
            dp.magZ = @(14);

            [realm transactionWithBlock:^{
                [realm addObject:dp];
            }];
        }
    }];
}

- (void)testPerformanceDatapointOneDay {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [self measureBlock:^{
        for (int i = 0; i < 60*60*10; i++) {
            SRDataPoint *dp = [SRDataPoint new];

            dp.magX = dp.magY = dp.magZ = @(arc4random());
            dp.accX = dp.accY = dp.accZ = @(arc4random());
            dp.gyroX = dp.gyroY = dp.gyroZ = @(arc4random());
            dp.curTime = arc4random();
            dp.index = @(arc4random());

            [realm transactionWithBlock:^{
                [realm addObject:dp];
            }];
        }
    }];
}

#if 0
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
#endif

@end
