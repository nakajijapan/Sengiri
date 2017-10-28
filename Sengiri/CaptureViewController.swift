//
//  CaptureViewController.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/19.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Cocoa

class CaptureViewController: NSViewController {
    @IBOutlet weak var recordButton: RecordButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }
    }

    @IBAction func recordButtonDidClick(_ sender: RecordButton) {
        sender.hide()
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "CaptureViewRecordButtonDidClick"),
            object: self, userInfo:["button": sender]
        )
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)

        if (event.keyCode == 49){
            recordButton.hide()
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "CaptureViewRecordButtonDidClick"),
                object: self, userInfo:["button": recordButton]
            )
        }
    }
}
