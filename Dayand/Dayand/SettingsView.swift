//
//  SettingsView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/23/21.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @State var colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
    @State var globalKeyCommand = UserDefaults.standard.string(forKey: "superbglobalkey") ?? ""
    
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Copy colors in this format").font(.caption)
                        
                        MenuButton("\(colorSyncFormat ?? "Hex value")") {
                            Button(action: {
                                ChangeColorCopyFormat(toValue: "Hex value")
                                self.colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
                            }) {
                                Text("Hex value")
                            }
                            
                            Button(action: {
                                ChangeColorCopyFormat(toValue: "RGB value")
                                self.colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
                            }) {
                                Text("RGB value")
                            }
                            
                            Button(action: {
                                ChangeColorCopyFormat(toValue: "Color name")
                                self.colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
                            }) {
                                Text("Color name")
                            }
                        }.frame(width: 140).shadow(color: Color(.lightGray).opacity(0.2), radius: 2, x: 0, y: 3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4){
                        Text("Global Show/Hide Command").font(.caption)
                        
                        TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $globalKeyCommand)
                            .disabled(true)
                            .foregroundColor(Color(.disabledControlTextColor))
                            .textFieldStyle(PlainTextFieldStyle())
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color(.lightGray), lineWidth: 1)
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(.lightGray))
                                    )
                                .shadow(color: Color(.lightGray).opacity(0.2), radius: 2, x: 0, y: 3)
                        
                        Text("Example: ⌥⌘S").foregroundColor(Color(.secondaryLabelColor)).font(.system(size: 10))
                        
                    }.frame(width: 220)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(12)
        }
        .background(Color(.windowBackgroundColor).opacity(0.9))
        .frame(width: 500, height: 300)
    }
}

func ChangeColorCopyFormat(toValue: String) {
    UserDefaults.standard.set(toValue, forKey: "superbcolorcopyformat")
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           SettingsView()
              .environment(\.colorScheme, .light)

           SettingsView()
              .environment(\.colorScheme, .dark)
        }
    }
}
