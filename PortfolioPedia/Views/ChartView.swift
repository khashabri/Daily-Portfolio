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
            VStack(alignment: .leading) {
                LineView(data: totalNumbers.totalGainHistory.reversed(), title: "Rendite", legend: String(totalNumbers.renditePercent)+"%")
                Spacer()
            }.padding(20)
            
            .navigationBarTitle(Text("Rendite Chart"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
        }
    }
}

//struct ChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartView()
//    }
//}
