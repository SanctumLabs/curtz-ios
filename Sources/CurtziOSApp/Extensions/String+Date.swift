//
//  String+Date.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 13/08/2024.
//

import Foundation


extension String {
    func toISODate() -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self) ?? .now
    }
}
