//
//  RecordButton.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/20.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Cocoa

class RecordButton: NSButton {

    func hide() {

        self.hidden = true
        
    }
    
    override func performKeyEquivalent(key: NSEvent) -> Bool {

        return true

    }
    
}
