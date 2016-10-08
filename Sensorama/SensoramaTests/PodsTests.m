//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  PodsTests.m
//  Sensorama

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

@end
