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
    
    @State var aCompanyData: CompData = offlineData[0]
//    @State var aCompanyData: CompPortfolioOutput
    
    var body: some View {
            VStack(){
                MarketPerformance(aCompanyData: aCompanyData)
            }
    }
}


struct MarketPerformance: View {
    
    @State var aCompanyData: CompData
    var body: some View {
        Form {
            Section(header:
                HStack {
                    HStack{
                        Image(systemName: "dollarsign.square")
                        Text("Data Analytics")
                    }
                    Spacer()
                    Text(String(aCompanyData.lastRefreshed))
            }) {
                
                HStack {
                    Text("Open").bold()
                    Spacer()
                    Text(roundGoodS(x: aCompanyData.s_open) + " $")
                }
                
                
                HStack {
                    Text("Close").bold()
                    Spacer()
                    VStack(alignment: .leading){
                        HStack{
                            Text("1 Day: ")
                                .multilineTextAlignment(.leading)
                            
                            if aCompanyData.pchange > 0 {
                                Text(String(aCompanyData.pchange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.pchange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("1 Week: ")
                            
                            if aCompanyData.closeWeekChange > 0 {
                                Text(String(aCompanyData.closeWeekChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.closeWeekChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("1 Month: ")
                            
                            if aCompanyData.close1MChange > 0 {
                                Text(String(aCompanyData.close1MChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.close1MChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("3 Months: ")
                            
                            if aCompanyData.close3MChange > 0 {
                                Text(String(aCompanyData.close3MChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.close3MChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                    }.offset(x: 10.5, y: 0)
                    Spacer()
                    Spacer()
                    Text(roundGoodS(x: aCompanyData.s_close) + " $")
                    
                }
                HStack {
                    Text("Low").bold()
                    
                    Spacer()
                    Text(roundGoodS(x: aCompanyData.s_low) + " $")
                }
                HStack {
                    Text("High").bold()
                    
                    Spacer()
                    Text(roundGoodS(x: aCompanyData.s_high) + " $")
                }
                HStack {
                    Text("Volume").bold()
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("1 Day: ")
                                .multilineTextAlignment(.leading)
                            
                            if aCompanyData.volumeDayChange > 0 {
                                Text(String(aCompanyData.volumeDayChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.volumeDayChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("1 Week: ")
                                .multilineTextAlignment(.leading)
                            if aCompanyData.volumeWeekChange > 0 {
                                Text(String(aCompanyData.volumeWeekChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.volumeWeekChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("1 Month: ")
                            
                            if aCompanyData.volume1MChange > 0 {
                                Text(String(aCompanyData.volume1MChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.volume1MChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                        HStack{
                            Text("3 Months: ")
                            
                            if aCompanyData.volume3MChange > 0 {
                                Text(String(aCompanyData.volume3MChange)+" %").foregroundColor(.green).bold()
                            } else {
                                Text(String(aCompanyData.volume3MChange)+" %").foregroundColor(.red).bold()
                            }
                        }
                        
                    }
                    .offset(x: 20, y: 0)
                    
                    Spacer()
                    Text(aCompanyData.s_volume)
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
        InfoSheet()
    }
}
