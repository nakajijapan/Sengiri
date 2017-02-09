//
//  CaptureViewController.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/19.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Cocoa

class CaptureViewController: NSViewController {

    @IBOutlet weak var recordButton: NSButton!
    @IBAction func recordButtonDidClick(_ sender: RecordButton) {
        
        sender.hide()
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "CaptureViewRecordButtonDidClick"),
            object: self, userInfo:["button": sender]
        )

    }
    
}
