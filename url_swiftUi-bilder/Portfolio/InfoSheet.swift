//
//  InfoSheet.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import SwiftUICharts

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
                    Text(roundGoodS(x: dataEntries[0].open) + " $")
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
                    }.offset(x: 10.5, y: 0)
                    Spacer()
                    Text(String(roundGoodD(x: dataEntries[0].priceHistory[0])) + " $")
                        .minimumScaleFactor(0.5)
                }
                HStack {
                    Text("Low").bold()
                    
                    Spacer()
                    Text(roundGoodS(x: dataEntries[0].low) + " $")
                }
                HStack {
                    Text("High").bold()
                    
                    Spacer()
                    Text(roundGoodS(x: dataEntries[0].high) + " $")
                }
                HStack {
                    Text("Volume").bold()
                    
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
                    .offset(x: 20, y: 0)
                    .minimumScaleFactor(0.5)
                    
                    Spacer()
                    Text(dataEntries[0].volume)
                }
            }
            
            purchaseDatesSubView(dataEntries: dataEntries)
        }
    }
}


struct InfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheet(dataEntries: [compPortfolioOutputOfflineSample])
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
                        Text(String(dataEntry.purchaseAmount) + " @ " + String(dataEntry.purchasePrice) + "$")
                        Text("= " + String(dataEntry.totalInvestment) + "$")
                            .font(.subheadline).foregroundColor(.gray)
                    }.lineLimit(1)
                    .minimumScaleFactor(0.1)
                }
            }
        }
    }
}
