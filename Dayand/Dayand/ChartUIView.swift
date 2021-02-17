//
//  ChartUIView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/28/21.
//

import SwiftUI

struct ChartUIView: View {
    var chartdata: [String: Int32]
    @State private var hovered = false
    @Binding var scrollTarget: Int?
    
    var body: some View {
        
        let theRoundness = 10
        
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
                        VStack {
                            Spacer()
                            
                            Rectangle()
                                .fill(VariableHeightColor(forHeight: self.chartdata[key] ?? 3))
                                .frame(minWidth: 1,
                                       maxWidth: .infinity,
                                       minHeight: 1,
                                       maxHeight: CGFloat(self.chartdata[key] ?? 4) * 45.0 + 1)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: CGFloat(theRoundness), trailing: 0))
                                .clipShape(RoundedRectangle(cornerRadius: CGFloat(theRoundness), style: .continuous))
                            
                            if (chartdata.count < 20) {
                                Text("\(FormatDate(whichdate: key))")
                                    .font(.footnote)
                            }
                        }
                        .onTapGesture {
                            scrollTarget = Array(chartdata.keys).firstIndex(of: key)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.textColor).opacity(0.04))
            .cornerRadius(9)
        }
        .padding(.horizontal, 10)
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
    
    func VariableHeightColor(forHeight: Int32) -> Color {
        var returnColor: Color
        returnColor = Color.green
        
        switch forHeight {
            case 0:
                returnColor = Color(.systemGray)

            case 1:
                returnColor = Color("dayandRed")

            case 2:
                returnColor = Color("dayandYellow")
                
            case 3:
                returnColor = Color("dayandYellow")
                
            case 4:
                returnColor = Color("dayandGreen")
                
            case 5:
                returnColor = Color("dayandGreen")

            default:
                returnColor = Color(.systemGray)
        }
        
        return returnColor
    }
}


//struct ChartUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartUIView(chartdata: ["20210102": 3,
//                    "20210103": 0,
//                    "20210104": 5,
//                    "20210105": 0,
//                    "20210106": 2,
//                    "20210107": 2], scrollTarget: 0)
//    }
//}
