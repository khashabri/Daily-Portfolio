//
//  PortfolioView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 08.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

var compPortfolioOutputOfflineSample = JsonOfflineCompPortfolioOutput()

struct PortfolioView: View {
    
    @State var userData = [settingsForPreview.samplePortInput1, settingsForPreview.samplePortInput2, settingsForPreview.samplePortInput3]
    
    @State var existingInputs: [UserInput] = []
    @State var wholeData: [CompPortfolioOutput] = []
    @State var totalInvestment = 0.0
    @State var totalValue = 0.0
    @State var rendite = 0.0
    @State var renditePercent = 0.0
    
    var body: some View {
        NavigationView{
            VStack{
                List() {
                    
                    ForEach(wholeData) {aCompPortRes in
                        RowViewPortfolio(aPortElement: aCompPortRes)
                    }
                    
                }
                .onAppear { self.buildElements() }
                
                Form {
                    
                    Section(header: Text("Total Result")) {
                        HStack {
                            Text("Investment")
                            Spacer()
                            Text(String(roundGoodD(x: totalInvestment)))
                        }
                        HStack {
                            Text("Current Value")
                            Spacer()
                            Text(String(roundGoodD(x: totalValue)))
                        }
                        HStack {
                            Text("Rendite")
                            Spacer()
                            Text(String(roundGoodD(x: rendite)) + " (" + String(renditePercent) + "%)")
                        }
                    }
                }
                .padding(.bottom, -100.0)
                .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: -100)
            }
                
            .navigationBarTitle(Text("Portfolio"))
        }
    }
    
    private func buildElements() {
        for input in userData {
            if !self.existingInputs.contains(input){
                existingInputs.append(input)
                NetworkingManagerPortfolio(userInput: input).getData { compPortfolioOutput in
                    print(compPortfolioOutput)
                    self.wholeData.append(compPortfolioOutput)
                    self.totalInvestment += compPortfolioOutput.totalInvestment
                    self.totalValue += compPortfolioOutput.totalCurrentValue
                    
                    self.rendite = self.totalValue - self.totalInvestment
                    
                    self.renditePercent = calcRateD(x: self.totalValue, y: self.totalInvestment)
                }
            }
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView().environmentObject(settingsForPreview)
    }
}
