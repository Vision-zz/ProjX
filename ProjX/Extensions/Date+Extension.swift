//
//  Date+Extension.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//

import Foundation

extension Date {
    func convertToString(with format: String = "dd/M/yyyy hh:mm a") -> String {
        let dateFormatter = DateFormatter()
        var dateFormat = format
        if self.isToday() {
            dateFormat = "'Today' hh:mm a"
        }
        dateFormatter.dateFormat = dateFormat
        let str = dateFormatter.string(from: self)
        return str
    }

    func isToday() -> Bool {
        return Calendar.current.startOfDay(for: Date()) == Calendar.current.startOfDay(for: self)
    }

    func isWithinADay() -> Bool {
        return self.timeIntervalSince(Date().addingTimeInterval(-24 * 60 * 60)) < 0
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

}
