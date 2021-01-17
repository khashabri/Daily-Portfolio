//
//  RowViewPortfolio.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct RowViewPortfolio: View {
    @State var showingDetail = false
    
    @State var dataEntries: [CompPortfolioOutput]
    @State var Name: String
    @State var portfolioListInvestDict: Double
    @State var portfolioListGainDict: Double
    @State var portfolioListPercentageDict: Double
    @State var portfolioListShareNumberDict: Double
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        HStack{
            HStack{
                //                Image("tesla.com")
                if settings.showLogos{
                    Image(myDic_Symb2Img[dataEntries[0].compSymbol]!)
                        .resizable()
                        .frame(height: 40)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading) {
                    Text(Name)
                        .font(.headline)
                    
                    Text(String(portfolioListShareNumberDict) + " @ " + currencyString(portfolioListInvestDict/portfolioListShareNumberDict, symbol: "$"))
                        .font(.footnote)
                }
            }
            Spacer()
            
            if portfolioListGainDict < 0
            {
                VStack(alignment: .trailing){
                    Text(String(portfolioListPercentageDict)+"%")
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                    Text(currencyString(portfolioListGainDict, symbol: "$"))
                        .font(.footnote)
                        .foregroundColor(Color.red)
                }
            }
                
            else
            {
                VStack(alignment: .trailing){
                    Text(String(portfolioListPercentageDict)+"%")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                    Text("+" + currencyString(portfolioListGainDict, symbol: "$"))
                        .font(.footnote)
                        .foregroundColor(Color.green)
                }
            }
        }.frame(height: 40)
    }
}

struct RowViewPortfolio_Previews: PreviewProvider {
    static var previews: some View {
        RowViewPortfolio(dataEntries: SampleData().companiesEntriesDict["SNAP"]!, Name: "Apple Inc.", portfolioListInvestDict: 1230, portfolioListGainDict: 400, portfolioListPercentageDict: 40, portfolioListShareNumberDict: 5)
    }
}
