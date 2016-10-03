//
//  SensoramaScreenshots.swift
//  SensoramaScreenshots
//
//  Created by Wojciech Adam Koszek (h) on 03/10/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

import XCTest

class SensoramaScreenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenRecord() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        snapshot("00_Record")
    }

    func testScreenFiles() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()

        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Files"].tap()
        snapshot("01_Files")
    }

//    func testScreenFilesDetail() {
//        let app = XCUIApplication()
//        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
//
//        let tabBarsQuery = app.tabBars
//        tabBarsQuery.buttons["Files"].tap()
//        app.tables.cells.element(boundBy: 0).tap()
//        snapshot("02_Details")
//    }

    func testScreenSettings() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()

        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Settings"].tap()
        snapshot("03_Settings")
    }

}
