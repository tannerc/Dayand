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
                        .fill(Color.green)
                        .frame(minWidth: 20,
                               maxWidth: .infinity,
                               minHeight: 0,
                               maxHeight: CGFloat(self.chartdata[key] ?? 10) * 25.0 + 1)
                    Text("\(key)")
                        .font(.footnote)
                }
            }
        }
        .padding()
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
