//
//  WindowInfo.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/24.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Foundation
import Cocoa

struct WindowInfo {
    var order: Int?
    var windowID: CGWindowID?
    var windowName = ""
    var ownerName = ""
    var layer: Int32 = 0
    var frame = NSRect.zero

    private var directDisplayID: CGDirectDisplayID?
    private let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
    lazy private var quartzScreenFrame: CGRect? = {
        return CGDisplayBounds(self.directDisplayID!)
    }()

    func directDisplayID(from frame: CGRect) -> CGDirectDisplayID {
        let unsafeDirectDisplayID = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: 1)
        unsafeDirectDisplayID.pointee = 1
        CGGetDisplaysWithRect(frame, 2, unsafeDirectDisplayID, nil)
        let directDisplayID = unsafeDirectDisplayID.pointee as CGDirectDisplayID
        return directDisplayID
    }

    init(item: [String: AnyObject]) {

        windowName = item[kCGWindowName.toString] as? String ?? ""
        ownerName = item[kCGWindowOwnerName.toString] as? String ?? ""
        layer = (item[kCGWindowLayer.toString] as! NSNumber).int32Value
        let bounds = item[kCGWindowBounds.toString] as! Dictionary<String, CGFloat>
        
        let cgFrame = NSRect(
            x: bounds["X"]!, y: bounds["Y"]!, width: bounds["Width"]!, height: bounds["Height"]!
        )

        var windowFrame = NSRectFromCGRect(cgFrame)
        directDisplayID = directDisplayID(from: windowFrame)
        windowFrame.origin = convertPosition(windowFrame)

        let differencialValue = SengiriCropViewLineWidth - CGFloat(2)
        let optimizeFrame = NSRect(
            x: windowFrame.origin.x - differencialValue,
            y: windowFrame.origin.y - differencialValue,
            width: windowFrame.width + differencialValue * 2.0,
            height: windowFrame.height + differencialValue * 2.0
        )

        frame = optimizeFrame
    }
    
    func convertPosition(_ frame:NSRect) -> NSPoint {
        var convertedPoint = frame.origin
        let y = mainDisplayBounds.height - frame.height - frame.origin.y
        convertedPoint.y = y
        return convertedPoint
    }
    
    func isNormalWindow(_ normal:Bool) -> Bool {
        if ownerName == "Dock" {
            return false
        }
        
        if normal && layer == CGWindowLevelForKey(.normalWindow) {
            return true
        }
        
        if normal && layer < CGWindowLevelForKey(.mainMenuWindow) {
            return true
        }
        return false
    }
}
