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


// Port of Resemble.js image compare library
// James Cryer / Huddle 2014
// URL: https://github.com/Huddle/Resemble.js


import Foundation
import CoreGraphics

public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
    
    init (rcolor: RColor) {
        a = UInt8(Int(rcolor.alpha * 255.0))
        r = UInt8(Int(rcolor.red * 255.0))
        g = UInt8(Int(rcolor.green * 255.0))
        b = UInt8(Int(rcolor.blue * 255.0))
    }
    
    var hex: String {
        let R = String(r, radix: 16, uppercase: true)
        let G = String(g, radix: 16, uppercase: true)
        let B = String(b, radix: 16, uppercase: true)
        return "#\(R)\(G)\(B)"
    }
}

class Resemble {
    var pixelTransparency = 1.0
    var ignoreColors = false
    
    var largeImageThreshold = 1200
    let tolerance = [
        "red": 0.0625,
        "green": 0.0625,
        "blue": 0.0625,
        "alpha": 0.0625,
        "minBrightness": 0.0625,
        "maxBrightness": 0.9375
    ]
    
    internal func getBrightness(r: UInt8, g: UInt8, b: UInt8) -> Double {
        return getBrightness(CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
    
    internal func getBrightness(r: Int8, g: Int8, b: Int8) -> Double {
        return getBrightness(CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
    
    internal func getBrightness(r: CGFloat, g: CGFloat, b: CGFloat) -> Double {
        return Double(RColor.getBrightness(r, green: g, blue: b))
    }
    
    internal func getBrightness(color: PixelData) -> Double {
        return Double(getBrightness(color.r, g: color.g, b: color.b))
    }
    
    internal func isColorSimilar(a: Double, b: Double, color: String) -> Bool {
        
        let absDiff = abs(a - b)
        
        if absDiff < tolerance[color] {
            return true
        } else {
            return false
        }
    }
    
    internal func isColorSimilar(a: UInt8, b: UInt8, color: String) -> Bool {
        
        let absDiff = abs(Double(a) - Double(b))/255.0
        
        if absDiff < tolerance[color] {
            return true
        } else {
            return false
        }
    }
    
    internal func isPixelBrightnessSimilar(d1: PixelData, d2: PixelData) -> Bool {
        let alpha = isColorSimilar(d1.a, b: d2.a, color: "alpha")
        let br1 = getBrightness(d1)
        let br2 = getBrightness(d2)
        let brightness = isColorSimilar(br1, b: br2, color: "minBrightness")
        return brightness && alpha
    }
    
    internal func isRGBSame(d1: PixelData, d2: PixelData) -> Bool {
        let red = d1.r == d2.r
        let green = d1.g == d2.g
        let blue = d1.b == d2.b
        return red && green && blue
    }
    
    internal func isRGBSimilar(d1: PixelData, d2: PixelData) -> Bool {
        let red = isColorSimilar(d1.r, b: d2.r, color: "red")
        let green = isColorSimilar(d1.g, b: d2.g, color: "green")
        let blue = isColorSimilar(d1.b, b: d2.b, color: "blue")
        let alpha = isColorSimilar(d1.a, b: d2.a, color: "alpha")
        
        return red && green && blue && alpha
    }
    
    internal func isContrasting(d1: RColor, d2: RColor) -> Bool {
        return abs(d1.br - d2.br) > tolerance["maxBrightness"]
    }
    
    internal func pixelColor(context: CGContextRef, x: Int, y: Int, width: Int) -> RColor {
        // Now we can get a pointer to the image data associated with the bitmap context.
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafePointer<UInt8>(data)
        let offset = 4 * ((Int(width) * y) + x)
        let alphaValue = dataType[offset]
        let redColor = dataType[offset+1]
        let greenColor = dataType[offset+2]
        let blueColor = dataType[offset+3]
        let redFloat = CGFloat(redColor)/255.0
        let greenFloat = CGFloat(greenColor)/255.0
        let blueFloat = CGFloat(blueColor)/255.0
        let alphaFloat = CGFloat(alphaValue)/255.0
        return RColor(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)
    }
    
    internal func pixelArray(img: RImage) -> [PixelData] {
        var pixels = [PixelData]()
        #if os(iOS)
            let imageRef = img.CGImage
        #else
            let imageRef = CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithData(img.TIFFRepresentation as! CFDataRef, nil)!, 0, nil)
        #endif
        
        //Get image width, height
        let pixelsWide = CGImageGetWidth(imageRef)
        let pixelsHigh = CGImageGetHeight(imageRef)
        // Declare the number of bytes per row. Each pixel in the bitmap in this example is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits per component. Regardless of what the source image format is (CMYK, Grayscale, and so on) it will be converted over to the format  specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, Int(pixelsWide), Int(pixelsHigh), Int(8), Int(bitmapBytesPerRow), colorSpace, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), imageRef)
        
        for (var verticalPos=0; verticalPos<Int(pixelsHigh); verticalPos++){
            for (var horizontalPos=0; horizontalPos<Int(pixelsWide); horizontalPos++){
                pixels.append(PixelData(rcolor: pixelColor(context!, x: horizontalPos, y: verticalPos, width: Int(pixelsWide))))
            }
        }
        
        free(bitmapData)
        return pixels
    }
    
    internal func analyseImages(img1: RImage, img2: RImage) -> Double {
        var pixelArray1 = pixelArray(img1)
        var pixelArray2 = pixelArray(img2)
        
        let width = img1.size.width * img1.scale
        let height = img1.size.height * img1.scale
        
        var mismatchCount = 0
        let inc = 1
        
        //        if(!!largeImageThreshold && ignoreAntialiasing && (width > largeImageThreshold || height > largeImageThreshold)) {
        //            inc = 2
        //        }
        
        for (var y=0; y<Int(height); y+=inc){
            for (var x=0; x<Int(width); x+=inc){
                let offset = (Int(width) * y + x)
                let pixel1 = pixelArray1[offset]
                let pixel2 = pixelArray2[offset]
                pixelArray2[offset] = PixelData(rcolor: RColor.blackColor())
                
                if (ignoreColors){
                    if( !isPixelBrightnessSimilar(pixel1, d2: pixel2) ){
                        mismatchCount++
                        pixelArray1[offset] = PixelData(rcolor: RColor.redColor())
                        pixelArray2[offset] = PixelData(rcolor: RColor.redColor())
                    }
                } else if( !isRGBSimilar(pixel1, d2: pixel2) ){
                    mismatchCount++
                    pixelArray1[offset] = PixelData(rcolor: RColor.redColor())
                    pixelArray2[offset] = PixelData(rcolor: RColor.redColor())
                }
            }
        }
        
        let diff = Double(mismatchCount*inc) * 100.0 / Double(height*width)
        if diff>0.002 {
            let debugImage = imageFromARGB32Bitmap(pixelArray1, width: Int(width), height: Int(height))
            let maskImage = imageFromARGB32Bitmap(pixelArray2, width: Int(width), height: Int(height))
            print("Image pixels mismatch: \(mismatchCount)")
        }
        return diff
    }
    
    func compare(one: RImage, two: RImage) -> Bool {
        if ((one.size.width * one.scale == two.size.width * two.scale) && (one.size.height * one.scale == two.size.height * two.scale)) {
            let diff = analyseImages(one, img2: two)
            NSLog("Image difference: \(diff)%")
            if diff < 0.002 {
                return true
            }
        }
        return false
    }
    
    func imageFromARGB32Bitmap(pixels:[PixelData], width: Int, height: Int)-> RImage {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let bitsPerComponent:Int = 8
        let bitsPerPixel:Int = 32
        
        assert(pixels.count == Int(width * height))
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProviderCreateWithCFData(
            NSData(bytes: &data, length: data.count * sizeof(PixelData))
        )
        
        let cgim = CGImageCreate(
            width,
            height,
            bitsPerComponent,
            bitsPerPixel,
            width * Int(sizeof(PixelData)),
            rgbColorSpace,
            bitmapInfo,
            providerRef,
            nil,
            true,
            .RenderingIntentDefault
        )
        #if os(iOS)
            return RImage(CGImage: cgim!)
        #else
            return RImage(CGImage: cgim!, size: NSSize.init(width: width, height: height))
        #endif
    }
}