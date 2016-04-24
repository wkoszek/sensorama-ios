// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTests.m
//  SensoramaTests
//

#import <XCTest/XCTest.h>
#import "JSONModel/JSONModel.h"

#import "SREngine.h"
#import "SRDataModel.h"
#import "SRUnitTestLoop.h"



@interface SensoramaTests : XCTestCase
@property (nonatomic) dispatch_queue_t waitQueue;
@end

@interface SREngine ()

- (void) recordingStopWithPath:(NSString *)path doSync:(BOOL)doSync;
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

- (void)testBasicPointJSONSerialize {
    SRDataPoint *dp = [SRDataPoint new];
    NSLog(@"dp=%@", [dp toDict]);
}

- (void)testBasicPointMake {
    SRDataPoint *dp = [self makeRandomDataPoint];
    SRDataStore *dataStore = [SRDataStore sharedInstance];

    WAIT_INIT();
    dispatch_sync(self.waitQueue, ^{
        [dataStore.realm beginWriteTransaction];
        [dataStore.realm addObject:dp];
        [dataStore.realm commitWriteTransaction];
        WAIT_DONE();
    });
    WAIT_LOOP();
}

- (void)testEngineBasic {
    SREngine __block *engine = [SREngine new];
    int i;

    WAIT_INIT();

    [engine recordingStartWithUpdates:NO];
    for (i = 0; i < 10; i++) {
        [engine sampleUpdate];
    }
    dispatch_sync(self.waitQueue, ^{
        [engine recordingStopWithPath:@"/tmp/data.json.bz2" doSync:NO];
        WAIT_DONE();
    });

    WAIT_LOOP();
}

- (void)testEngineOneHour {
    SREngine *engine = [SREngine new];

    WAIT_INIT();
    [engine recordingStartWithUpdates:NO];
    for (int i = 0; i < 60*60*10; i++) {
        [engine sampleUpdate];
    }
    dispatch_sync(self.waitQueue, ^{
        [engine recordingStopWithPath:@"/tmp/data.json.bz2" doSync:NO];
        WAIT_DONE();
    });

    WAIT_LOOP();
}

- (void)testDatapointBasic {
    RLMRealm *realm = [RLMRealm defaultRealm];
    WAIT_INIT();
    for (int i = 0; i < 10; i++) {
        SRDataPoint *dp = [self makeRandomDataPoint];

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
            SRDataPoint *dp = [self makeRandomDataPoint];
            [dps addObject:dp];
        }
        dispatch_sync(self.waitQueue, ^{
            [realm beginWriteTransaction];
            [realm addOrUpdateObjectsFromArray:dps];
            [realm commitWriteTransaction];
            WAIT_DONE();
        });

        NSLog(@"%d/%d", ti, transNumber);
    }
    WAIT_LOOP();
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
        [points addObject:dp];
    }
    XCTAssert([points count] == howMany);
    return points;
}

- (void)testDataStoreBasic {
    NSArray *points = [self makeDataPointsWithFileId:13 howMany:10];

    RLMRealm *realm = [[SRDataStore sharedInstance] realm];


    dispatch_sync(self.waitQueue, ^{
        [realm beginWriteTransaction];
#if 0
        [realm addObject:points[0]];
        [realm addObject:points[1]];
        [realm addObject:points[2]];
#else
        [realm addOrUpdateObjectsFromArray:points];
#endif
        [realm commitWriteTransaction];
    });

    RLMResults<SRDataPoint *> *dataPoints = [SRDataPoint objectsWhere:@"fileId = 13"];

    XCTAssert([dataPoints count] == 10);
}

- (void)testBasicPointJSONSerialize {
    SRDataPoint *dp = [SRDataPoint new];
    NSLog(@"dp=%@", [dp toDict]);
}


@end
