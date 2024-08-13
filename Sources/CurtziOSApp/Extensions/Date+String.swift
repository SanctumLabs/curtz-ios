//
//  Date+String.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 13/08/2024.
//

import Foundation

extension String {
    func toFormattedDateString() -> String {
        let formatter = ISO8601DateFormatter()
        if let dateString = formatter.date(from: self) {
            return dateString.formatted()
        } else {
            return ""
        }
    }
}
