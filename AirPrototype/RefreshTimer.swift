//
//  RefreshTimer.swift
//  AirPrototype
//
//  Created by mtasota on 10/15/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class RefreshTimer: NSObject, Timer {
    
    var timer:Foundation.Timer?
    var timerInterval: TimeInterval
    var timerTolerance: TimeInterval?
    
    
    init(interval: TimeInterval, withTolerance: TimeInterval?) {
        self.timerInterval = interval
        self.timerTolerance = withTolerance
    }
    
    
    func timerExpires() {
        GlobalHandler.sharedInstance.updateReadings()
    }
    
    
    func startTimer() {
        self.stopTimer()
        self.timer = Foundation.Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(RefreshTimer.timerExpires), userInfo: nil, repeats: false)
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
