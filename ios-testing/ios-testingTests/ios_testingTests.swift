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
@testable import ios_testing

let kMIL_World_Street_map = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
let kMIL_World_Imagery = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer")
let expectedAccuracy = 0.00001

class ios_testingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultPropertiesOnURL() {
        
        let tiledLayer = AGSArcGISTiledLayer(URL: kMIL_World_Street_map!)
        
        XCTAssertNil(tiledLayer.credential)
        XCTAssertNotNil(tiledLayer.requestConfiguration)
        XCTAssertNotNil(tiledLayer.mapServiceInfo)
        XCTAssertEqual(tiledLayer.attributionText!, "")
        XCTAssertEqual(tiledLayer.layerDescription!, "")
        XCTAssertNil(tiledLayer.fullExtent)
        XCTAssertNil(tiledLayer.spatialReference)
        XCTAssertNil(tiledLayer.loadError)
        
        XCTAssertTrue(tiledLayer.brightness.isNaN)
        XCTAssertTrue(tiledLayer.contrast.isNaN)
        XCTAssertTrue(tiledLayer.gamma.isNaN)
        
        XCTAssertEqual(tiledLayer.name!, "World Street Map")
        XCTAssertTrue(tiledLayer.maxScale.isNaN)
        XCTAssertTrue(tiledLayer.minScale.isNaN)
        XCTAssertEqual(tiledLayer.opacity, 1.0)
        XCTAssertNotEqual(tiledLayer.layerID, 0)
        
        XCTAssertEqual(tiledLayer.URL!.absoluteURL, kMIL_World_Street_map!.absoluteURL)
        XCTAssertEqual(tiledLayer.showInLegend, true)
        XCTAssertTrue(tiledLayer.loadStatus == .NotLoaded)
        XCTAssertEqual(tiledLayer.visible, true)
    }
    
    func testArea_SurveyFoot() {
        let NAD1927ColoradoNorth = AGSSpatialReference(WKID: 26753)
        let cwPolygonBuilder = AGSPolygonBuilder(spatialReference: NAD1927ColoradoNorth)
        cwPolygonBuilder.addPoint(AGSPoint(x:2212788.054, y:395247.022, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2212837.988, y:396395.497, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2214553.750, y:397871.219, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2216779.750, y:397750.500, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2219192.750, y:397123.375, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2219314.250, y:395886.250, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2216638.250, y:393945.562, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2214146.500, y:393428.750, spatialReference: nil))
        cwPolygonBuilder.addPoint(AGSPoint(x:2212788.054, y:395247.022, spatialReference: nil))
        
        //create polygons
        let cwPolygon1 = cwPolygonBuilder.toGeometry()
        let cwArea1 = AGSGeometryEngine.areaOfGeometry(cwPolygon1)
        XCTAssertEqualWithAccuracy(cwArea1, 20417242.209763139486313, accuracy: expectedAccuracy)
        
        let ccwPolygonBuilder = cwPolygonBuilder.ccw().moveBy(221677.750, y: 39588.250)
        let ccwPolygon1 = ccwPolygonBuilder.toGeometry()
        let ccwArea1 = AGSGeometryEngine.areaOfGeometry(ccwPolygon1)
        XCTAssertEqualWithAccuracy(ccwArea1, -20417242.209763139486313, accuracy: expectedAccuracy)
        
        let cwPolygonBuilder2 = AGSPolygonBuilder(spatialReference: NAD1927ColoradoNorth)
        
        //clockwise
        cwPolygonBuilder2.addPoint(AGSPoint(x:2215381.750, y:392714.594, spatialReference: nil))
        cwPolygonBuilder2.addPoint(AGSPoint(x:2216656.000, y:393504.625, spatialReference: nil))
        cwPolygonBuilder2.addPoint(AGSPoint(x:2217958.250, y:393197.844, spatialReference: nil))
        cwPolygonBuilder2.addPoint(AGSPoint(x:2218431.750, y:392371.781, spatialReference: nil))
        cwPolygonBuilder2.addPoint(AGSPoint(x:2216086.500, y:391772.594, spatialReference: nil))
        
        let cwArea2 = AGSGeometryEngine.areaOfGeometry(cwPolygonBuilder2.toGeometry())
        XCTAssertEqualWithAccuracy(cwArea2, 3204203.14587499, accuracy: expectedAccuracy)
        
        let cwcPolygonBuilder2 = cwPolygonBuilder2.ccw().moveBy(221665.000, y: 39319.844)
        let ccwArea2 = AGSGeometryEngine.areaOfGeometry(cwcPolygonBuilder2.toGeometry())
        XCTAssertEqualWithAccuracy(ccwArea2, -3204203.14587499, accuracy: expectedAccuracy)
        
        XCTAssertEqualWithAccuracy(cwArea1+ccwArea1, 0.0, accuracy: expectedAccuracy)
        XCTAssertEqualWithAccuracy(cwArea2+ccwArea2, 0.0, accuracy: expectedAccuracy)
    }
    
    func testBenchmarkBufferOnShortPolyline() {
        let polylineBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.WGS84())
        polylineBuilder.addPoint(AGSPoint(x:-143.963, y:-41.866, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-157.947, y:-21.940, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-165.336, y:11.767, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-145.576, y:40.399, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-124.618, y:47.925, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-81.009, y:51.033, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-59.866, y:29.646, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-32.132, y:8.944, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-39.132, y:-17.686, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-49.601, y:-44.286, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-89.120, y:-62.432, spatialReference: nil))
        polylineBuilder.addPoint(AGSPoint(x:-123.397, y:-57.593, spatialReference: nil))
        let polyline = polylineBuilder.toGeometry()
        
        //***** BUFFER *****
        AGSGeometryEngine.bufferGeometry(polyline, byDistance: 10)
        self.measureBlock{ () -> Void in
            for _ in 1...2500 {
                AGSGeometryEngine.bufferGeometry(polyline, byDistance: 10)
            }
        }
    }
    
    func testLoadObjects() {
        let map = AGSMap()
        let layers = [AGSArcGISMapImageLayer(URL: kMIL_World_Street_map!), AGSArcGISMapImageLayer(URL: kMIL_World_Imagery!)]
        weak var expectation = expectationWithDescription("loadObjects")
        map.basemap!.baseLayers.addObjectsFromArray(layers)
        
        XCTAssertTrue(layers[0].loadStatus == .NotLoaded)
        XCTAssertTrue(layers[1].loadStatus == .NotLoaded)
        
        loadObjects(map.basemap!.baseLayers.asArrayOfLoadables, { (finished) in
            print("Finished: \(finished)")
            expectation?.fulfill()
        })
        
        waitForExpectationsWithTimeout(60.0) { (error) in
            if (error != nil) {
                XCTFail(error!.localizedDescription)
            }
        }
        
//App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure.
//Temporary exceptions can be configured via your app's Info.plist file.
//In your HOST App Info.plist file!!

//        XCTAssertTrue(layers[0].loadStatus == .Loaded)
//        XCTAssertTrue(layers[1].loadStatus == .Loaded)
        XCTAssertEqual(AGSLoadStatusAsString(layers[0].loadStatus), AGSLoadStatusAsString(.Loaded))
        XCTAssertEqual(AGSLoadStatusAsString(layers[1].loadStatus), AGSLoadStatusAsString(.Loaded))
    }
}
