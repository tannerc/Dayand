//
//  CustomToggle.swift
//  Dayand
//
//  Created by Tanner Christensen on 2/20/21.
//

import SwiftUI

struct CustomToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? Color(.systemBlue) : Color(.systemGray).opacity(0.6))
                .frame(width: 32, height: 20)
                .overlay(
                    Circle()
                        .foregroundColor(Color("backgroundColor"))
                        .padding(.all, 3)
                        .offset(x: configuration.isOn ? 6 : -6, y: 0)
                        .animation(Animation.linear(duration: 0.15))
                        
                ).cornerRadius(11)
                .onTapGesture { configuration.isOn.toggle() }
        }
        .frame(width: 32, height: 20)
    }
}
