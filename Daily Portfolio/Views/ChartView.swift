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
            GeometryReader { geo in
                ScrollView{
                    VStack() {
                        if totalNumbers.totalGainHistory.isEmpty {
                            Text("Your portfolio is currently empty. Fill in your stocks and come back again!")
                        }else{
                            Text("Portfolio yield history")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                            
                            LineChart(yDataPoints: totalNumbers.totalGainHistory.reversed(), withYLabels: true, withAnimation: true)
                                .padding([.leading, .bottom, .trailing])
                                .frame(width: geo.size.width, height: 230, alignment: .center)
                            
                            Divider()
                            Text("Current value distribution")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                            PieChartView(handelDicts: handelDicts)
                        }
                    }.padding(.bottom, 100)
                }
            }
            .navigationBarTitle(Text("Charts"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(totalNumbers: SampleData().totalNumbers, handelDicts: SampleData().handelDicts)
    }
}
