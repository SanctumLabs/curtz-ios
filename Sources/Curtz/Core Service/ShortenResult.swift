//
//  ShortenResult.swift
//  Curtz
//
//  Created by George Nyakundi on 20/11/2023.
//

import Foundation

public enum ShortenResult {
    case success(ShortenResponseItem)
    case failure(Error)
}
