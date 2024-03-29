//
//  DevidendView.swift
//  Daily Portfolio Update
//
//  Created by Khashayar Abri on 06.09.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct DividendView: View {
    @State var compPortfolioOutput: CompPortfolioOutput
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            List(){
                ForEach(self.compPortfolioOutput.dividendDict.keys.sorted(by: >), id: \.self) { key in
                    HStack{
                        Text(key)
                        
                        Spacer()
                        
                        HStack(){
                            Text(currencyString(self.compPortfolioOutput.dividendDict[key]!))
                            
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Dividends"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
        }
    }
}

struct DividendView_Previews: PreviewProvider {
    static var previews: some View {
        DividendView(compPortfolioOutput: (SampleData().companiesEntriesDict["SNAP"]!.first)!)
    }
}
