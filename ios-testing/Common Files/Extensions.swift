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
import CoreGraphics
import ArcGIS

#if os(iOS)
    typealias RImage = UIImage
    typealias RColor = UIColor
#else
    typealias RImage = NSImage
    typealias RColor = NSColor
#endif

extension RImage {
    func scaledToSize(size: CGSize) -> RImage {
        
#if os(iOS)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0);
#else
        self.lockFocus()
#endif
        
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
#if os(iOS)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
#else
        let newImage = self
        self.unlockFocus()
#endif
        
        return newImage
    }
    
#if !os(iOS)
    var scale: CGFloat {
    return CGFloat(1.0)
    }
#endif
}

extension RColor {
    var red: CGFloat {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return r
    }
    var green: CGFloat {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return g
    }
    var blue: CGFloat {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return b
    }
    var alpha: CGFloat {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return a
    }
    var brightness: CGFloat {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return RColor.getBrightness(r, green: g, blue: b)
    }
    
    var r: Double {
        return Double(self.red)
    }
    var g: Double {
        return Double(self.green)
    }
    var b: Double {
        return Double(self.blue)
    }
    var a: Double {
        return Double(self.alpha)
    }
    var br: Double {
        return Double(self.brightness)
    }
    
    var R: Int8 {
        return Int8(self.red * 255)
    }
    var G: Int8 {
        return Int8(self.green * 255)
    }
    var B: Int8 {
        return Int8(self.blue * 255)
    }
    var A: Int8 {
        return Int8(self.alpha * 255)
    }
    
    class func getBrightness(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let r = 0.3 * red
        let g = 0.59 * green
        let b = 0.11 * blue
        return CGFloat(r + g + b)
    }
}

extension NSMutableArray {
    var asArrayOfLoadables: [AGSLoadable] {
        //Swift functional programming
        //converts Array to Array
        //In this particular case for each element in the array it returns it is force casted to AGSLoadable
        return self.map({ $0 as! AGSLoadable })
    }
}

extension AGSPolygonBuilder {
    func moveBy(x: Double, y: Double) -> AGSPolygonBuilder {
        let b = AGSPolygonBuilder(polygon: self.toGeometry())
        
        for P in 0...b.parts.count-1 {
            for p in 0...b.parts[P].points.count-1 {
                let pnt = b.parts[P].points[p]
                b.parts[P].setPoint(pnt.toBuilder().offsetByX(x, y: y).toGeometry(), atIndex: p)
            }
        }
        
        return b
    }
    
    func moveTo(x: Double, y: Double) -> AGSPolygonBuilder {
        let b = AGSPolygonBuilder(polygon: self.toGeometry())
        let C = self.extent.center
        
        for P in 0...b.parts.count-1 {
            for p in 0...b.parts[P].points.count-1 {
                let pnt = b.parts[P].points[p]
                b.parts[P].setPoint(pnt.toBuilder().offsetByX(x-C.x, y: y-C.y).toGeometry(), atIndex: p)
            }
        }
        
        return b
    }
    
    func scaleBy(scale: Double) -> AGSPolygonBuilder {
        let b = AGSPolygonBuilder(polygon: self.toGeometry())
        let C = self.extent.center
        
        for P in 0...b.parts.count-1 {
            for p in 0...b.parts[P].points.count-1 {
                let pnt = b.parts[P].points[p]
                b.parts[P].setPoint(AGSPointMake(C.x+(pnt.x-C.x)*scale, C.y+(pnt.y-C.y)*scale, nil), atIndex: p)
            }
        }
        
        return b
    }
    
    func ccw() -> AGSPolygonBuilder {
        let b = AGSPolygonBuilder(polygon: self.toGeometry())
        
        for P in 0...b.parts.count-1 {
            for p in 0...b.parts[P].points.count-1 {
                b.parts[P].setPoint(self.parts[P].pointAtIndex(self.parts[P].pointCount-p), atIndex: p)
            }
        }
        
        return b
    }
}