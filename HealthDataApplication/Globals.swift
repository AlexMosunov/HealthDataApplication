//
//  Globals.swift
//  HealthDataApplication
//
//  Created by User on 11.12.2023.
//

import Foundation


let calendar = Calendar.current
let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Use "EEE" for abbreviated day names (e.g., "Mon")
        return dateFormatter.string(from: self)
    }
    
    func monthYearFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.yy"
        return dateFormatter.string(from: self)
    }
    
    func formattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

