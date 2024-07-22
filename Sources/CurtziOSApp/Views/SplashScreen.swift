//
//  SplashScreen.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 22/07/2024.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            .scaleEffect(2.0, anchor: .center)
    }
}
