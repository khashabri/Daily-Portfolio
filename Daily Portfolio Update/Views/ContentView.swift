//
//  SwiftUIView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 31.07.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

var settingsForPreview = UserSettings()

var totalGainHistory: [Double] = []
var lastRefreshed = ""
var totalInvestment = 0.0
var totalValue = 0.0
var rendite = 0.0
var renditePercent = 0.0

struct ContentView: View {
    
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
    // for SlideOverCard
    @State private var position = CardPosition.middle
    @State private var background = BackgroundStyle.blur
    
    var body: some View {
        TabView {
            NavigationView{
                ZStack(alignment: Alignment.top){
                    List() {
                        
                        ForEach(portfolioListInvestDict.sorted(by: <), id: \.value) {key, value in
                            
                            RowViewPortfolio(dataEntries: self.companiesEntriesDict[key]! ,Name: (self.companiesEntriesDict[key]?.first!.compName)!, portfolioListInvestDict: self.portfolioListInvestDict[key]!, portfolioListGainDict: self.portfolioListGainDict[key]!, portfolioListPercentageDict: self.portfolioListPercentageDict[key]!, portfolioListShareNumberDict: self.portfolioListShareNumberDict[key]!)
                        }
                        .onDelete(perform: self.deleteRow)
                        //                    .onMove(perform: self.move)
                    }
                    .onAppear { self.buildElements() }
                    
                    SlideOverCard($position, backgroundStyle: $background) {
                        VStack {
                            totalInfoSubview(lastRefreshed: lastRefreshed, totalInvestment: totalInvestment, totalValue: totalValue, rendite: rendite, renditePercent: renditePercent, isLoading: settingsForPreview.isLoading)
                        }
                    }
                }
                    
                .navigationBarItems(leading: EditButton(), trailing: AddButton(destination: SearchingView()))
                .navigationBarTitle(Text("Portfolio"), displayMode: .inline)
            }
                
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Portfolio")
            }
            
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
        }
    }
    
    private func buildElements() {
        for input in settings.portfolio {
            if !self.existingInputs.contains(input){
                existingInputs.append(input)
                NetworkingManagerPortfolio(userInput: input).getData { compPortfolioOutput in
                    
                    print(compPortfolioOutput)
                    
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
                    totalGainHistory = totalGainHistory + compPortfolioOutput.gainHistory
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
            settingsForPreview.isLoading = false
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        var delArr = self.portfolioListInvestDict.sorted(by: <)
        let OrgArr = delArr
        delArr.remove(atOffsets: indexSet)
        var removedKey = ""
        
        for elementOrgArr in OrgArr{
            var gefunden = false
            for elementdelArr in delArr{
                if elementOrgArr.0 == elementdelArr.0{
                    gefunden = true
                }
            }
            if gefunden == false{
                removedKey = elementOrgArr.0
            }
        }
        
        for entry in companiesEntriesDict[removedKey]!{
            totalGainHistory = totalGainHistory - entry.gainHistory
        }
        
        totalInvestment -= portfolioListInvestDict[removedKey]!
        totalValue -= (portfolioListInvestDict[removedKey]! + portfolioListGainDict[removedKey]!)
        rendite -= portfolioListGainDict[removedKey]!
        renditePercent = calcRateD(x: totalValue, y: totalInvestment)
        
        self.companiesEntriesDict[removedKey] = nil
        self.portfolioListInvestDict[removedKey] = nil
        self.portfolioListGainDict[removedKey] = nil
        self.portfolioListPercentageDict[removedKey] = nil
        self.portfolioListShareNumberDict[removedKey] = nil
        
        self.settings.portfolio.remove(atOffsets: indexSet)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(settingsForPreview)
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
                
                Section(header: ListHeader(isLoading: isLoading), footer: Text("Last database update on: " + lastRefreshed)) {
                    HStack {
                        Text("Investment")
                        Spacer()
                        Text(currencyString(x: totalInvestment))
                    }
                    HStack {
                        Text("Current Value")
                        Spacer()
                        Text(currencyString(x: totalValue))
                    }
                    HStack {
                        Text("Rendite")
                        Spacer()
                        if roundGoodD(x: rendite) < 0 {
                            Text(currencyString(x: rendite) + " (" + String(abs(renditePercent)) + "%)")
                                .foregroundColor(Color.red)
                        }
                        else {
                            Text("+" + currencyString(x: rendite) + " (" + String(renditePercent) + "%)")
                                .foregroundColor(Color.green)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}


struct ListHeader: View {
    let isLoading: Bool
    var body: some View {
        HStack {
            Image(systemName: "sum")
            Text("Total Result")
            Spacer()
            if(isLoading){
                ActivityIndicator().frame(width: 23, height: 23)
                Text("Loading...").bold()
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
