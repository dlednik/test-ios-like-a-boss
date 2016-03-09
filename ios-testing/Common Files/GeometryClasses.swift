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
import ArcGIS

class pointsWGS84 {
    static func zero() -> AGSPoint {
        return AGSPoint(x: 0, y:0, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func greenwich() -> AGSPoint {
        return AGSPoint(x: 0, y:51.4772, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func esriCampus(offset: Double = 0) -> AGSPoint {
        return AGSPoint(x: -117.1958 + offset, y:34.0568, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func toronto() -> AGSPoint {
        return AGSPoint(x: -79.3784148, y:43.5837554, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func dateLine() -> AGSPoint {
        return AGSPoint(x: -179.9, y:0, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func capeTown(frame: Double = 0) -> AGSPoint {
        return AGSPoint(x: -341.5 + frame * 360.0, y:-34, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func grandCanyon() -> AGSPoint {
        return AGSPoint(x: -112.1129972, y:36.1069652, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func colorado() -> AGSPoint {
        return AGSPoint(x: -105.550567, y:38.9979339, spatialReference: AGSSpatialReference.WGS84())
    }
    
    static func paris() -> AGSPoint {
        return AGSPoint(x: 2.354276, y:48.860526, spatialReference: AGSSpatialReference.WGS84())
    }
}

class poiWGS84 {
    static func zero(atScale: Double = 10000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.zero(), scale: atScale)
    }
    
    static func greenwich(atScale: Double = 10000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.greenwich(), scale: atScale)
    }
    
    static func esriCampus(atScale: Double = 10000, offset: Double = 0) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.esriCampus(offset), scale: atScale)
    }
    
    static func toronto(atScale: Double = 10000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.toronto(), scale: atScale)
    }
    
    static func dateLine(atScale: Double = 1000000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.dateLine(), scale: atScale)
    }
    
    static func capeTown(atScale: Double = 3000000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.capeTown(), scale: atScale)
    }
    
    static func grandCanyon(atScale: Double = 300000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.grandCanyon(), scale: atScale)
    }
    
    static func colorado(atScale: Double = 1000000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.colorado(), scale: atScale)
    }
    
    static func paris(atScale: Double = 125000) -> AGSViewpoint {
        return AGSViewpoint(center: pointsWGS84.paris(), scale: atScale)
    }
}