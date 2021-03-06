//
//  GetColor.swift
//  Photon
//
//  Created by Haru-tan on 11/01/2019.
//  Copyright © 2019 Haru-tan. All rights reserved.
//

import Foundation
import Cocoa
import Wallpaper
import Witness
import EonilFSEvents
import ORSSerial
import CocoaMQTT

var sendingString = "0"
var rString = "0"
var gString = "0"
var bString = "0"


func getColor() {
    
    //let url = NSWorkspace.shared.desktopImageURL(for: NSScreen.screens[0]) //Old method!
    if let url = try? Wallpaper.get(screen: .main) {

        if let beginImage = CIImage(contentsOf: url[0].absoluteURL) {  //Wallpaper library delivers url as an array, so we're passing the zero index
            
            let extentVector = CIVector(x: beginImage.extent.origin.x, y: beginImage.extent.origin.y, z: beginImage.extent.size.width, w: beginImage.extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage")!
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            filter.setValue(extentVector, forKey: kCIInputExtentKey)
            let preoutputImage = filter.outputImage!  //I would like to filter for non-white colors but this will suffice for now
    
            let filter2 = CIFilter(name: "CIColorControls")!
            filter2.setValue(preoutputImage, forKey: kCIInputImageKey)
            filter2.setValue(7.0, forKey: kCIInputSaturationKey)
            filter2.setValue(1.0, forKey: kCIInputContrastKey)
            let outputImage = filter2.outputImage!
    
            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext(options: [.workingColorSpace: kCFNull])
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
            let rgba = CIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
            let rgb = [rgba.red * 255, rgba.green * 255, rgba.blue * 255]
            let rInt:Int = Int(rgb[0])
            let gInt:Int = Int(rgb[1])
            let bInt:Int = Int(rgb[2])
            rString = String(format: "%03d", rInt)  //Arduino expects each color channel value to be three digits in length
            gString = String(format: "%03d", gInt)
            bString = String(format: "%03d", bInt)
            sendingString = rString + gString + bString + "\n"
            
        } else {
            usleep(100000)
            getColor()
            }
        
    } else {
        usleep(100000)
        getColor()
        }
}
