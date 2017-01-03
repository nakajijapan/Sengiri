//
//  PreferenceViewController.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/21.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import RxBlocking

class PreferenceViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var frameCountTextField: NSTextField!
    @IBOutlet weak var delayTimeTextField: NSTextField!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let secondPerFrame = UserDefaults.standard.float(forKey: "GifSecondPerFrame")
        self.frameCountTextField.doubleValue = Double(Int(secondPerFrame * 1000.0)) * 0.001
        
        let delayTime = UserDefaults.standard.double(forKey: "GifDelayTime")
        self.delayTimeTextField.doubleValue = Double(Int(delayTime * 1000.0)) * 0.001

        frameCountTextField.rx_text.subscribeNext { (text) -> Void in
            UserDefaults.standard().set(text.floatValue, forKey: "GifSecondPerFrame")
            }.addDisposableTo(self.disposeBag)

        
        delayTimeTextField.rx_text.subscribeNext { (text) -> Void in
            UserDefaults.standard().set(text.floatValue, forKey: "GifDelayTime")
            }.addDisposableTo(self.disposeBag)
        

    }

}
