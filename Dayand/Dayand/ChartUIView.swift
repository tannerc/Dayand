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
    
    let responseArr = ["😡", "☹️", "😐", "🙂", "😄"]
    
    var body: some View {
        HStack {
            ZStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        ForEach(0..<responseArr.count) { i in
                            Text("\(responseArr.reversed()[i])")
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                
                VStack {
                    ForEach(0..<5) { i in
                        Divider()
                            .background(Color(.systemGray).opacity(0.05))
                            .padding(8)
                            .padding(.leading, 20)
                        Rectangle()
                            .strokeBorder(Color(.systemBlue).opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [12]))
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .opacity(i == GetMedian() ? 1.0 : 0)
                        
                        Spacer()
                    }
                }
                
                HStack {
                    ForEach(chartdata.keys.sorted(), id: \.self) { key in
                        ChartColumn(columnHeight: self.chartdata[key] ?? 0, columnKey: key, columnRoundness: chartdata.count)
                            .onTapGesture {
                                scrollTarget = (chartdata.count-1) - (Array(chartdata.keys.sorted(by: <)).firstIndex(of: key) ?? 0)
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 240)
            .padding()
            .padding(.bottom, -30)
            .background(Color(.textColor).opacity(0.05))
            .cornerRadius(9)
        }
        .padding(.horizontal, 20)
        .cornerRadius(9)
    }
    
    func GetMedian() -> Int32 {
        let values = chartdata.map { $0.value }
        var thevalue = values.reduce(0, +)
        thevalue = 5 - thevalue
        
        return Int32(thevalue)
    }
    
    struct ChartColumn: View {
        @State private var hovered = false
        var columnHeight = Int32()
        var columnKey = String()
        var columnRoundness = Int()
        
        var body: some View {
            VStack {
                Spacer()
                
                Rectangle()
//                    .fill(VariableHeightColor(forHeight: Int32(columnHeight)))
                    .fill(LinearGradient(
                          gradient: .init(colors: [Color(red: 33 / 255, green: 166 / 255, blue: 210 / 255),
                                                   Color(red: 47 / 255, green: 124 / 255, blue: 246 / 255)]),
                          startPoint: .init(x: 0.5, y: 0),
                          endPoint: .init(x: 0.5, y: 0.6)
                        ))
                    .frame(minWidth: 1,
                           maxWidth: .infinity,
                           minHeight: 1,
                           maxHeight: CGFloat(columnHeight) * 50 + 1)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: CGFloat(3), trailing: 0))
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(columnRoundness), style: .continuous))
                
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
