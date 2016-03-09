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
let SengiriSavePath = "\(SengiriHomePath)/\(NSBundle.mainBundle().bundleIdentifier!)"


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AVCaptureFileOutputRecordingDelegate, NSMenuDelegate {

    var statusItem:NSStatusItem?

    @IBOutlet weak var menu: NSMenu!
    
    var captureController:CaptureWindowController? = nil
    var preferenceWindowController:NSWindowController? = nil


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // create working directory
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath("\(SengiriSavePath)", withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("failed to make directory. error: \(error.description)")
        }
        
        
        // initialize default setting
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recordButtonDidClick:", name: "CaptureViewRecordButtonDidClick", object: nil)

        let frameCount = NSUserDefaults.standardUserDefaults().floatForKey("GifSecondPerFrame")
        if frameCount == 0 {
            NSUserDefaults.standardUserDefaults().setDouble(0.1, forKey: "GifSecondPerFrame")
        }

        let delayTime = NSUserDefaults.standardUserDefaults().floatForKey("GifDelayTime")
        if delayTime == 0.0 {
            NSUserDefaults.standardUserDefaults().setDouble(0.1, forKey: "GifDelayTime")
        }
        
        self.menu.delegate = self

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CaptureViewRecordButtonDidClick", object: nil)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Main Menu Actions
   
    @IBOutlet weak var mainMenuItem: NSMenuItem!
    @IBAction func mainMenuItemDidClick(sender: AnyObject) {
        self.menuItemForCropRecordDidClick(NSMenuItem())
    }
    
    @IBAction func mainMenuItemForCropWindowToTopWindowDidClic(sender: AnyObject) {

        if self.captureController == nil {

            let storyBoard = NSStoryboard(name: "Main", bundle: nil)
            let windowController = storyBoard.instantiateControllerWithIdentifier("CaptureWindowController") as! CaptureWindowController
            self.captureController = windowController

        }
        
        if let windowInfo = WindowInfoManager.topWindowInfo() {

            let frame = windowInfo.frame!
            self.captureController!.window!.setFrame(frame, display: true, animate: true)

        }

        self.captureController!.showWindow(nil)
        self.captureController?.window?.makeKeyWindow()
    }
    
    @IBAction func mainMenuForStopDidClick(sender: AnyObject) {
        self.menuItemForStopDidClick(NSMenuItem())
    }
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {

        // Highlight
        let progressIndicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 16, height: 16))
        progressIndicator.style = NSProgressIndicatorStyle.SpinningStyle
        progressIndicator.startAnimation(nil)
        progressIndicator.controlSize = NSControlSize.SmallControlSize
        progressIndicator.displayedWhenStopped = false
        self.statusItem!.view = progressIndicator
        
        self.menuItemForStopDidClick(NSMenuItem())
    }
    
    // MARK: - NSMenu Actions

    func menuItemForCropRecordDidClick(sender: NSMenuItem) {
        
        if self.captureController == nil {
            
            let storyBoard = NSStoryboard(name: "Main", bundle: nil)
            let windowController = storyBoard.instantiateControllerWithIdentifier("CaptureWindowController") as! CaptureWindowController
            self.captureController = windowController

        }

        self.captureController!.showWindow(nil)
        self.captureController?.window?.makeKeyWindow()
        
    }
    
    func menuItemForStopDidClick(sender: NSMenuItem) {

        self.captureController?.window?.close()
        self.captureController?.close()
        self.captureController = nil // assign nil because some capture window opens when capture window open in second time
        
        NSNotificationCenter.defaultCenter().postNotificationName("AppDelegateStopMenuDidClick", object: self, userInfo:nil)
        
        if self.videoMovieFileOutput == nil {
            return
        }
        if self.videoMovieFileOutput.recording {
            self.videoMovieFileOutput.stopRecording()
        }
        
    }
    
    @IBAction func mainMenuItemForPreferenceDidClick(sender: NSMenuItem) {
        
        if self.preferenceWindowController == nil {
            let storyBoard = NSStoryboard(name: "PreferenceWindowController", bundle: nil)
            let windowController = storyBoard.instantiateInitialController() as! NSWindowController
            windowController.showWindow(self)
            self.preferenceWindowController = windowController
        }

        self.preferenceWindowController!.showWindow(nil)
        self.preferenceWindowController?.window?.makeKeyWindow()
        
    }

    // MARK: - Actions
    
    func recordButtonDidClick(button:NSButton) {
        
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
        self.statusItem!.highlightMode = true
        self.statusItem!.menu = self.menu
        self.statusItem!.image = NSImage(named: "icon_stop")

        self.prapareVideoScreen()
    }
    
    // image
    var captureSession:AVCaptureSession!
    var videoStillImageOutput:AVCaptureStillImageOutput!
    
    // movie
    var videoMovieFileOutput:AVCaptureMovieFileOutput!

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
        let fileName = NSBundle.mainBundle().bundleIdentifier!
        let pathString = "\(NSTemporaryDirectory())/\(fileName).mov"
        let schemePathString = "file://\(pathString)"
        
        if NSFileManager.defaultManager().fileExistsAtPath(pathString) {
            try! NSFileManager.defaultManager().removeItemAtPath(pathString)
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
            
            captureInput.cropRect = optimizeFrame
            
            // start recording
            self.videoMovieFileOutput.startRecordingToOutputFileURL(NSURL(string: schemePathString), recordingDelegate: self)
        }
        
    }
    
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        let pathString = "\(SengiriSavePath)/\(dateString).gif"
        let schemePathURL = NSURL(string: "file://\(pathString)")!
        
        if NSFileManager.defaultManager().fileExistsAtPath(pathString) {
            try! NSFileManager.defaultManager().removeItemAtPath(pathString)
        }
        
        let secondPerFrame = NSUserDefaults.standardUserDefaults().floatForKey("GifSecondPerFrame")
        let delayTime = NSUserDefaults.standardUserDefaults().floatForKey("GifDelayTime")

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
        NSStatusBar.systemStatusBar().removeStatusItem(self.statusItem!)

        let url = NSURL(string: "file://\(SengiriSavePath)")!
        NSWorkspace.sharedWorkspace().openURL(url)
    }
    
    func frameCount(sourceFileURL:NSURL, secondPerFrame:Float) -> Int {

        let asset = AVURLAsset(URL: sourceFileURL, options: nil)
        let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        let frameCount = Int(movieLength / secondPerFrame)
        return frameCount
        
    }

}

