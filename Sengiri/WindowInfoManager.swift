//
//  WindowInfoManager.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/24.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Foundation

class WindowInfoManager {
    
    class func windowListAboveWindowID(_ windowID:CGWindowID) -> [WindowInfo] {

        let windowInfosRef = CGWindowListCopyWindowInfo(
            [CGWindowListOption.optionOnScreenOnly, CGWindowListOption.optionOnScreenBelowWindow],
            windowID
        )
        var items: [WindowInfo] = []
        
        for i in 0..<CFArrayGetCount(windowInfosRef) {

            let lineUnsafePointer: UnsafeRawPointer = CFArrayGetValueAtIndex(windowInfosRef, i)
            let lineRef = unsafeBitCast(lineUnsafePointer, to: CFDictionary.self)
            let dic = lineRef as Dictionary<NSObject, AnyObject>
            
            let info = WindowInfo(item: dic as! [String : AnyObject])
            
            items.append(info)
        }
        
        return items
    }
    
    class func topWindowInfo() -> WindowInfo? {
        var topWindow:WindowInfo?
        let items = self.windowListAboveWindowID(CGWindowID(0))
        
        for i in 0..<items.count {
            
            if items[i].isNormalWindow(true) {
                
                let item = items[i]
                let frame = item.frame
                if frame.width > 16.0 && frame.height > 16.0 {
                    topWindow = item
                    break
                }
                
            }
        }
        
        return topWindow
    }
    
}
