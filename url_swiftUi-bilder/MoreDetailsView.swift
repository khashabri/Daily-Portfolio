//
//  MoreDetailsView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 01.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct MoreDetailsView: View {
    @State var aCompanyData: CompData
    
    var body: some View {
        NavigationView {
            VStack(){
                ZStack {
                    LogoView(name_of_company: myDic_Symb2Img[String(aCompanyData.symbol)]!)
                        .padding(.top, -90)
                        .zIndex(1)
                    
                    LineChartView(data: aCompanyData.Days100Before.reversed(), title: aCompanyData.symbol.uppercased(), legend: "3 Month Overview", form: ChartForm.large, dropShadow: false)
                        .padding(.top, 100)
                        .zIndex(0)
                }.padding(.top, -240)
                
                Spacer()
                
                DataAnalyticsView(aCompanyData: aCompanyData)
                
            }
        }
    }
}



struct MoreDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreDetailsView(aCompanyData: offlineData[0])
    }
}


struct DataAnalyticsView: View {
    @State var aCompanyData: CompData
    var body: some View {
        Form {
            Section(header:
                HStack {
                    Text("Data Analytics")
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
        }
    }
}

