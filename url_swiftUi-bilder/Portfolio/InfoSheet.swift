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
    @State var aPortElement: CompPortfolioOutput
    
    var body: some View {
        VStack(){
            MarketPerformance(aPortElement: aPortElement)
        }
    }
}


struct MarketPerformance: View {
    
    @State var aPortElement: CompPortfolioOutput
    var body: some View {
        Form {
            Section(header:
                HStack {
                    HStack{
                        Image(systemName: "dollarsign.square")
                        Text("Data Analytics")
                    }
                    Spacer()
                    Text(String(aPortElement.lastRefreshed))
            }) {
                
                HStack {
                    Text("Open").bold()
                    Spacer()
                    Text(roundGoodS(x: aPortElement.open) + " $")
                }
                
                
                HStack {
                    Text("Close").bold()
                    Spacer()
                    VStack(alignment: .leading){
                        HStack{
                            Text("Daily: ")
                                .multilineTextAlignment(.leading)
                            
                            if aPortElement.priceChange1D > 0 {
                                Text(String(aPortElement.priceChange1D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.priceChange1D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Weekly: ")
                            
                            if aPortElement.priceChange5D > 0 {
                                Text(String(aPortElement.priceChange5D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.priceChange5D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Monthly: ")
                            
                            if aPortElement.priceChange1M > 0 {
                                Text(String(aPortElement.priceChange1M)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.priceChange1M)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Yearly: ")
                            
                            if aPortElement.priceChange1Y > 0 {
                                Text(String(aPortElement.priceChange1Y)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.priceChange1Y)+" %").foregroundColor(.red).bold()
                            }
                        }
                    }.offset(x: 10.5, y: 0)
                    Spacer()
                    Spacer()
                    Text(String(roundGoodD(x: aPortElement.priceHistory[0])) + " $")
                    
                }
                HStack {
                    Text("Low").bold()
                    
                    Spacer()
                    Text(roundGoodS(x: aPortElement.low) + " $")
                }
                HStack {
                    Text("High").bold()
                    
                    Spacer()
                    Text(roundGoodS(x: aPortElement.high) + " $")
                }
                HStack {
                    Text("Volume").bold()
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("Daily: ")
                                .multilineTextAlignment(.leading)
                            
                            if aPortElement.volumeChange1D > 0 {
                                Text(String(aPortElement.volumeChange1D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.volumeChange1D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Weekly: ")
                                .multilineTextAlignment(.leading)
                            if aPortElement.volumeChange5D > 0 {
                                Text(String(aPortElement.volumeChange5D)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.volumeChange5D)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Monthly: ")
                            
                            if aPortElement.volumeChange1M > 0 {
                                Text(String(aPortElement.volumeChange1M)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.volumeChange1M)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("Yealy: ")
                            
                            if aPortElement.volumeChange1Y > 0 {
                                Text(String(aPortElement.volumeChange1Y)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aPortElement.volumeChange1Y)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                    }
                    .offset(x: 20, y: 0)
                    
                    Spacer()
                    Text(aPortElement.volume)
                }
            }
            
            Section(
                header: HStack {
                    Image(systemName: "cart")
                    Text("Your Purchase Dates")
            }) {
                HStack{
                    Text("2019-09-12")
                    
                    Spacer()
                    
                    HStack(){
                        Text("22 @ 213$")
                        Text("= 4.686$")
                            .font(.subheadline).foregroundColor(.gray)
                    }
                }
                HStack{
                    Text("2019-09-12")
                    
                    Spacer()
                    
                    HStack(){
                        Text("22 @ 213$")
                        Text("= 4.686$")
                            .font(.subheadline).foregroundColor(.gray)
                        
                    }
                }
                
            }
        }
    }
}


struct InfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheet(aPortElement: compPortfolioOutputOfflineSample)
    }
}
