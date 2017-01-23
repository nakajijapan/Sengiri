//
//  WindowInfo.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/24.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Foundation
import Cocoa

class WindowInfo:NSObject {
    var order:Int?
    var windowID:CGWindowID?
    var windowName:String?
    var ownerName:String?
    var	layer:Int32?
    var frame:NSRect?
    
    func toString(cfstring: CFString) -> String {
        let string = cfstring as NSString
        return string as String
    }
    
    init(item: [String: AnyObject]) {
        super.init()
        
        ownerName = item[kCGWindowOwnerName.toString] as? String
        layer = (item[kCGWindowLayer.toString] as! NSNumber).int32Value
        let bounds = item[kCGWindowBounds.toString] as! Dictionary<String, CGFloat>
        
        let cgFrame = CGRect(x: bounds["X"]!, y: bounds["Y"]!, width: bounds["Width"]!, height: bounds["Height"]!)

        var frame = NSRectFromCGRect(cgFrame)
        frame.origin = convertPosition(frame)
        
        let differencialValue = CGFloat(SengiriCropViewLineWidth - 2)
        let optimizeFrame = NSRect(
            x: frame.origin.x - differencialValue,
            y: frame.origin.y - differencialValue,
            width: frame.width + differencialValue * 2.0,
            height: frame.height + differencialValue * 2.0
        )
        
        frame = optimizeFrame
    }
    
    func convertPosition(_ frame:NSRect) -> NSPoint {
        let mainFrame = NSScreen.main()?.frame;
        var convertedPoint = frame.origin
        
        let y = mainFrame!.height - (frame.origin.y + frame.size.height)
        convertedPoint.y = y
        
        return convertedPoint
    }
    
    func isNormalWindow(_ normal:Bool) -> Bool {
        
        if ownerName! == "Dock" {
            return false
        }
        
        if normal && layer == CGWindowLevelForKey(.normalWindow) {
            return true
        }
        
        if normal && layer! < CGWindowLevelForKey(.mainMenuWindow) {
            return true
        }
        
        return false
    }
}
