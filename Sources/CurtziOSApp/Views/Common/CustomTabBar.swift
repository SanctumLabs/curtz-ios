//
//  CustomTabBar.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 26/10/2023.
//

import SwiftUI

struct CustomTabBar: View {
    @State var animate = true
    @Binding var currentTab: String
    @Binding var ctaSelected: Bool
    var body: some View {
        HStack(spacing: 4, content: {
            TabButton(image: DashboardTab.home.rawValue,currentTab: $currentTab)
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .frame(width: 95, height: 68)
                    .opacity(self.animate ? 0: 1)
                    .scaleEffect(self.animate ? 1: 0.4)
                
                RoundedRectangle(cornerRadius: 20.5, style: .continuous)
                    .frame(width: 80, height: 53)
                    .opacity(self.animate ? 0: 1)
                    .scaleEffect(self.animate ? 1: 0.6)
                
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                    ctaSelected = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(MyButtonStyle())
                .padding(15)
            }
            TabButton(image: DashboardTab.settings.rawValue, currentTab: $currentTab)
        })
    }
}

struct TabButton: View {
    let image: String
    @Binding var currentTab: String
    
    var body: some View {
        Button {
            DispatchQueue.main.async {
                withAnimation {
                    currentTab = image
                }
            }
        } label: {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 28, maxHeight: 28)
                .animation(.easeInOut(duration: 0.3), value: currentTab)
                .frame(maxWidth: .infinity)
                .foregroundStyle(currentTab == image ? Color.DarkIcon: Color.GreyIcon)
        }
        .buttonStyle(BouncyButton(duration: 0.3, scale: 0.6))
        .accessibilityLabel("\(image) tab")
        .accessibilityAddTraits(currentTab == image ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    CustomTabBar(currentTab: .constant(DashboardTab.home.rawValue), ctaSelected: .constant(false))
}


extension Color {
    static var LightIcon: Color {
        return Color("LightIcon")
    }
    
    static var DarkIcon: Color {
        return Color("DarkIcon")
    }
    
    static var GreyIcon: Color {
        return Color("GreyIcon")
    }
    
    static var DarkBackground: Color {
        return Color("DarkBackground")
    }
    static var SubtitleText: Color {
        return Color("SubtitleText")
    }
    static var PrimaryBackground: Color {
        return Color("PrimaryBackground")
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color.LightIcon)
            .frame(width: 65, height: 38)
            .background(configuration.isPressed ? Color.SubtitleText : Color.DarkBackground, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

struct BouncyButton: ButtonStyle {
    var duration: Double
    var scale: Double
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: duration), value: configuration.isPressed)
    }
}
