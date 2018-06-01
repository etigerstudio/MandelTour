//
//  Mandel.swift
//  MandelTour
//
//  Created by ALuier Bondar on 29/05/2018.
//  Copyright © 2018 E-Tiger Studio. All rights reserved.
//

import Foundation

class Mandel {
    static let shared = Mandel()
    private init() {}
    
    var range = MandelRange.initial
    
    func calibratedForFrame(width: Double, height: Double) {
        print("cali")
        let rView = width / height
        let rMandel = (range.maxR - range.minR) / (range.maxI - range.minI)
        
        var calibratedRange = MandelRange.zero
        let delta: Double
        
        if rView != rMandel {
            delta = (((range.maxR - range.minR) / rMandel * rView) - (range.maxR - range.minR)) / 2
            calibratedRange.minR = range.minR - delta
            calibratedRange.maxR = range.maxR + delta
            
            calibratedRange.minI = range.minI
            calibratedRange.maxI = range.maxI
            calibratedRange = range
        } else {
            range = calibratedRange
        }
        
    }
}

struct MandelRange {
    var minR: Double
    var maxR: Double
    var minI: Double
    var maxI: Double
    
    static let zero = MandelRange(minR: 0, maxR: 0, minI: 0, maxI: 0)
    static let initial = MandelRange(minR: -2, maxR: 1, minI: -1.5, maxI: 1.5)
}
