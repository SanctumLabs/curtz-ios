//
//  HTTPURLResponse+Extension.swift
//  curtz-ios
//
//  Created by George Nyakundi on 08/11/2023.
//

import Foundation

extension HTTPURLResponse {
    
    public func isOK() -> Bool {
        (200...299).contains(self.statusCode)
    }
    
    public func isBadRequest() -> Bool {
        (400...499).contains(self.statusCode)
    }
}

