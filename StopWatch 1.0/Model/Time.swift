//
//  Time.swift
//  StopWatch 1.0
//
//  Created by Marek Barták on 27.04.2021.
//

import Foundation

struct Time {
    
    var currentTimeInHundredth: Int {
        get {
            Int(CFAbsoluteTimeGetCurrent()*100) // použil jsem CFAbsoluteTimeGetCurrent, bych když uživatel vyjede z aplikace, aby stále stopky běželi
        }
    }
    var startTimeInHundredth: Int
    
    var displayTime: Int {
        get {
    currentTimeInHundredth - startTimeInHundredth
        }
}
    
    func getTimeString(hundredts: Int) -> String {
        
        let hundredths = hundredts % 100
        let seconds = ((hundredts - (hundredts % 100))/100) % 60
        let minutes = ((hundredts - (hundredts % 100))/6000) % 60
        let hours = ((hundredts - (hundredts % 100))/360000) % 60
        
        let stringTimeWithoutHours = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds) + "," + String(format: "%02d", hundredths)
        if hours == 0 {
            return stringTimeWithoutHours
        } else {
            return String(hours) + ":" + stringTimeWithoutHours
        }
    }
}
