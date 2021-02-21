//
//  CustomButtonView.swift
//  Dayand
//
//  Created by Tanner Christensen on 2/13/21.
//

import SwiftUI

struct CustomButtonView: View {
    let title: String
    let action: () -> Void
    let disabledState: Bool?
    let buttonClass: String?
    var buttonRadius = CGFloat(7.0)
    @State private var hovered = false
    
    var body: some View {
        switch buttonClass {
            case "Primary":
                Button(action: action) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 11.0)
                        .padding(.horizontal, 24.0)
                        .foregroundColor(Color("backgroundColor"))
                        .background(Color(.systemBlue))
                        .cornerRadius(buttonRadius)
                        .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)
                        .onHover {_ in self.hovered.toggle() }
                        .overlay (
                            RoundedRectangle(cornerRadius: buttonRadius)
                        ).foregroundColor(Color(.textColor).opacity(hovered ? 0.1 : 0))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(disabledState ?? false)
                
            case "Destructive":
                Button(action: action) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 11.0)
                        .padding(.horizontal, 24.0)
                        .foregroundColor(Color(.red))
                        .background(Color("backgroundColor"))
                        .overlay(
                            RoundedRectangle(cornerRadius: buttonRadius)
                                .stroke(Color(.systemGray).opacity(hovered ? 0.6 : 0.4), lineWidth: 1)
                        )
                        .cornerRadius(buttonRadius)
                        .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)
                        .onHover {_ in self.hovered.toggle() }
                        .overlay (
                            RoundedRectangle(cornerRadius: buttonRadius)
                        ).foregroundColor(Color(.textColor).opacity(hovered ? 0.02 : 0))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(disabledState ?? false)
            
            default:
                Button(action: action) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 11.0)
                        .padding(.horizontal, 24.0)
                        .foregroundColor(Color(.textColor))
                        .background(Color("backgroundColor"))
                        .overlay(
                            RoundedRectangle(cornerRadius: buttonRadius)
                                .stroke(Color(.systemGray).opacity(hovered ? 0.6 : 0.4), lineWidth: 1)
                        )
                        .cornerRadius(buttonRadius)
                        .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)
                        .onHover {_ in self.hovered.toggle() }
                        .overlay (
                            RoundedRectangle(cornerRadius: buttonRadius)
                        ).foregroundColor(Color(.textColor).opacity(hovered ? 0.02 : 0))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(disabledState ?? false)
        }
    }
}

struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(title: "A Button", action: {}, disabledState: false, buttonClass: "Default")
    }
}
