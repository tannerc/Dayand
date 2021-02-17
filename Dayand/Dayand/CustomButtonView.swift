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
    var buttonRadius = CGFloat(9.0)
    
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
                                .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                        )
                        .cornerRadius(buttonRadius)
                        .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)
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
