//
//  ShortenerView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 30/10/2023.
//

import SwiftUI

struct ShortenerView: View {
    @Binding var ctaSelected: Bool
    var body: some View {
        ZStack(alignment: .bottom, content: {
            Color.PrimaryBackground.opacity(0.4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())

            VStack {
                Spacer()
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                Button {
                    withAnimation {
                        ctaSelected = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(Color.SubtitleText)
                        .padding(7)
                        .contentShape(Circle())
                }
            }
            .offset(x: 5, y: -5)
        })
        
    }
}

#Preview {
    ShortenerView(ctaSelected: .constant(false))
}
