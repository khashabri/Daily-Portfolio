//
//  PortfolioView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 08.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

var compPortfolioOutputOfflineSample = JsonOfflineCompPortfolioOutput()

var totalGainHistory: [Double] = []
var lastRefreshed = ""
var totalInvestment = 0.0
var totalValue = 0.0
var rendite = 0.0
var renditePercent = 0.0

struct PortfolioView: View {
    
//    @State var userData = [settingsForPreview.samplePortInput3]
    
    @State var existingInputs: [UserInput] = []
    @State var wholeData: [CompPortfolioOutput] = []
    @State var companiesEntriesDict = [String : [CompPortfolioOutput]]()
    @State var portfolioListInvestDict = [String : Double]()
    @State var portfolioListGainDict = [String : Double]()
    @State var portfolioListPercentageDict = [String : Double]()
    @State var portfolioListShareNumberDict = [String : Double]()
    
    // For add button
    @State private var showModal = false
    // shared variable between add and this view to exchange objects
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationView{
            VStack{
                List() {
                    
                    ForEach(portfolioListInvestDict.sorted(by: >), id: \.value) {key, value in
                        
                        RowViewPortfolio(dataEntries: self.companiesEntriesDict[key]! ,Name: (self.companiesEntriesDict[key]?.first!.compName)!, portfolioListInvestDict: self.portfolioListInvestDict[key]!, portfolioListGainDict: self.portfolioListGainDict[key]!, portfolioListPercentageDict: self.portfolioListPercentageDict[key]!, portfolioListShareNumberDict: self.portfolioListShareNumberDict[key]!)
                    }
                    
                }
                    .onAppear { self.buildElements() }
                .navigationBarItems(leading: EditButton(), trailing: AddButton(destination: SearchingView()))

                totalInfoSubview(lastRefreshed: lastRefreshed, totalInvestment: totalInvestment, totalValue: totalValue, rendite: rendite, renditePercent: renditePercent)
            }
            .navigationBarTitle(Text("Portfolio"), displayMode: .inline)
        }
    }
    
    private func buildElements() {
        for input in settings.portfolio {
            if !self.existingInputs.contains(input){
                existingInputs.append(input)
                NetworkingManagerPortfolio(userInput: input).getData { compPortfolioOutput in
                    
                    print(compPortfolioOutput)
                    //                    self.wholeData.append(compPortfolioOutput)
                    
                    // Catching Data of companies
                    let key = compPortfolioOutput.compSymbol
                    if self.companiesEntriesDict.keys.contains(key){
                        
                        self.companiesEntriesDict[key]?.append(compPortfolioOutput)
                        self.portfolioListInvestDict[key]! += compPortfolioOutput.totalInvestment
                        self.portfolioListGainDict[key]! += compPortfolioOutput.gainHistory[0]
                        self.portfolioListShareNumberDict[key]! += compPortfolioOutput.purchaseAmount
                        
                    }
                    else{
                        self.companiesEntriesDict[key] = [compPortfolioOutput]
                        self.portfolioListInvestDict[key] = compPortfolioOutput.totalInvestment
                        self.portfolioListGainDict[key] = compPortfolioOutput.gainHistory[0]
                        self.portfolioListShareNumberDict[key] = compPortfolioOutput.purchaseAmount
                        
                    }
                    
                    let currentPrice = compPortfolioOutput.priceHistory[0]
                    // Catching data for the Portfolio List (some are above)
                    self.portfolioListPercentageDict[key] = calcRateD(x: currentPrice * self.portfolioListShareNumberDict[key]!, y: self.portfolioListInvestDict[key]!)
                    
                    // Calc data for "Total Result" section
                    totalInvestment += compPortfolioOutput.totalInvestment
                    totalValue += compPortfolioOutput.totalCurrentValue
                    rendite = totalValue - totalInvestment
                    renditePercent = calcRateD(x: totalValue, y: totalInvestment)
                    totalGainHistory += compPortfolioOutput.gainHistory
                    lastRefreshed = compPortfolioOutput.lastRefreshed
                    
                    
                    print(self.companiesEntriesDict)
                    print(self.portfolioListInvestDict)
                    print(self.portfolioListGainDict)
                    print(self.portfolioListPercentageDict)
                    print(self.portfolioListShareNumberDict)
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

struct ListHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "sum")
            Text("Total Result")
        }
    }
}

struct totalInfoSubview: View, Equatable {
    let lastRefreshed: String
    let totalInvestment: Double
    let totalValue: Double
    let rendite: Double
    let renditePercent: Double
    
    var body: some View {
        
        Form{
            
            Section(header: ListHeader(), footer: Text("Last database update on: " + lastRefreshed)) {
                HStack {
                    Text("Investment")
                    Spacer()
                    Text(String(roundGoodD(x: totalInvestment)) + " $")
                }
                HStack {
                    Text("Current Value")
                    Spacer()
                    Text(String(roundGoodD(x: totalValue)) + " $")
                }
                HStack {
                    Text("Rendite")
                    Spacer()
                    if rendite < 0 {
                        Text(String(roundGoodD(x: rendite)) + " (" + String(abs(renditePercent)) + "%)")
                            .foregroundColor(Color.red)
                    }
                    else {
                        Text("+" + String(roundGoodD(x: rendite)) + " (" + String(renditePercent) + "%)")
                            .foregroundColor(Color.green)
                    }
                }
            }
        }
        .padding(.bottom, -50)
        .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: -50)
    }
}

struct AddButton<Destination : View>: View {

    var destination:  Destination

    var body: some View {
        NavigationLink(destination: self.destination) {
            Image(systemName: "plus")
                .resizable()
                .padding(6)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
                .foregroundColor(.white)
                .offset(x: -5, y: 0)
        }
    }
}
