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
    
    override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)

        self.isReleasedWhenClosed = true
        self.displaysWhenScreenProfileChanges = true
        self.backgroundColor = NSColor.clear()
        self.isOpaque = false
        self.hasShadow = false
        self.collectionBehavior = [.fullScreenPrimary]
        
        self.isMovable = true
        self.isMovableByWindowBackground = true
        
        // hide title bar
        self.styleMask = NSBorderlessWindowMask | NSResizableWindowMask
        self.ignoresMouseEvents = false
        

        self.level = Int(CGWindowLevelForKey(.floatingWindow))
        
        
        NotificationCenter.default().addObserver(self, selector: "recordButtonDidClick:", name: "CaptureViewRecordButtonDidClick", object: nil)
        
        self.setFrame(NSRect(x: 200, y: 200, width: 500, height: 500), display: true)

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            self.keyDown(aEvent)
            return aEvent
        }
        
    }
    
    deinit {
        NotificationCenter.default().removeObserver(self, name: "CaptureViewRecordButtonDidClick" as NSNotification.Name, object: nil)
    }

    // MARK: - Notification
    
    func recordButtonDidClick(_ notification:Notification) {

        var frame = self.frame
        frame.size.height += 0.25
        self.setFrame(frame, display: true)
        self.ignoresMouseEvents = true

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func performKeyEquivalent(_ theEvent: NSEvent) -> Bool {
        return false
    }
    
}
