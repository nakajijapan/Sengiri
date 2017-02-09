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
            selector: #selector(self.recordButtonDidClick(_:)),
            name: NSNotification.Name(rawValue: "CaptureViewRecordButtonDidClick"),
            object: nil
        )

        let frameCount = UserDefaults.standard.float(forKey: "GifSecondPerFrame")
        if frameCount == 0 {
            UserDefaults.standard.set(0.1, forKey: "GifSecondPerFrame")
        }

        let delayTime = UserDefaults.standard.float(forKey: "GifDelayTime")
        if delayTime == 0.0 {
            UserDefaults.standard.set(0.1, forKey: "GifDelayTime")
        }
        
        self.menu.delegate = self

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CaptureViewRecordButtonDidClick"), object: nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

// MARK: - Main Menu Actions

extension AppDelegate {
    
    @IBAction func mainMenuItemDidClick(_ sender: AnyObject) {
        self.menuItemForCropRecordDidClick(NSMenuItem())
    }
    
    @IBAction func mainMenuItemForCropWindowToTopWindowDidClic(_ sender: AnyObject) {

        if captureController == nil {
            let storyBoard = NSStoryboard(name: "Main", bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: "CaptureWindowController") as! CaptureWindowController
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
        progressIndicator.style = NSProgressIndicatorStyle.spinningStyle
        progressIndicator.startAnimation(nil)
        progressIndicator.controlSize = NSControlSize.small
        progressIndicator.isDisplayedWhenStopped = false
        self.statusItem!.view = progressIndicator
        
        self.menuItemForStopDidClick(NSMenuItem())

    }

}

// MARK: - NSMenu Actions

extension AppDelegate {

    func menuItemForCropRecordDidClick(_ sender: NSMenuItem) {
        
        if self.captureController == nil {
            
            let storyBoard = NSStoryboard(name: "Main", bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: "CaptureWindowController") as! CaptureWindowController
            self.captureController = windowController

        }

        self.captureController!.showWindow(nil)
        self.captureController?.window?.makeKey()
        
    }
    
    func menuItemForStopDidClick(_ sender: NSMenuItem) {

        self.captureController?.window?.close()
        self.captureController?.close()
        self.captureController = nil // assign nil because some capture window opens when capture window open in second time
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AppDelegateStopMenuDidClick"), object: self, userInfo:nil)
        
        if self.videoMovieFileOutput == nil {
            return
        }
        if self.videoMovieFileOutput.isRecording {
            self.videoMovieFileOutput.stopRecording()
        }
        
    }
    
    @IBAction func mainMenuItemForPreferenceDidClick(_ sender: NSMenuItem) {
        
        if self.preferenceWindowController == nil {
            let storyBoard = NSStoryboard(name: "PreferenceWindowController", bundle: nil)
            let windowController = storyBoard.instantiateInitialController() as! NSWindowController
            windowController.showWindow(self)
            self.preferenceWindowController = windowController
        }

        self.preferenceWindowController!.showWindow(nil)
        self.preferenceWindowController?.window?.makeKey()
        
    }

}

// MARK: - Notifications

extension AppDelegate {

    func recordButtonDidClick(_ button:NSButton) {
        
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        self.statusItem!.highlightMode = true
        self.statusItem!.menu = self.menu
        self.statusItem!.image = NSImage(named: "icon_stop")

        self.prapareVideoScreen()
    }
    
    func prapareVideoScreen() {

        let displayID = CGMainDisplayID()

        // Movie Output
        self.videoMovieFileOutput = AVCaptureMovieFileOutput()

        let captureInput = AVCaptureScreenInput(displayID: displayID)
        
        self.captureSession = AVCaptureSession()
        
        if self.captureSession.canAddInput(captureInput) {
            self.captureSession.addInput(captureInput)
        }
        
        if self.captureSession.canAddOutput(self.videoStillImageOutput) {
            self.captureSession.addOutput(self.videoStillImageOutput)
        }
        
        if self.captureSession.canAddOutput(self.videoMovieFileOutput) {
            self.captureSession.addOutput(self.videoMovieFileOutput)
        }
        
        // Start running the session
        self.captureSession.startRunning()
        
        // delete file
        let fileName = Bundle.main.bundleIdentifier!
        let pathString = "\(NSTemporaryDirectory())/\(fileName).mov"
        let schemePathString = "file://\(pathString)"
        
        if FileManager.default.fileExists(atPath: pathString) {
            try! FileManager.default.removeItem(atPath: pathString)
        }
        
        if let frame = self.captureController?.window?.frame {
            
            // cropping
            let differencialValue = CGFloat(SengiriCropViewLineWidth)
            let optimizeFrame = NSRect(
                x: frame.origin.x + differencialValue,
                y: frame.origin.y + differencialValue,
                width: frame.width - differencialValue * 2.0,
                height: frame.height - differencialValue * 2.0
            )
            
            captureInput?.cropRect = optimizeFrame
            
            // start recording
            self.videoMovieFileOutput.startRecording(toOutputFileURL: URL(string: schemePathString), recordingDelegate: self)
        }
        
    }
    
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension AppDelegate: AVCaptureFileOutputRecordingDelegate {
    
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {

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

        let regift = Regift(
            sourceFileURL: outputFileURL,
            destinationFileURL: schemePathURL,
            frameCount: self.frameCount(outputFileURL, secondPerFrame: secondPerFrame),
            delayTime: delayTime,
            loopCount: 0
        )
        
        let gifmovieURL = regift.createGif()
        print("Gif saved to \(gifmovieURL)")

        // hide menu
        self.statusItem!.image = nil
        self.statusItem!.view = nil
        NSStatusBar.system().removeStatusItem(self.statusItem!)

        let url = URL(string: "file://\(SengiriSavePath)")!
        NSWorkspace.shared().open(url)
    }
    
    func frameCount(_ sourceFileURL:URL, secondPerFrame:Float) -> Int {

        let asset = AVURLAsset(url: sourceFileURL, options: nil)
        let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        let frameCount = Int(movieLength / secondPerFrame)
        return frameCount
        
    }

}

