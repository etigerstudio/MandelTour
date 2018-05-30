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
    
    func calibratedRange( width: Double, height: Double) -> MandelRange {
        let rView = width / height
        let rMandel = (range.maxR - range.minR) / (range.maxI - range.minI)
        
        var rangeC = MandelRange.zero
        let rV2M: Double
        let delta: Double
        
        if rView > rMandel {
            rV2M = (range.maxI - range.minI) / height
            delta = (width * rV2M - (range.maxR - range.minI)) / 2
            rangeC.minR = range.minR - delta
            rangeC.maxR = range.maxR + delta
            
            rangeC.minI = range.minI
            rangeC.maxI = range.maxI
        } else if rView < rMandel {
            rV2M = (range.maxR - range.minR) / width
            delta = (height * rV2M - (range.maxI - range.minI)) / 2
            rangeC.minI = range.minI - delta
            rangeC.maxI = range.maxI - delta
            
            rangeC.minR = range.minR
            rangeC.maxR = range.maxR
        } else {
            rangeC = range
        }
        
        return rangeC
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
