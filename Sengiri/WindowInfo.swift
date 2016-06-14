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
    
    init(item:Dictionary<NSObject, AnyObject>) {
        super.init()
        
        self.ownerName = item[kCGWindowOwnerName as String] as? String
        self.layer = (item[kCGWindowLayer as String] as! NSNumber).int32Value
        let bounds = item[kCGWindowBounds as String] as! Dictionary<String, CGFloat>
        
        let cgFrame = CGRect(x: bounds["X"]!, y: bounds["Y"]!, width: bounds["Width"]!, height: bounds["Height"]!)

        var frame = NSRectFromCGRect(cgFrame)
        frame.origin = self.convertPosition(frame)
        
        let differencialValue = CGFloat(SengiriCropViewLineWidth - 2)
        let optimizeFrame = NSRect(
            x: frame.origin.x - differencialValue,
            y: frame.origin.y - differencialValue,
            width: frame.width + differencialValue * 2.0,
            height: frame.height + differencialValue * 2.0
        )
        
        self.frame = optimizeFrame
    }
    
    func convertPosition(_ frame:NSRect) -> NSPoint {
        let mainFrame = NSScreen.main()?.frame;
        var convertedPoint = frame.origin
        
        let y = mainFrame!.height - (frame.origin.y + frame.size.height)
        convertedPoint.y = y
        
        return convertedPoint
    }
    
    func isNormalWindow(_ normal:Bool) -> Bool {
        
        if self.ownerName! == "Dock" {
            return false
        }
        
        if normal && self.layer == CGWindowLevelForKey(.normalWindow) {
            return true
        }
        
        if normal && self.layer < CGWindowLevelForKey(.mainMenuWindow) {
            return true
        }
        
        return false
    }
}
