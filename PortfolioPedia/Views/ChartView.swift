//
//  ChartView.swift
//  Daily Portfolio Update
//
//  Created by Khashayar Abri on 30.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct ChartView: View {
    @State var totalNumbers: TotalNumbers
    @State var handelDicts: HandelDicts
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack() {
                    Text("Portfolio yield history")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    LineChart(yDataPoints: totalNumbers.totalGainHistory.reversed(), withYLabels: true, withAnimation: true)
                        .frame(width: 350, height: 200)
                        .scaledToFit()
                        .padding(.bottom, 20)
                    
                    Divider()
                    Text("Current value distribution")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    PieChartView(handelDicts: handelDicts)
                }
                .navigationBarTitle(Text("Charts"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(totalNumbers: SampleData().totalNumbers, handelDicts: SampleData().handelDicts)
    }
}
