//
//  AppDelegate.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/17.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreMedia
import CoreVideo
import QuartzCore
import RegiftOSX

let SengiriHomePath = "\(NSHomeDirectory())/Pictures"
let SengiriSavePath = "\(SengiriHomePath)/\(Bundle.main.bundleIdentifier!)"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var mainMenuItem: NSMenuItem!

    var statusItem:NSStatusItem?
    var captureController:CaptureWindowController? = nil
    var preferenceWindowController:NSWindowController? = nil
    // image
    var captureSession:AVCaptureSession!
    var videoStillImageOutput:AVCaptureStillImageOutput!
    // movie
    var videoMovieFileOutput:AVCaptureMovieFileOutput!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // create working directory
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: "\(SengiriSavePath)", withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("failed to make directory. error: \(error.description)")
        }
        
        // initialize default setting
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recordButtonDidClick(_:)),
            name: NSNotification.Name(rawValue: "CaptureViewRecordButtonDidClick"),
            object: nil
        )

        let frameCount = UserDefaults.standard.double(forKey: "GifSecondPerFrame")
        if frameCount == 0 {
            UserDefaults.standard.set(0.1, forKey: "GifSecondPerFrame")
        }

        let delayTime = UserDefaults.standard.float(forKey: "GifDelayTime")
        if delayTime == 0.0 {
            UserDefaults.standard.set(0.1, forKey: "GifDelayTime")
        }

        let compressionRate = UserDefaults.standard.float(forKey: "GifCompressionRate")
        if compressionRate == 0.0 {
            UserDefaults.standard.set(0.5, forKey: "GifCompressionRate")
        }
        
        menu.delegate = self

    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "CaptureViewRecordButtonDidClick"),
            object: nil
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

// MARK: - Main Menu Actions

extension AppDelegate {
    
    @IBAction func mainMenuItemDidClick(_ sender: AnyObject) {
        menuItemForCropRecordDidClick(NSMenuItem())
    }
    
    @IBAction func mainMenuItemForCropWindowToTopWindowDidClic(_ sender: AnyObject) {
        if captureController == nil {
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CaptureWindowController")) as! CaptureWindowController
            captureController = windowController

        }
        
        if let windowInfo = WindowInfoManager.topWindowInfo() {
            let frame = windowInfo.frame
            captureController?.window?.setFrame(frame, display: true, animate: true)
        }

        captureController?.showWindow(nil)
        captureController?.window?.makeKey()
    }
    
    @IBAction func mainMenuForStopDidClick(_ sender: AnyObject) {
        menuItemForStopDidClick(NSMenuItem())
    }

}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {

    func menuWillOpen(_ menu: NSMenu) {
        let progressIndicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 16, height: 16))
        progressIndicator.style = NSProgressIndicator.Style.spinning
        progressIndicator.startAnimation(nil)
        progressIndicator.controlSize = NSControl.ControlSize.small
        progressIndicator.isDisplayedWhenStopped = false
        statusItem!.view = progressIndicator
        
        menuItemForStopDidClick(NSMenuItem())
    }

}

// MARK: - NSMenu Actions

extension AppDelegate {

    func menuItemForCropRecordDidClick(_ sender: NSMenuItem) {
        
        if captureController == nil {
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CaptureWindowController")) as! CaptureWindowController
            captureController = windowController
        }

        captureController!.showWindow(nil)
        captureController?.window?.makeKey()
        
    }
    
    func menuItemForStopDidClick(_ sender: NSMenuItem) {

        captureController?.window?.close()
        captureController?.close()
        captureController = nil // assign nil because some capture window opens when capture window open in second time
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AppDelegateStopMenuDidClick"), object: self, userInfo:nil)
        
        if videoMovieFileOutput == nil {
            return
        }
        if videoMovieFileOutput.isRecording {
            videoMovieFileOutput.stopRecording()
            captureSession.stopRunning()
        }
        
    }
    
    @IBAction func mainMenuItemForPreferenceDidClick(_ sender: NSMenuItem) {
        
        if preferenceWindowController == nil {
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "PreferenceWindowController"), bundle: nil)
            let windowController = storyBoard.instantiateInitialController() as! NSWindowController
            windowController.showWindow(self)
            preferenceWindowController = windowController
        }

        preferenceWindowController!.showWindow(nil)
        preferenceWindowController?.window?.makeKey()
        
    }

}

// MARK: - Notifications

extension AppDelegate {

    @objc func recordButtonDidClick(_ button:NSButton) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem!.highlightMode = true
        statusItem!.menu = menu
        statusItem!.image = NSImage(named: NSImage.Name(rawValue: "icon_stop"))

        prapareVideoScreen()
    }

    var currentDisplayID: CGDirectDisplayID {
        guard let screen = captureController?.window?.screen else {
            fatalError("Can not find screen info")
        }

        guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID else {
            fatalError("Can not find screen device description")
        }

        return displayID
    }

    var currentSize: NSSize {
        guard let screen = captureController?.window?.screen else {
            fatalError("Can not find screen info")
        }

        guard let size = screen.deviceDescription[NSDeviceDescriptionKey.size] as? NSSize else {
            fatalError("Can not find screen device description")
        }
        return size
    }
    
    func prapareVideoScreen() {
        videoMovieFileOutput = AVCaptureMovieFileOutput()

        let captureInput = AVCaptureScreenInput(displayID: currentDisplayID)
        captureSession = AVCaptureSession()

        if captureSession.canAddInput(captureInput) {
            captureSession.addInput(captureInput)
        }

        if captureSession.canAddOutput(videoMovieFileOutput) {
            captureSession.addOutput(videoMovieFileOutput)
        }
        
        // Start running the session
        captureSession.startRunning()
        
        // delete file
        let fileName = Bundle.main.bundleIdentifier!
        let pathString = "\(NSTemporaryDirectory())/\(fileName).mov"
        let schemePathString = "file://\(pathString)"
        
        if FileManager.default.fileExists(atPath: pathString) {
            try! FileManager.default.removeItem(atPath: pathString)
        }
        
        if let frame = captureController?.window?.frame {

            let quartzScreenFrame = CGDisplayBounds(currentDisplayID)
            let x = frame.origin.x - quartzScreenFrame.origin.x
            let y = frame.origin.y - quartzScreenFrame.origin.y

            // cropping
            let differencialValue = SengiriCropViewLineWidth
            let optimizeFrame = NSRect(
                x: x + differencialValue,
                y: y + differencialValue,
                width: frame.width - differencialValue * 2.0,
                height: frame.height - differencialValue * 2.0
            )

            captureInput.cropRect = optimizeFrame
            
            // start recording
            videoMovieFileOutput.startRecording(to: URL(string: schemePathString)!, recordingDelegate: self)
        }
        
    }
    
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension AppDelegate: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.string(from: Date())
        let pathString = "\(SengiriSavePath)/\(dateString).gif"
        let schemePathURL = URL(string: "file://\(pathString)")!

        if FileManager.default.fileExists(atPath: pathString) {
            try! FileManager.default.removeItem(atPath: pathString)
        }

        let secondPerFrame = UserDefaults.standard.float(forKey: "GifSecondPerFrame")
        let delayTime = UserDefaults.standard.float(forKey: "GifDelayTime")
        let compressionRate = CGFloat(UserDefaults.standard.float(forKey: "GifCompressionRate"))

        guard let track = AVAsset(url: outputFileURL).tracks(withMediaType: AVMediaType.video).first else { return }
        var size = track.naturalSize.applying(track.preferredTransform)
        let compressionTargetSide: CGFloat = 1000
        if size.width >= compressionTargetSide || size.height >= compressionTargetSide {
            size.width = size.width * compressionRate
            size.height = size.height * compressionRate
        }

        let regift = Regift(
            sourceFileURL: outputFileURL,
            destinationFileURL: schemePathURL,
            frameCount: frameCount(outputFileURL, secondPerFrame: secondPerFrame),
            delayTime: delayTime,
            loopCount: 0,
            width: Int(size.width),
            height: Int(size.height)
        )

        _ = regift.createGif()

        // hide menu
        statusItem!.image = nil
        statusItem!.view = nil
        NSStatusBar.system.removeStatusItem(statusItem!)

        let url = URL(string: "file://\(SengiriSavePath)")!
        NSWorkspace.shared.open(url)
    }
    
    func frameCount(_ sourceFileURL:URL, secondPerFrame:Float) -> Int {
        let asset = AVURLAsset(url: sourceFileURL, options: nil)
        let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        let frameCount = Int(movieLength / secondPerFrame)
        return frameCount
    }
}
