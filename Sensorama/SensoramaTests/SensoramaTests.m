// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTests.m
//  SensoramaTests
//

#import "SREngine.h"
#import <XCTest/XCTest.h>

@interface SensoramaTests : XCTestCase

@end

@interface SREngine ()

- (void) recordingStopWithPath:(NSString *)path;
- (void) recordingStartWithUpdates:(BOOL)enableUpdates;

@end

@implementation SensoramaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEngineBasic {
    SREngine *engine = [SREngine new];

    NSLog(@"----------------------- ");
    [engine recordingStartWithUpdates:NO];
    [engine recordingStopWithPath:@"/tmp/data.json.bz2"];
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
