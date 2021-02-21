//
//  ChartUIView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/28/21.
//

import SwiftUI

struct ChartUIView: View {
    var chartdata: [String: Int32]
    @Binding var scrollTarget: Int?
    
    var body: some View {
        HStack {
            ZStack {
                VStack {
                    ForEach(0..<5) { i in
                        Divider().background((Color(.lightGray)).opacity(0.02))
                        Spacer()
                    }
                }
                
                HStack {
                    ForEach(chartdata.keys.sorted(), id: \.self) { key in
                        ChartColumn(columnHeight: self.chartdata[key] ?? 0, columnKey: key)
                            .onTapGesture {
                                scrollTarget = (chartdata.count-1) - (Array(chartdata.keys.sorted(by: <)).firstIndex(of: key) ?? 0)
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .padding()
            .padding(.bottom, -10)
            .background(Color(.textColor).opacity(0.03))
            .cornerRadius(9)
        }
        .padding(.horizontal, 20)
    }
    
    struct ChartColumn: View {
        @State private var hovered = false
        var columnHeight = Int32()
        var columnKey = String()
        
        var body: some View {
            VStack {
                Spacer()
                
                Rectangle()
                    .fill(VariableHeightColor(forHeight: Int32(columnHeight)))
                    .frame(minWidth: 1,
                           maxWidth: .infinity,
                           minHeight: 1,
                           maxHeight: CGFloat(columnHeight) * 140 + 1)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: CGFloat(3), trailing: 0))
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(3), style: .continuous))
                
//                    Text("\(FormatDate(whichdate: columnKey))")
//                        .font(.footnote)
//                        .truncationMode(.tail)
            }
            .background(Color(.systemGray).opacity(hovered ? 0.2 : 0))
            .onHover {_ in self.hovered.toggle() }
        }
        
        func VariableHeightColor(forHeight: Int32) -> Color {
            var returnColor: Color
            returnColor = Color.green
            
            switch forHeight {
                case 0:
                    returnColor = Color(.systemGray)

                case 1:
                    returnColor = Color("blue5")

                case 2:
                    returnColor = Color("blue4")
                    
                case 3:
                    returnColor = Color("blue3")
                    
                case 4:
                    returnColor = Color("blue2")
                    
                case 5:
                    returnColor = Color(.systemBlue)

                default:
                    returnColor = Color(.systemGray)
            }
            
            return returnColor
        }
        
        func FormatDate(whichdate: String) -> String {
            let dateString = String(whichdate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.locale = Locale.init(identifier: "en_US")
            
            let dateObj = dateFormatter.date(from: dateString)
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let returnstring = dateFormatter.string(from: dateObj!)
            return returnstring
        }
    }
}
