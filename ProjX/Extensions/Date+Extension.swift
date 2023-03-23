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
        dateFormatter.locale = Locale(identifier: "en-US")
        var dateFormat = format
        if self.isToday() {
            dateFormat = "Today hh:mm a"
        }
        dateFormatter.dateFormat = dateFormat
        let str = dateFormatter.string(from: self)
        return str
    }

    func isToday() -> Bool {
        return Calendar.current.startOfDay(for: Date()) == Calendar.current.startOfDay(for: self)
    }

}
