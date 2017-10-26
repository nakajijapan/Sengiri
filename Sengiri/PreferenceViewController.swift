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
        frameCountTextField.doubleValue = Double(Int(secondPerFrame * 1000.0)) * 0.001
        
        let delayTime = UserDefaults.standard.double(forKey: "GifDelayTime")
        delayTimeTextField.doubleValue = Double(Int(delayTime * 1000.0)) * 0.001

        frameCountTextField.rx.text.subscribe(onNext: { (text) in
            guard let text = text else { return }
            UserDefaults.standard.set(text.floatValue, forKey: "GifSecondPerFrame")
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        delayTimeTextField.rx.text.subscribe(onNext: { (text) in
            guard let text = text else { return }
            UserDefaults.standard.set(text.floatValue, forKey: "GifDelayTime")
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }
}
