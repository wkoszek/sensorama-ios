//
//  PodsTests.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <XCTest/XCTest.h>

#import "SRDataPoint.h"

@interface Bleh : JSONModel
@property (nonatomic) SRDataPoint *point;
@end
@implementation Bleh
@end

@interface PodsTests : XCTestCase

@end

@implementation PodsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJSONSerialize {
    Bleh *bleh = [Bleh new];
    bleh.point = [SRDataPoint new];
    NSString *string = [bleh toJSONString];
    NSLog(@"JSON string=%@", string);
}

@end
