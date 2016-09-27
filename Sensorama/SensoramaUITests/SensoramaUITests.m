// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaUITests.m
//  SensoramaUITests
//

#import <XCTest/XCTest.h>

@interface SensoramaUITests : XCTestCase

@end

@implementation SensoramaUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testTabRecord {
    XCUIElement *element = [[[[[[[[[[[XCUIApplication alloc] init] childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element;
    [element tap];
}

- (void) testTabFiles {
    XCUIElementQuery *tabBarsQuery = [[XCUIApplication alloc] init].tabBars;
    [tabBarsQuery.buttons[@"Files"] tap];
    [tabBarsQuery.buttons[@"Record"] tap];
}

- (void) testTabSettings {
    XCUIElementQuery *tabBarsQuery = [[XCUIApplication alloc] init].tabBars;
    [tabBarsQuery.buttons[@"Settings"] tap];
    [tabBarsQuery.buttons[@"Record"] tap];
}

- (void) testTabSlideBackAndForth {
    XCUIElementQuery *tabBarsQuery = [[XCUIApplication alloc] init].tabBars;
    XCUIElement *recordButton = tabBarsQuery.buttons[@"Record"];
    XCUIElement *filesButton = tabBarsQuery.buttons[@"Files"];
    XCUIElement *settingsButton = tabBarsQuery.buttons[@"Settings"];

    [recordButton tap];
    [filesButton tap];
    [settingsButton tap];

    [filesButton tap];
    [recordButton tap];

    [filesButton tap];
    [settingsButton tap];

    [recordButton tap];
}

- (void) helperRemoveFirstFile {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tabBars.buttons[@"Files"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [[tablesQuery.cells elementAtIndex:0] tap];
    [tablesQuery.staticTexts[@"Delete"] tap];
    [app.alerts[@"Will delete file"].buttons[@"Yes"] tap];
}

- (void) testRemoveFirstFile {
    [self helperRemoveFirstFile];
}

- (void) testRemoveAllFiles {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tabBars.buttons[@"Files"] tap];

    XCUIElementQuery *tablesQuery = app.tables;
    NSInteger count = [tablesQuery.staticTexts count];

    for (int i = 0; i < count; i++) {
        [self helperRemoveFirstFile];
    }
}

@end
