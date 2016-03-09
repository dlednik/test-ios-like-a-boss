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

import Foundation
import XCTest
import ArcGIS

class ImageComparisonClass: XCTestCase {
    let globalClass = GlobalTestClass()
    var mapView: AGSMapView!
    var vc:ViewController = ViewController()
    var isDrawing: Bool = false
    var drawStatus: AGSDrawStatus = AGSDrawStatus.Completed
    var refreshCountError = 0
    
    func waitSeconds(mapView: AGSMapView, status: AGSDrawStatus, sec: Double) {
        let initialTime = NSDate()
        let runLoop = NSRunLoop.currentRunLoop()
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

    func getImageWithSufix(sufix: String = "") -> RImage? {
        let imgName = self.name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "-[]"))
        let names = imgName.componentsSeparatedByString(" ")
        let fileName = "TestData/ImageComparisonTests/" + names[0] + "/" + names[1] + sufix
        if let storedImage = NSBundle(forClass: ImageComparisonClass.self).pathForResource(fileName, ofType: "png") {
            return RImage(contentsOfFile: storedImage)
        }
        XCTFail("Image \(fileName).png was not found in Bundle!")
        return nil
    }
    
    func getImageWithName(name: String = "") -> RImage? {
        if let storedImage = NSBundle(forClass: ImageComparisonClass.self).pathForResource("TestData/ImageComparisonTests/" + name, ofType: "png") {
            return RImage(contentsOfFile: storedImage)
        }
        XCTFail("Image \(name).png was not found in Bundle!")
        return nil
    }
    
    func reBindMap(mapView: AGSMapView) {
        print("\rreBINDING MAP!!!")
        let vp = mapView.currentViewpointWithType(.CenterAndScale)
        let map = mapView.map
        mapView.map = nil
        waitSeconds(1.0)
        map?.initialViewpoint = vp
        mapView.map = map
    }
    
    func waitForMapToCompleteDrawing(mapView: AGSMapView, waitFor: Double = 120.0, bWaitStart: Bool = true) -> Bool {
        var bLoop = true
        var ret = false
        var cnt = 1
        
        if mapView.drawStatusChangedHandler == nil {
            self.drawStatus = mapView.drawStatus
            mapView.drawStatusChangedHandler = { (status) in
                let txt = status==AGSDrawStatus.Completed ? "Completed" : "Refreshing"
                NSLog("Map status: \(txt)")
                self.drawStatus = status
            }
        }
        
        while bLoop {
            var bSkip = true
            if bWaitStart && drawStatus == AGSDrawStatus.Completed {
                waitSeconds(mapView, status: AGSDrawStatus.Completed, sec: 10.0)
                if mapView.drawStatus == AGSDrawStatus.Completed {
                    if cnt>0 {
                        cnt--
                        reBindMap(mapView)
                    } else {
                        bLoop = false
                        ret = true
                    }
                    bSkip = false
                }
            }
            
            if bSkip && drawStatus == AGSDrawStatus.InProgress {
                waitSeconds(mapView, status: AGSDrawStatus.InProgress, sec: waitFor)
                if mapView.drawStatus == AGSDrawStatus.InProgress {
                    if cnt>0 {
                        cnt--
                        reBindMap(mapView)
                    } else {
                        bLoop = false
                        ret = true
                    }
                } else {
                    bLoop = false
                }
            } else {
                if cnt>0 {
                    cnt--
                    reBindMap(mapView)
                } else {
                    bLoop = false
                    ret = true
                }
            }
        }
        
        return ret
    }

    func exportImage(mapView: AGSMapView) -> RImage? {
        var retImage: RImage!
        var bExportInProgress = true
        var cnt = 3
        
        while bExportInProgress {
            mapView.exportImageWithCompletion() { (exportedImage, error) in
                if error != nil {
                    XCTFail("imageExport error: \(error!.localizedDescription)")
                } else {
                    retImage = exportedImage
                }
                bExportInProgress = false
            }
            
            let initialTime = NSDate()
            let runLoop = NSRunLoop.currentRunLoop()
            NSLog("Waiting for imageExport, max 30.0 seconds...")
            while(bExportInProgress && initialTime.timeIntervalSinceNow > -10.0) {
                runLoop.runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
            }
            NSLog("Delayed for: \(initialTime.timeIntervalSinceNow)")
            
            if bExportInProgress {
                if cnt>0 {
                    print("\rExport count down: \(cnt--)")
                    reBindMap(mapView)
                    waitForMapToCompleteDrawing(mapView)
                    bExportInProgress = true
                } else {
                    XCTFail("Export image FAILED!!!")
                    bExportInProgress = false
                }
            }
        }
        
        if retImage != nil {
            if retImage.scale > 1 {
                //Normalize image to scale 1.0
                //So that images are same for retina and non retina devices.
                return retImage.scaledToSize(retImage.size)
            }
        }
        return retImage
    }
    
    func setViewpointCenterScale(mapView: AGSMapView, center: AGSPoint, scale: Double, expectationDescription: String = "Expectation") -> Bool {
        var ret = false
        weak var expZoom = expectationWithDescription(expectationDescription)
        mapView.setViewpointCenter(center, scale: scale, completion: { (finished) -> Void in
            NSLog("setViewpointRotation: \(finished)")
            if finished {
                expZoom?.fulfill()
            }
        })
        waitForExpectationsWithTimeout(5.0, handler: { (error) -> Void in
            expZoom = nil
            if (error != nil) {
                XCTFail(error!.localizedDescription)
                ret = true
            }
        })
        expZoom = nil
        return ret
    }
    
    func imageCrop(image: RImage, rect: CGRect) -> RImage {
        let r = CGRectMake(rect.origin.x*image.scale, rect.origin.y*image.scale, rect.size.width*image.scale, rect.size.height*image.scale)
        
        #if os(iOS)
            let imageRef = CGImageCreateWithImageInRect(image.CGImage, r)
            let result = RImage(CGImage:imageRef!, scale:image.scale, orientation:image.imageOrientation)
        #else
            let context = NSGraphicsContext.currentContext()
            let imageCGRect = CGRectMake(0, 0, image.size.width, image.size.height);
            var imageRect = NSRectFromCGRect(imageCGRect)
            let imageRef = image.CGImageForProposedRect(&imageRect, context: context, hints: nil)
            let result = RImage(CGImage: imageRef!, size:image.size)
        #endif
        
        return result
    }
    
    func imageCrop(image: RImage) -> RImage {
        let w = CGFloat(image.size.width / 4)
        let h = CGFloat(image.size.height / 4)
        return imageCrop(image, rect: CGRectMake(w,h,2*w,2*h))
    }
    
    func imageCrop(image: RImage, crop: String? = "center") -> RImage {
        var img = image
        let w = CGFloat(image.size.width / 2)
        let h = CGFloat(image.size.height / 2)
        if crop != nil {
            let c = crop?.lowercaseString
            switch c! {
            case "topleft", "tl":
                img = self.imageCrop(image, rect: CGRectMake(0,0,w,h))
            case "topright", "tr":
                img = self.imageCrop(image, rect: CGRectMake(w,0,w,h))
            case "bottomleft", "bl":
                img = self.imageCrop(image, rect: CGRectMake(0,h,w,h))
            case "bottomright", "br":
                img = self.imageCrop(image, rect: CGRectMake(w,h,w,h))
            default:
                img = imageCrop(image, rect: CGRectMake(w/2,h/2,w,h))
            }
        }
        return img
    }
    
//MARK: assertions
    func assertExportImage(mapView: AGSMapView?, sufix: String) {
        let r = Resemble()
        if let exportedImage = exportImage(mapView!) {
            if let compareImage = getImageWithSufix(sufix) {
                if !r.compare(imageCrop(exportedImage), two: imageCrop(compareImage)) {
                    XCTFail("Images\(sufix) are not same  \(self.name)")
                }
            }
        } else { XCTFail("Image\(sufix) not exported: \(self.name)") }
    }
}
