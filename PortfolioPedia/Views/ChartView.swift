//
//  ChartView.swift
//  Daily Portfolio Update
//
//  Created by Khashayar Abri on 30.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import SwiftUICharts


struct ChartView: View {
    @State var totalNumbers: TotalNumbers
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            VStack() {
                Text("Portfolio yield history")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                LineChart(yDataPoints: totalNumbers.totalGainHistory.reversed(), withYLabels: true, withAnimation: true)
                    .frame(width: 350, height: 200)
                    .scaledToFit()
                    .padding(.bottom, 150)
            }
            .navigationBarTitle(Text("Charts"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
        }
    }
}

//struct ChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartView()
//    }
//}
