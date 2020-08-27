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
var isLoading = false

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
                    .onDelete(perform: self.deleteRow)
                    .onMove(perform: self.move)
                }
                .onAppear { self.buildElements() }
                .navigationBarItems(leading: EditButton(), trailing: AddButton(destination: SearchingView()))
                
                totalInfoSubview(lastRefreshed: lastRefreshed, totalInvestment: totalInvestment, totalValue: totalValue, rendite: rendite, renditePercent: renditePercent, isLoading: isLoading)
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
        
        withAnimation{
            isLoading = false
        }
    }
    
//    private func deleteRow(at indexSet: IndexSet) {
//        let x = self.portfolioListInvestDict.sorted(by: >)
//        x.remove(atOffsets: indexSet)
//        self.settings.portfolio.remove(atOffsets: indexSet)
//    }
//    
//    private func move(from source: IndexSet, to destination: Int) {
//        wholeData.move(fromOffsets: source, toOffset: destination)
//    }
    
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
    let isLoading: Bool
    
    
    var body: some View {
        VStack{
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
            .padding(.bottom, -200)
            .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: -50)
            
            Spacer()
            if(isLoading){
                HStack{
                    ActivityIndicator().frame(width: 25, height: 25)
                    Text("Loading...")
                }.padding(15)
                    .transition(.scale)
            }
        }
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

struct ActivityIndicator: View {
    
    @State private var isAnimating: Bool = false
    
    
    
    var body: some View {
        
        GeometryReader { (geometry: GeometryProxy) in
            
            ForEach(0..<5) { index in
                
                Group {
                    
                    Circle()
                        
                        .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                        
                        .scaleEffect(!self.isAnimating ? 1 - CGFloat(index) / 5 : 0.2 + CGFloat(index) / 5)
                        
                        .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
                    
                }.frame(width: geometry.size.width, height: geometry.size.height)
                    
                    .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                    
                    .animation(Animation
                        
                        .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                        
                        .repeatForever(autoreverses: false))
                
            }
            
        }.aspectRatio(1, contentMode: .fit)
            
            .onAppear {
                
                self.isAnimating = true
                
        }
        
    }
    
}
