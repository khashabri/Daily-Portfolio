//
//  SwiftUIView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 31.07.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var existingInputs = [UserInput]()
    @State var handelDicts = HandelDicts()
    @State var totalNumbers = TotalNumbers()
    @State var loadingState: LoadingState
    @State var erroredComps = [String]()
    
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
                GeometryReader { geometry in
                    ZStack(alignment: Alignment.top){
                        List() {
                            
                            ForEach(self.handelDicts.portfolioListInvestDict.sorted(by: <), id: \.value) {key, value in
                                
                                NavigationLink(destination: MoreInfo(dataEntries: self.handelDicts.companiesEntriesDict[key]!)) {
                                    RowViewPortfolio(dataEntries: self.handelDicts.companiesEntriesDict[key]! ,Name: (self.handelDicts.companiesEntriesDict[key]?.first!.compName)!, portfolioListInvestDict: self.handelDicts.portfolioListInvestDict[key]!, portfolioListGainDict: self.handelDicts.portfolioListGainDict[key]!, portfolioListPercentageDict: self.handelDicts.portfolioListPercentageDict[key]!, portfolioListShareNumberDict: self.handelDicts.portfolioListShareNumberDict[key]!)
                                }
                            }
                            .onDelete(perform: self.deleteRow)
                        }
                        .listStyle(DefaultListStyle())
                        .onAppear{ buildElements() }
                        
                        if colorScheme == .dark{
                            SlideOverCardBlack(tabBarHeight: .constant(geometry.size.height-22), $position, backgroundStyle: $background) {
                                VStack {
                                    totalInfoSubview(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts, loadingState: self.$loadingState, erroredComps: self.$erroredComps)
                                }
                            }
                        }else{
                            SlideOverCardLight(tabBarHeight: .constant(geometry.size.height-22), $position, backgroundStyle: $background) {
                                VStack {
                                    totalInfoSubview(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts, loadingState: self.$loadingState, erroredComps: self.$erroredComps)
                                }
                            }
                        }
                    }
                }
                
                .navigationBarItems(leading: EditButton(), trailing: AddButton(destination: SearchingView()))
                .navigationBarTitle(Text("Portfolio"))
            }
            
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Portfolio")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.existingInputs = [UserInput]()
                self.handelDicts = HandelDicts()
                self.totalNumbers = TotalNumbers()
                self.buildElements()
            }
            
            //            TopNewsView().environmentObject(self.settings)
            //                .tabItem {
            //                    Image(systemName: "flame")
            //                    Text("Top News")
            //                }
            
            SettingView(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts).environmentObject(self.settings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
    
    private func buildElements() {
        // Do nothing if everything is there
        if self.existingInputs.containsSameElements(as: self.settings.userInputs){
            self.loadingState = .allDone
            return
        }
        
        self.loadingState = .isLoading
        var pionierInputs = [UserInput]()
        var followerInputs = [UserInput]()
        self.erroredComps = []
        
        var names = self.settings.userInputs.map{ $0.compName }
        names = Array(Set(names))
        
        for name in names{
            var tmp = self.settings.userInputs.filter{ $0.compName == name }
            pionierInputs.append(tmp.removeFirst())
            followerInputs.append(contentsOf: tmp)
        }
        // first fetching data of an input per Company
        let pionierGroup = DispatchGroup()
        for input in pionierInputs {
            pionierGroup.enter()
            
            if !self.existingInputs.contains(input){
                NetworkingManagerPortfolio(userInput: input).getData { result in
                    switch result {
                    case .success(let compPortfolioOutput):
                        self.existingInputs.append(input)
                        calculate(compPortfolioOutput: compPortfolioOutput)
                        pionierGroup.leave()
                        
                    case .failure(let networkError):
                        switch networkError {
                        case .badURL(let compName):
                            self.loadingState = .errorOccured(errorType: .badURL(compName: compName))
                            let erroredCompName = compName
                            self.erroredComps.contains(erroredCompName) ? () : self.erroredComps.append(erroredCompName)
                            
                        case .badDate(let compName):
                            self.loadingState = .errorOccured(errorType: .badDate(compName: compName))
                            let erroredCompName = compName
                            self.erroredComps.contains(erroredCompName) ? () : self.erroredComps.append(erroredCompName)
                            
                            // Removing the bad entry from portfolio. If let because it might be already deleted
                            if let tmpIndx = self.settings.userInputs.findByID(id: input.id){
                                self.settings.userInputs.remove(at: tmpIndx)
                            }
                        }
                    }
                }
            }else{
                pionierGroup.leave() // you can't remove these because otherwise it will done before dispatch
            }
        }
        
        // second fetching data of other inputs so they can be done offline
        pionierGroup.notify(queue: .main) {
            let followerGroup = DispatchGroup()
            for input in followerInputs {
                followerGroup.enter()
                
                if !self.existingInputs.contains(input){
                    NetworkingManagerPortfolio(userInput: input).getData { result in
                        switch result {
                        case .success(let compPortfolioOutput):
                            self.existingInputs.append(input)
                            calculate(compPortfolioOutput: compPortfolioOutput)
                            followerGroup.leave()
                            
                        case .failure(let networkError):
                            switch networkError {
                            case .badURL( _): break
                            // this will actually never happend, since it is done offline
                                
                            case .badDate(let compName):
                                self.loadingState = .errorOccured(errorType: .badDate(compName: compName))
                                let erroredCompName = compName
                                self.erroredComps.contains(erroredCompName) ? () : self.erroredComps.append(erroredCompName)
                                
                                // removing the bad entry from portfolio. If let because it might be already deleted
                                if let tmpIndx = self.settings.userInputs.findByID(id: input.id){
                                    self.settings.userInputs.remove(at: tmpIndx)
                                }
                            }
                        }
                    }
                }else{
                    followerGroup.leave() // you can't remove these because otherwise it will done before dispatch
                }
            }
            
            followerGroup.notify(queue: .main) {
                // finished
                self.loadingState = .allDone
            }
        }
    }
    
    private func calculate(compPortfolioOutput: CompPortfolioOutput) {
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
        !(isAboutZero(self.totalNumbers.totalGainHistory.last!)) ? self.totalNumbers.totalGainHistory.append(0) : () // gain should begin from a 0
        
        self.totalNumbers.totalInvestment -= handelDicts.portfolioListInvestDict[removedKey]!
        self.totalNumbers.totalValue -= (handelDicts.portfolioListInvestDict[removedKey]! + handelDicts.portfolioListGainDict[removedKey]!)
        self.totalNumbers.rendite -= handelDicts.portfolioListGainDict[removedKey]!
        self.totalNumbers.renditePercent = calcRateD(x: self.totalNumbers.totalValue, y: self.totalNumbers.totalInvestment)
        (self.totalNumbers.totalGainHistory.count == 1 && isAboutZero(self.totalNumbers.totalGainHistory[0])) ? self.totalNumbers.totalGainHistory = [Double]() : ()
        
        self.handelDicts.companiesEntriesDict[removedKey] = nil
        self.handelDicts.portfolioListInvestDict[removedKey] = nil
        self.handelDicts.portfolioListGainDict[removedKey] = nil
        self.handelDicts.portfolioListPercentageDict[removedKey] = nil
        self.handelDicts.portfolioListShareNumberDict[removedKey] = nil
        
        while let indx = self.settings.userInputs.firstIndex(where: {$0.compSymbol == removedKey}) {
            deleteCache_CompPortfolioOutput(fileName: savingKeyMaker(self.settings.userInputs[indx]))
            self.settings.userInputs.remove(at: indx)
        }
        
        deleteCache_Welcome(compSymbol: removedKey)
        deleteCache_Articles(compSymbol: removedKey)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    // doomy object for making the preview visible
    static var settingsForPreview = UserSettings(userInputs: SampleData().userInputs, subscribed: false, notificationsEnabled: false)
    
    static var previews: some View {
        ContentView(loadingState: LoadingState.allDone).environmentObject(self.settingsForPreview)
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
    @Binding var loadingState: LoadingState
    @Binding var erroredComps: [String]
    
    @State var showCharts = false
    @State var showLogs = false
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack{
            Form{
                
                Section(header: totalInfoHeader(loadingState: $loadingState,handelDicts: $handelDicts ,totalNumbers: $totalNumbers, erroredComps: $erroredComps), footer: totalInfoFooter(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts, showLogs: self.$showLogs)) {
                    HStack {
                        Text("Investment")
                        Spacer()
                        Text(currencyString(totalNumbers.totalInvestment))
                            .animation(nil)
                    }
                    HStack {
                        Text("Current Value")
                        Spacer()
                        Text(currencyString(totalNumbers.totalValue))
                            .animation(nil)
                    }
                    HStack {
                        Text("Yield")
                        Spacer()
                        if loadingState.type() == "allDone"{
                            Button(action: { self.showCharts.toggle()}){
                                HStack{
                                    Image(systemName: "chart.pie")
                                }
                            }
                        }
                        
                        if roundGoodD(totalNumbers.rendite) < 0 {
                            Text(currencyString(totalNumbers.rendite) + " (" + String(abs(totalNumbers.renditePercent)) + "%)")
                                .foregroundColor(Color.red)
                                .animation(nil)
                        }
                        else {
                            Text("+" + currencyString(totalNumbers.rendite) + " (" + String(totalNumbers.renditePercent) + "%)")
                                .foregroundColor(Color.green)
                                .animation(nil)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCharts) {ChartView(totalNumbers: self.totalNumbers, handelDicts: self.handelDicts)}
            .background(EmptyView()
                            .sheet(isPresented: $showLogs) {LogsView(totalNumbers: self.$totalNumbers, handelDicts: self.$handelDicts).environmentObject(self.settings)})
            
            
            Spacer()
        }
    }
}


struct totalInfoHeader: View {
    @Binding var loadingState: LoadingState
    @Binding var handelDicts: HandelDicts
    @Binding var totalNumbers: TotalNumbers
    @Binding var erroredComps: [String]
    @State private var showingErrorAlert = false
    @State private var showingUpToDateAlert = false
    
    var body: some View {
        HStack {
            Image(systemName: "sum")
                .foregroundColor(.green)
            Text("Total Result")
                .bold()
                .gradientForeground(colors: [.green, .orange, .red])
            Spacer()
            switch loadingState{
            case .isLoading:
                HStack{
                    ActivityIndicator().frame(width: 23, height: 23)
                    Text("Fetching latest data...").bold()
                }
                .padding(.leading, 15)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            case .errorOccured(let errorType):
                switch errorType{
                case .badURL( _):
                    HStack{
                        Button(action: {
                            self.showingErrorAlert = true
                        }) {
                            Image(systemName: "exclamationmark.bubble")
                                .foregroundColor(.orange)
                            Text("Something went wrong. Retry shortly.").bold()
                                .foregroundColor(.gray)
                                .modifier(lowerCase())
                        }
                        .alert(isPresented: $showingErrorAlert) {
                            Alert(title: Text("Error Message"), message: Text("Server didn't fully respond for the following companies: " + erroredComps.joined(separator: ", ")), dismissButton: .default(Text("Dismiss")))
                        }
                    }
                    .padding(.leading, 15)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                case .badDate( _):
                    HStack{
                        Button(action: {
                            self.showingErrorAlert = true
                        }) {
                            Image(systemName: "exclamationmark.bubble")
                                .foregroundColor(.orange)
                            Text("Invalid date!").bold()
                                .foregroundColor(.gray)
                                .modifier(lowerCase())
                        }
                        .alert(isPresented: $showingErrorAlert) {
                            Alert(title: Text("Error Message"), message: Text("It seems that the following company has had no IPO at that time: " + erroredComps.joined(separator: ", ")), dismissButton: .default(Text("Dismiss")))
                        }
                    }
                    .padding(.leading, 15)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                }

            case .allDone:
                Button(action: { self.showingUpToDateAlert = true }) {
                    Text("Up to date")
                        .foregroundColor(.gray)
                        .modifier(lowerCase())
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.purple)
                }.alert(isPresented: $showingUpToDateAlert) {
                    Alert(title: Text("Up to date!"), message: Text("Your portfolio is already updated. Next server check will be on:\n" + nextServerCheck()), dismissButton: .default(Text("Got it!")))
                } 
            }
        }
    }
}

struct totalInfoFooter: View {
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    @Binding var showLogs: Bool
    
    var body: some View {
        HStack {
            Text("Last market closure: " + totalNumbers.lastRefreshed)
                .padding(.trailing, 30)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            Spacer()
            Button(action: { self.showLogs.toggle()}){
                HStack{
                    Image(systemName: "pencil.and.ellipsis.rectangle")
                    Text("View Logs")
                }.foregroundColor(.blue)
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
