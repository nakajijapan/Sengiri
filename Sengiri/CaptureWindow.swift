//
//  CaptureWindow.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/19.
//  Copyright © 2016 nakajijapan. All rights reserved.
//
import Foundation
import Cocoa
import CoreGraphics

class CaptureWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, `defer`: flag)

        self.releasedWhenClosed = true
        self.displaysWhenScreenProfileChanges = true
        self.backgroundColor = NSColor.clearColor()
        self.opaque = false
        self.hasShadow = false
        self.collectionBehavior = [.FullScreenPrimary]
        
        self.movable = true
        self.movableByWindowBackground = true
        
        // hide title bar
        self.styleMask = NSBorderlessWindowMask | NSResizableWindowMask
        self.ignoresMouseEvents = false
        

        self.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recordButtonDidClick:", name: "CaptureViewRecordButtonDidClick", object: nil)
        
        self.setFrame(NSRect(x: 200, y: 200, width: 500, height: 500), display: true)

        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { (aEvent) -> NSEvent? in
            self.keyDown(aEvent)
            return aEvent
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CaptureViewRecordButtonDidClick", object: nil)
    }

    // MARK: - Notification
    
    func recordButtonDidClick(notification:NSNotification) {

        var frame = self.frame
        frame.size.height += 0.25
        self.setFrame(frame, display: true)
        self.ignoresMouseEvents = true

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func performKeyEquivalent(theEvent: NSEvent) -> Bool {
        return false
    }
    
}
