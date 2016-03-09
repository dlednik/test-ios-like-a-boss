//
// Copyright 2016 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

import XCTest

class DownloadTileCacheUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func waitSeconds(sec: Double) {
        let initialTime = NSDate()
        let runLoop = NSRunLoop.currentRunLoop()
        NSLog("Delay for \(sec) seconds")
        while(initialTime.timeIntervalSinceNow > -sec) {
            runLoop.runUntilDate(NSDate(timeIntervalSinceNow: 1))
        }
        NSLog("Delayed[\(sec)]: \(initialTime.timeIntervalSinceNow)")
    }
    
    func testLabels() {
        let app = XCUIApplication()
        XCTAssertTrue(app.staticTexts["How many scale levels?"].exists)
        XCTAssertTrue(app.staticTexts["Please choose a scale level"].exists)
        XCTAssertTrue(app.buttons["Estimate"].exists)
        XCTAssertTrue(app.buttons["Download"].exists)
    }
    
    func testLOD() {
        let app = XCUIApplication()
        let steppersQuery = app.steppers
        let incrementButton = steppersQuery.buttons["Increment"]
        incrementButton.tap()
        let tb = app.staticTexts.elementMatchingType(.Any, identifier: "LOD")
        XCTAssertEqual(tb.label, "1")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "2")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "3")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "4")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "5")
        
        let decrementButton = steppersQuery.buttons["Decrement"]
        decrementButton.tap()
        XCTAssertEqual(tb.label, "4")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "3")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "4")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "5")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "6")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "7")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "8")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "9")
        XCTAssertFalse(incrementButton.enabled)
        incrementButton.tap()
        XCTAssertEqual(tb.label, "9")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "8")
        XCTAssertTrue(incrementButton.enabled)
        decrementButton.tap()
        XCTAssertEqual(tb.label, "7")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "6")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "5")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "4")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "3")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "2")
        decrementButton.tap()
        XCTAssertEqual(tb.label, "1")
        XCTAssertFalse(decrementButton.enabled)
        decrementButton.tap()
        XCTAssertEqual(tb.label, "1")
        incrementButton.tap()
        XCTAssertEqual(tb.label, "2")
        XCTAssertTrue(decrementButton.enabled)
    }
    
    func testEstimateTPK() {
        let app = XCUIApplication()
        let incrementButton = app.steppers.buttons["Increment"]
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        app.buttons["Estimate"].tap()
        XCTAssertTrue(app.otherElements["Estimating\n size"].exists)
        
        waitSeconds(2.0)
//        XCTAssertTrue(app.otherElements["Estimated size:\n4.3 MB / 261 tiles"].exists)
        
        waitSeconds(2.0)
        let er = app.staticTexts.elementMatchingType(.Any, identifier: "estimateResults")
        XCTAssertEqual(er.label, "4.3 MB / 261 tiles")
    }
    
    func testDowloadTPK() {
        let app = XCUIApplication()
        let incrementButton = app.steppers.buttons["Increment"]
        let mapView = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1)
        
        mapView.doubleTap()
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        app.buttons["Download"].tap()
        
        waitSeconds(15.0)
        app.alerts["Download Complete"].collectionViews.buttons["Ok"].tap()
        
        mapView.pinchWithScale(0.25, velocity: -1.0)
        
        mapView.doubleTap()
        mapView.doubleTap()
        mapView.doubleTap()
        mapView.doubleTap()
        mapView.doubleTap()
        
        
    }
}
