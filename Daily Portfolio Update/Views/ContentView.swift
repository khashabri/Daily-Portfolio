//
//  SwiftUIView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 31.07.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var existingInputs: [UserInput] = []
    @State var handelDicts = HandelDicts()
    @State var totalNumbers = TotalNumbers()
    @State var isLoading: Bool
    
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
                        
                        ForEach(self.handelDicts.portfolioListInvestDict.sorted(by: <), id: \.value) {key, value in
                            
                            NavigationLink(destination: MoreInfo(dataEntries: self.handelDicts.companiesEntriesDict[key]!)) {
                                RowViewPortfolio(dataEntries: self.handelDicts.companiesEntriesDict[key]! ,Name: (self.handelDicts.companiesEntriesDict[key]?.first!.compName)!, portfolioListInvestDict: self.handelDicts.portfolioListInvestDict[key]!, portfolioListGainDict: self.handelDicts.portfolioListGainDict[key]!, portfolioListPercentageDict: self.handelDicts.portfolioListPercentageDict[key]!, portfolioListShareNumberDict: self.handelDicts.portfolioListShareNumberDict[key]!)
                            }
                        }
                        .onDelete(perform: self.deleteRow)
                    }
                    .onAppear { self.buildElements() }
                    
                    SlideOverCard($position, backgroundStyle: $background) {
                        VStack {
                            totalInfoSubview(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts, isLoading: self.$isLoading)
                        }
                    }
                }
                    
                .navigationBarItems(leading: EditButton(), trailing: AddButton(destination: SearchingView(isLoading: self.$isLoading)))
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
        let myGroup = DispatchGroup()
        
        for input in settings.portfolio {
            myGroup.enter()
            
            if !self.existingInputs.contains(input){
                existingInputs.append(input)
                NetworkingManagerPortfolio(userInput: input).getData { compPortfolioOutput in
                    
                    print(compPortfolioOutput)
                    
                    // Catching Data of companies
                    let key = compPortfolioOutput.compSymbol
                    if self.handelDicts.companiesEntriesDict.keys.contains(key){
                        
                        self.handelDicts.companiesEntriesDict[key]?.append(compPortfolioOutput)
                        self.handelDicts.portfolioListInvestDict[key]! += compPortfolioOutput.totalInvestment
                        self.handelDicts.portfolioListGainDict[key]! += compPortfolioOutput.gainHistory[0]
                        self.handelDicts.portfolioListShareNumberDict[key]! += compPortfolioOutput.purchaseAmount
                        
                    }
                    else{
                        self.handelDicts.companiesEntriesDict[key] = [compPortfolioOutput]
                        self.handelDicts.portfolioListInvestDict[key] = compPortfolioOutput.totalInvestment
                        self.handelDicts.portfolioListGainDict[key] = compPortfolioOutput.gainHistory[0]
                        self.handelDicts.portfolioListShareNumberDict[key] = compPortfolioOutput.purchaseAmount
                        
                    }
                    
                    let currentPrice = compPortfolioOutput.priceHistory[0]
                    // Catching data for the Portfolio List (some are above)
                    self.handelDicts.portfolioListPercentageDict[key] = calcRateD(x: currentPrice * self.handelDicts.portfolioListShareNumberDict[key]!, y: self.handelDicts.portfolioListInvestDict[key]!)
                    
                    // Calc data for "Total Result" section
                    self.totalNumbers.totalInvestment += compPortfolioOutput.totalInvestment
                    self.totalNumbers.totalValue += compPortfolioOutput.totalCurrentValue
                    self.totalNumbers.rendite = self.totalNumbers.totalValue - self.totalNumbers.totalInvestment
                    self.totalNumbers.renditePercent = calcRateD(x: self.totalNumbers.totalValue, y: self.totalNumbers.totalInvestment)
                    self.totalNumbers.totalGainHistory = self.totalNumbers.totalGainHistory + compPortfolioOutput.gainHistory
                    self.totalNumbers.lastRefreshed = compPortfolioOutput.lastRefreshed
                    
                    myGroup.leave()
                }
            }else{
                myGroup.leave() // you can't remove these because otherwise it will done before dispatch
            }
        }
        
        myGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        var delArr = self.handelDicts.portfolioListInvestDict.sorted(by: <)
        let OrgArr = delArr
        delArr.remove(atOffsets: indexSet)
        var removedKey = ""
        
        for elementOrgArr in OrgArr{
            var gefunden = false
            for elementdelArr in delArr{
                (elementOrgArr.0 == elementdelArr.0) ? (gefunden = true) : ()
            }
            
            (gefunden == false) ? (removedKey = elementOrgArr.0) : ()
        }
        
        for entry in self.handelDicts.companiesEntriesDict[removedKey]!{
            self.totalNumbers.totalGainHistory = self.totalNumbers.totalGainHistory - entry.gainHistory
        }
        // removing zeros which may be there because of deleting an earlier purchase
        self.totalNumbers.totalGainHistory = removeEndZeros(self.totalNumbers.totalGainHistory)
        (self.totalNumbers.totalGainHistory.last != 0) ? self.totalNumbers.totalGainHistory.append(0) : () // gain should begin from a 0
        
        self.totalNumbers.totalInvestment -= handelDicts.portfolioListInvestDict[removedKey]!
        self.totalNumbers.totalValue -= (handelDicts.portfolioListInvestDict[removedKey]! + handelDicts.portfolioListGainDict[removedKey]!)
        self.totalNumbers.rendite -= handelDicts.portfolioListGainDict[removedKey]!
        self.totalNumbers.renditePercent = calcRateD(x: self.totalNumbers.totalValue, y: self.totalNumbers.totalInvestment)
        
        self.handelDicts.companiesEntriesDict[removedKey] = nil
        self.handelDicts.portfolioListInvestDict[removedKey] = nil
        self.handelDicts.portfolioListGainDict[removedKey] = nil
        self.handelDicts.portfolioListPercentageDict[removedKey] = nil
        self.handelDicts.portfolioListShareNumberDict[removedKey] = nil
        
        self.settings.portfolio.remove(atOffsets: indexSet)
    }
}

struct ContentView_Previews: PreviewProvider {
    // doomy object for making the preview visible
    static var settingsForPreview = UserSettings()
    
    static var previews: some View {
        ContentView(isLoading: true).environmentObject(self.settingsForPreview)
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

struct totalInfoSubview: View {
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack{
            Form{
                
                Section(header: totalInfoHeader(isLoading: $isLoading, totalNumbers: $totalNumbers), footer: totalInfoFooter(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts)) {
                    HStack {
                        Text("Investment")
                        Spacer()
                        Text(currencyString(totalNumbers.totalInvestment))
                    }
                    HStack {
                        Text("Current Value")
                        Spacer()
                        Text(currencyString(totalNumbers.totalValue))
                    }
                    HStack {
                        Text("Rendite")
                        Spacer()
                        if roundGoodD(totalNumbers.rendite) < 0 {
                            Text(currencyString(totalNumbers.rendite) + " (" + String(abs(totalNumbers.renditePercent)) + "%)")
                                .foregroundColor(Color.red)
                        }
                        else {
                            Text("+" + currencyString(totalNumbers.rendite) + " (" + String(totalNumbers.renditePercent) + "%)")
                                .foregroundColor(Color.green)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}


struct totalInfoHeader: View {
    @Binding var isLoading: Bool
    @Binding var totalNumbers: TotalNumbers
    @State var showPlot = false
    
    var body: some View {
        HStack {
            Image(systemName: "sum")
            Text("Total Result")
            Spacer()
            if(isLoading){
                ActivityIndicator().frame(width: 23, height: 23)
                Text("Loading...").bold()
            }
            else{
                Button(action: { self.showPlot.toggle()}){
                    HStack{
                        Image(systemName: "paintbrush")
                        Text("Chart")
                    }
                    .sheet(isPresented: $showPlot) {ChartView(totalNumbers: self.totalNumbers)}
                }
            }
        }
    }
}

struct totalInfoFooter: View {
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    
    @State var showLogs = false
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        HStack {
            Text("Last database update on: " + totalNumbers.lastRefreshed)
            Spacer()
            Button(action: { self.showLogs.toggle()}){
                HStack{
                    Image(systemName: "pencil.and.ellipsis.rectangle")
                    Text("View Logs")
                }
                .sheet(isPresented: $showLogs) {LogsView(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts).environmentObject(self.settings)}
            }
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
