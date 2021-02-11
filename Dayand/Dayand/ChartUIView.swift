//
//  ChartUIView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/28/21.
//

import SwiftUI

struct ChartUIView: View {
    var chartdata: [String: Int32]
    
    var body: some View {
        HStack {
            ForEach(chartdata.keys.sorted(), id: \.self) { key in
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(VariableHeightColor(forHeight: self.chartdata[key] ?? 10))
                        .frame(minWidth: 20,
                               maxWidth: .infinity,
                               minHeight: 0,
                               maxHeight: CGFloat(self.chartdata[key] ?? 10) * 45.0 + 1)
                    Text("\(FormatDate(whichdate: key))")
                        .font(.footnote)
                }
            }
        }
        .padding()
    }
    
    func FormatDate(whichdate: String) -> String {
        let dateString = String(whichdate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let returnstring = dateFormatter.string(from: dateObj!)
        return returnstring
    }
    
    func VariableHeightColor(forHeight: Int32) -> Color {
        var returnColor: Color
        returnColor = Color.green
        
        switch forHeight {
            case 0:
                returnColor = Color.gray

            case 1:
                returnColor = Color.red

            case 2:
                returnColor = Color.yellow
                
            case 3:
                returnColor = Color.yellow
                
            case 4:
                returnColor = Color.green
                
            case 5:
                returnColor = Color.green

            default:
                returnColor = Color.gray
        }
        
        return returnColor
    }
}

struct ChartUIView_Previews: PreviewProvider {
    static var previews: some View {
        ChartUIView(chartdata: ["test1": 3,
                    "test2": 0,
                    "test3": 5,
                    "test4": 0,
                    "test5": 2])
    }
}
