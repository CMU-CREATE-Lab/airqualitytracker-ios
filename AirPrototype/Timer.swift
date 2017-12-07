//
//  Timer.swift
//  AirPrototype
//
//  Created by mtasota on 10/15/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

// NOTICE
// NSTimer needs to have NSObject as its target. Because of this,
// whenever you use this protocol in a class, that class MUST
// extend from NSObject (we can't extend in the protocol of course
// because protocols can't extend from classes...)
// OOPs!
protocol Timer {
    
    // actual timer object (from lib)
    var timer:Foundation.Timer? { get }
    // length of time for the timer
    var timerInterval: TimeInterval { get }
    // tolerance allows less precision and saves on battery
    var timerTolerance: TimeInterval? { get }
    
    func timerExpires()
    func startTimer()
    func stopTimer()
    
}
