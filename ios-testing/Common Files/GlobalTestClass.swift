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
//

import XCTest
import ArcGIS

class GlobalTestClass: NSObject, AGSAuthenticationManagerDelegate {
    var testTimeOut: Double
    
    var expectedAccuracy: Double {
        get {
            return 0.00001
        }
    }
    
    func funcName(name: String) -> String {
        let funcName = name.componentsSeparatedByString(" ")
        return funcName[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "]"))
    }
    
    override init() {
        testTimeOut = 180.0
    }
    
    func waitSeconds(mapView: AGSMapView, status: AGSDrawStatus, sec: Double, wait: Bool = false) {
        let initialTime = NSDate()
        let runLoop = NSRunLoop.currentRunLoop()
        if wait {
            while((mapView.drawStatus != status) && initialTime.timeIntervalSinceNow > -sec) {
                runLoop.runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
            }
        }
        NSLog("Delay for MAXIMUM of \(sec) seconds")
        while((mapView.drawStatus == status) && initialTime.timeIntervalSinceNow > -sec) {
            runLoop.runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
        }
        NSLog("Delayed[\(sec)]: \(initialTime.timeIntervalSinceNow)")
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
    
    @objc func authenticationManager(authenticationManager: AGSAuthenticationManager, didReceiveAuthenticationChallenge challenge: AGSAuthenticationChallenge) {
        if(challenge.type == AGSAuthenticationChallengeType.UntrustedHost) {
            challenge.trustHostAndContinue()
        }
        else {
            XCTFail("Authentication Challenge should not be issued")
        }
    }
    
    func trustHost() {
        AGSAuthenticationManager.sharedAuthenticationManager().delegate = self
    }
}
