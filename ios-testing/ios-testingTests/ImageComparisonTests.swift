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

let wgs84 = AGSSpatialReference(WKID: 4326)
let kImageServiceLayer_SubLayers_v103 = NSURL(string: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/USA/MapServer")

class ImageComparisonTests: ImageComparisonClass {
    let yellow = UIColor.yellowColor()
    let red = UIColor.redColor()
    let green = UIColor.greenColor()
    let blue = UIColor.blueColor()
    
    func sms(size: CGFloat = 10.0, color: UIColor = UIColor.redColor()) -> AGSSimpleMarkerSymbol {
        return AGSSimpleMarkerSymbol(style: .Circle, color: color, size: size)
    }
    
    func sls(color: UIColor = UIColor.blackColor()) -> AGSSimpleLineSymbol {
        return AGSSimpleLineSymbol(style: AGSSimpleLineSymbolStyle.Solid, color: color, width: 2.0)
    }
    
    func sfs(color: UIColor = UIColor.redColor(), outlineColor: UIColor? = UIColor.blackColor()) -> AGSSimpleFillSymbol {
        if outlineColor == nil {
            return AGSSimpleFillSymbol(style: AGSSimpleFillSymbolStyle.Solid, color: color, outline: nil)
        } else {
            return AGSSimpleFillSymbol(style: AGSSimpleFillSymbolStyle.Solid, color: color, outline: sls(outlineColor!))
        }
    }
    
    override func setUp() {
        super.setUp()
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        vc = storyboard.instantiateViewControllerWithIdentifier("MyStoryboard") as! ViewController
        UIApplication.sharedApplication().keyWindow!.rootViewController = vc
        self.mapView = vc.mapView
        
        self.globalClass.waitSeconds(1.0)
    }
    
    override func tearDown() {
        if self.mapView?.map != nil {
            self.mapView?.map = nil
        }
        XCTAssertNil(self.mapView?.map)
        self.mapView = nil
        
        super.tearDown()
    }
    
    func testSubLayers_ArcGISMapImageLayer() {
        let map = AGSMap()
        let imgLayer = AGSArcGISMapImageLayer(URL: kImageServiceLayer_SubLayers_v103!)
        
        map.basemap!.baseLayers.addObject(imgLayer)
        map.initialViewpoint = poiWGS84.esriCampus(50000000)
        
        self.mapView!.map = map
        if waitForMapToCompleteDrawing(self.mapView!) {return}
        
        let misl0 = imgLayer.mapImageSublayers[0] as! AGSArcGISMapImageSublayer
        let misl1 = imgLayer.mapImageSublayers[1] as! AGSArcGISMapImageSublayer
        let misl2 = imgLayer.mapImageSublayers[2] as! AGSArcGISMapImageSublayer
        let misl3 = imgLayer.mapImageSublayers[3] as! AGSArcGISMapImageSublayer
        assertExportImage(self.mapView, sufix: "1")
        
        misl0.visible = false
        self.globalClass.waitSeconds(self.mapView!, status: .InProgress, sec: 5.0, wait: true)
        assertExportImage(self.mapView, sufix: "2")
        
        misl1.visible = false
        self.globalClass.waitSeconds(self.mapView!, status: .InProgress, sec: 5.0, wait: true)
        assertExportImage(self.mapView, sufix: "3")
        
        misl2.visible = false
        self.globalClass.waitSeconds(self.mapView!, status: .InProgress, sec: 5.0, wait: true)
        assertExportImage(self.mapView, sufix: "4")
        
        misl3.visible = false
        self.globalClass.waitSeconds(self.mapView!, status: .InProgress, sec: 5.0, wait: true)
        assertExportImage(self.mapView, sufix: "5")
    }

    func testZIndex() {
        let gl = AGSGraphicsOverlay()
        let map = AGSMap(basemap: AGSBasemap.streetsBasemap())
        self.mapView.graphicsOverlays.addObject(gl)
        let offset = 0.4
        
        let g1 = AGSGraphic(geometry: AGSPointMake(0.0, 0.0, wgs84), symbol: sms(100.0, color: yellow))
        g1.selected = true
        let g2 = AGSGraphic(geometry: AGSPointMake(offset, offset, wgs84), symbol: sms(100.0, color: red))
        let g3 = AGSGraphic(geometry: AGSPointMake(offset, -offset, wgs84), symbol: sms(100.0, color: green))
        let g4 = AGSGraphic(geometry: AGSPointMake(-offset, -offset, wgs84), symbol: sms(100.0, color: blue))
        g4.selected = true
        let g5 = AGSGraphic(geometry: AGSPointMake(-offset, offset, wgs84), symbol: sms(100.0, color: UIColor.blackColor()))
        gl.graphics.addObject(g1)
        gl.graphics.addObject(g2)
        gl.graphics.addObject(g3)
        gl.graphics.addObject(g4)
        gl.graphics.addObject(g5)
        
        self.mapView.map = map
        
        if waitForMapToCompleteDrawing(self.mapView!) {return}
        if setViewpointCenterScale(self.mapView!, center: gl.extent.center, scale: 5000000) {
            XCTFail("Zoom in failed, exiting UT!")
            return
        }
        if waitForMapToCompleteDrawing(self.mapView!) {return}
        
        XCTAssertEqual(g1.zIndex, 0)
        XCTAssertEqual(g2.zIndex, 0)
        XCTAssertEqual(g3.zIndex, 0)
        XCTAssertEqual(g4.zIndex, 0)
        XCTAssertEqual(g5.zIndex, 0)
        assertExportImage(self.mapView, sufix: "1")
        
        g1.zIndex = 1
        XCTAssertEqual(g1.zIndex, 1)
        XCTAssertEqual(g2.zIndex, 0)
        XCTAssertEqual(g3.zIndex, 0)
        XCTAssertEqual(g4.zIndex, 0)
        XCTAssertEqual(g5.zIndex, 0)
        assertExportImage(self.mapView, sufix: "2")
        
        g2.zIndex = 2
        XCTAssertEqual(g1.zIndex, 1)
        XCTAssertEqual(g2.zIndex, 2)
        XCTAssertEqual(g3.zIndex, 0)
        XCTAssertEqual(g4.zIndex, 0)
        XCTAssertEqual(g5.zIndex, 0)
        assertExportImage(self.mapView, sufix: "3")
        
        g3.zIndex = 3
        XCTAssertEqual(g1.zIndex, 1)
        XCTAssertEqual(g2.zIndex, 2)
        XCTAssertEqual(g3.zIndex, 3)
        XCTAssertEqual(g4.zIndex, 0)
        XCTAssertEqual(g5.zIndex, 0)
        assertExportImage(self.mapView, sufix: "4")
        
        g4.zIndex = 4
        XCTAssertEqual(g1.zIndex, 1)
        XCTAssertEqual(g2.zIndex, 2)
        XCTAssertEqual(g3.zIndex, 3)
        XCTAssertEqual(g4.zIndex, 4)
        XCTAssertEqual(g5.zIndex, 0)
        assertExportImage(self.mapView, sufix: "5")
        
        g5.zIndex = 5
        XCTAssertEqual(g1.zIndex, 1)
        XCTAssertEqual(g2.zIndex, 2)
        XCTAssertEqual(g3.zIndex, 3)
        XCTAssertEqual(g4.zIndex, 4)
        XCTAssertEqual(g5.zIndex, 5)
        assertExportImage(self.mapView, sufix: "1")
        
        if setViewpointCenterScale(self.mapView!, center: gl.extent.center, scale: 3500000) {
            XCTFail("Zoom in failed, exiting UT!")
            return
        }
        if waitForMapToCompleteDrawing(self.mapView!) {return}
        assertExportImage(self.mapView, sufix: "6")
    }
}