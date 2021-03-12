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
                                print("Would jump to target row: \(String(describing: scrollTarget))")
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 240)
            .padding()
            .padding(.bottom, -30)
            .background(Color(.textColor).opacity(0.04))
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
            }
            .background(Color(.systemGray).opacity(hovered ? 0.2 : 0))
            .onHover {_ in self.hovered.toggle() }
        }
        
//        func VariableHeightColor(forHeight: Int32) -> Color {
//
//            // Not used function that previously would change the color of the bar in the chart depending on the response color (or average responses for a single day). Went with a solid color for the final product, but leaving this in for customization.
//
//            var returnColor: Color
//            returnColor = Color.green
//
//            switch forHeight {
//                case 0:
//                    returnColor = Color(.systemGray)
//
//                case 1:
//                    returnColor = Color(.red)
//
//                case 2:
//                    returnColor = Color(.yellow)
//
//                case 3:
//                    returnColor = Color(.blue)
//
//                case 4:
//                    returnColor = Color(.systemTeal)
//
//                case 5:
//                    returnColor = Color(.green)
//
//                default:
//                    returnColor = Color(.systemGray)
//            }
//
//            return returnColor
//        }
    }
}
