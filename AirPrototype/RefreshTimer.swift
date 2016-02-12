//
//  RefreshTimer.swift
//  AirPrototype
//
//  Created by mtasota on 10/15/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class RefreshTimer: NSObject, Timer {
    
    var timer:NSTimer?
    var timerInterval: NSTimeInterval
    var timerTolerance: NSTimeInterval?
    
    
    init(interval: NSTimeInterval, withTolerance: NSTimeInterval?) {
        self.timerInterval = interval
        self.timerTolerance = withTolerance
    }
    
    
    func timerExpires() {
        GlobalHandler.sharedInstance.updateReadings()
    }
    
    
    func startTimer() {
        self.stopTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timerInterval, target: self, selector: Selector("timerExpires"), userInfo: nil, repeats: false)
        if let tolerance = self.timerTolerance {
            self.timer!.tolerance = tolerance
        }
    }
    
    
    func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
    
}