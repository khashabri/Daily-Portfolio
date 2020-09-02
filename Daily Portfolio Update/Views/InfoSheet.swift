//
//  InfoSheet.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct InfoSheet: View {
    
    //    @State var aCompanyData: CompData = offlineData[0]
    @State var dataEntries: [CompPortfolioOutput]
    
    var body: some View {
        VStack(){
            MarketPerformance(dataEntries: dataEntries)
        }
    }
}


struct MarketPerformance: View {
    
    @State var dataEntries: [CompPortfolioOutput]
    var body: some View {
        Form {
            Section(header:
                HStack {
                    HStack{
                        Image(systemName: "dollarsign.square")
                        Text("Data Analytics")
                    }
                    Spacer()
                    Text(String(dataEntries[0].lastRefreshed))
            }) {
                
                HStack {
                    Text("Open").bold()
                    Spacer()
                    Text(currencyString(dataEntries[0].open))
                }
                
                
                HStack {
                    Text("Close").bold()
                    Spacer()
                    VStack(alignment: .leading){
                        HStack{
                            Text("Daily: ")
                                .multilineTextAlignment(.leading)
                            
                            if dataEntries[0].priceChange1D > 0 {
                                Text(String(dataEntries[0].priceChange1D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].priceChange1D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Weekly: ")
                            
                            if dataEntries[0].priceChange5D > 0 {
                                Text(String(dataEntries[0].priceChange5D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].priceChange5D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Monthly: ")
                            
                            if dataEntries[0].priceChange1M > 0 {
                                Text(String(dataEntries[0].priceChange1M)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].priceChange1M)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Yearly: ")
                            
                            if dataEntries[0].priceChange1Y > 0 {
                                Text(String(dataEntries[0].priceChange1Y)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].priceChange1Y)+" %").foregroundColor(.red).bold()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    
                    Spacer()
                    Text(currencyString(dataEntries[0].priceHistory[0]))
                        .minimumScaleFactor(0.5)
                }
                HStack {
                    Text("Low").bold()
                    
                    Spacer()
                    Text(currencyString(dataEntries[0].low))
                }
                HStack {
                    Text("High").bold()
                    
                    Spacer()
                    Text(currencyString(dataEntries[0].high))
                }
                HStack {
                    Text("Volume").bold()
                    Spacer()
                    VStack(alignment: .leading){
                        HStack{
                            Text("Daily: ")
                                .multilineTextAlignment(.leading)
                            
                            if dataEntries[0].volumeChange1D > 0 {
                                Text(String(dataEntries[0].volumeChange1D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].volumeChange1D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Weekly: ")
                                .multilineTextAlignment(.leading)
                            if dataEntries[0].volumeChange5D > 0 {
                                Text(String(dataEntries[0].volumeChange5D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].volumeChange5D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Monthly: ")
                            
                            if dataEntries[0].volumeChange1M > 0 {
                                Text(String(dataEntries[0].volumeChange1M)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].volumeChange1M)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Yealy: ")
                            
                            if dataEntries[0].volumeChange1Y > 0 {
                                Text(String(dataEntries[0].volumeChange1Y)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(dataEntries[0].volumeChange1Y)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal)
                    
                    
                    
                    Spacer()
                    Text(currencyString(dataEntries[0].volume, symbol: "").dropLast(3))
                }
            }
            
            if dataEntries[0].dividendDict.keys.isEmpty {
                noDividendSubView()
            }
            else{
                dividendSubView(compPortfolioOutput: dataEntries[0])
            }
            
            purchaseDatesSubView(dataEntries: dataEntries)
        }
    }
}

struct InfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheet(dataEntries: SampledataEntry["SNAP"]!)
    }
}

struct purchaseDatesSubView: View {
    @State var dataEntries: [CompPortfolioOutput]
    
    var body: some View {
        Section(
            header: HStack {
                Image(systemName: "cart")
                Text("Your Purchase Dates")
        }) {
            ForEach(dataEntries){dataEntry in
                HStack{
                    Text(dataEntry.purchaseDate)
                    
                    Spacer()
                    
                    HStack(){
                        Text(String(dataEntry.purchaseAmount) + " @ " + currencyString(dataEntry.purchasePrice, symbol: "$"))
                        Text("= " + currencyString(dataEntry.totalInvestment, symbol: "$"))
                            .font(.subheadline).foregroundColor(.gray)
                    }.lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
        }
    }
}

struct dividendSubView: View {
    @State var compPortfolioOutput: CompPortfolioOutput
    
    var body: some View {
        Section(
            header: HStack {
                Image(systemName: "creditcard")
                Text("Some of last devidend dates")
        }) {
            ForEach(self.compPortfolioOutput.dividendDict.keys.sorted(by: >), id: \.self) { key in
                HStack{
                    Text(key)
                    
                    Spacer()
                    
                    HStack(){
                        Text(currencyString(self.compPortfolioOutput.dividendDict[key]!))
                        
                    }.lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
        }
    }
}

struct noDividendSubView: View {
    var body: some View {
        Section(
            header: HStack {
                Image(systemName: "dollarsign.circle")
                Text("Some of last devidend dates")})
        {
            Text("No dividend das been registered.")
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
    }
}

