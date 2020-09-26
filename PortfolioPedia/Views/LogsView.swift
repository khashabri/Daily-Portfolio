//
//  ContentView.swift
//  DoomyTesting
//
//  Created by Khashayar Abri on 30.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct LogsView: View {
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                List() {
                    ForEach(self.handelDicts.companiesEntriesDict.keys.sorted(by: <), id: \.self) {key in
                        
                        Section(header: Text(myDic_Symb2Name[key]!)) {
                            ForEach(self.handelDicts.companiesEntriesDict[key]!, id: \.self) {value in
                                TaskRow(aValue: value)
                            }.onDelete {self.removeItems(at: $0, from: key)}
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Logs"), displayMode: .inline)
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
        }
    }
    
    func removeItems(at offsets: IndexSet, from category: String) {
        let index = Int(offsets.first!)
        let removedEntry = self.handelDicts.companiesEntriesDict[category]![index]
        self.handelDicts.companiesEntriesDict[category]!.remove(at: index)
        
        // removing zeros which may be there because of deleting an earlier purchase
        self.totalNumbers.totalGainHistory = self.totalNumbers.totalGainHistory - removedEntry.gainHistory
        self.totalNumbers.totalGainHistory = removeEndZeros(self.totalNumbers.totalGainHistory)
        (self.totalNumbers.totalGainHistory.last != 0) ? self.totalNumbers.totalGainHistory.append(0) : () // gain should begin from a 0
        
        self.totalNumbers.totalInvestment -= removedEntry.totalInvestment
        self.totalNumbers.totalValue -= removedEntry.totalCurrentValue
        self.totalNumbers.rendite = self.totalNumbers.totalValue - self.totalNumbers.totalInvestment
        self.totalNumbers.renditePercent = calcRateD(x: self.totalNumbers.totalValue, y: self.totalNumbers.totalInvestment)
        
        self.handelDicts.portfolioListInvestDict[category]! -= removedEntry.totalInvestment
        self.handelDicts.portfolioListGainDict[category]! -= removedEntry.gainHistory.first!
        self.handelDicts.portfolioListShareNumberDict[category]! -= removedEntry.purchaseAmount
        
        let currentTotalValue = self.handelDicts.portfolioListInvestDict[category]! + self.handelDicts.portfolioListGainDict[category]!
        self.handelDicts.portfolioListPercentageDict[category]! = calcRateD(x: currentTotalValue, y: self.handelDicts.portfolioListInvestDict[category]!)
        
        if (self.handelDicts.companiesEntriesDict[category]!.isEmpty) {
            self.handelDicts.companiesEntriesDict.removeValue(forKey: category)
        }
        
        if (isAboutZero(self.handelDicts.portfolioListShareNumberDict[category]!) && isAboutZero(self.handelDicts.portfolioListInvestDict[category]!)) {
            self.handelDicts.portfolioListShareNumberDict.removeValue(forKey: category)
            self.handelDicts.portfolioListGainDict.removeValue(forKey: category)
            self.handelDicts.portfolioListInvestDict.removeValue(forKey: category)
            
            deleteCache_Articles(compSymbol: category)
            deleteCache_Welcome(compSymbol: category)
        }
        
        let tmpIndx = self.settings.userInputs.findByID(id: removedEntry.id)
        self.settings.userInputs.remove(at: tmpIndx!)
        
        deleteCache_CompPortfolioOutput(fileName: removedEntry.savingKey)
        
    }
}

//struct LogsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LogsView()
//    }
//}

struct TaskRow: View {
    var aValue: CompPortfolioOutput
    
    var body: some View {
        HStack{
            Text(aValue.purchaseDate)
            Spacer()
            Text(String(aValue.purchaseAmount) + " @ " + currencyString(aValue.purchasePrice))
        }
    }
}
