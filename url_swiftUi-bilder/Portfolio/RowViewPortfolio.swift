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
    
    @State var aPortElement: CompPortfolioOutput
    @State var Name: String
    @State var portfolioListInvestDict: Double
    @State var portfolioListGainDict: Double
    @State var portfolioListPercentageDict: Double
    @State var portfolioListShareNumberDict: Double
        
    var body: some View {
        HStack{
            HStack{
                //                LogoView(name_of_company: "Apple").padding(.trailing, 12.0)
                VStack(alignment: .leading) {
                    Text(Name)
                        .font(.headline)
                    
                    Text(String(portfolioListShareNumberDict) + " @ " + String(roundGoodD(x: portfolioListInvestDict/portfolioListShareNumberDict)))
                        .font(.footnote)
                }
            }
            Spacer()
            
            if portfolioListGainDict < 0
            {
                VStack(alignment: .center){
                    Text(String(portfolioListPercentageDict)+"%")
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                    Text(String(roundGoodD(x: portfolioListGainDict)) + "$")
                        .font(.footnote)
                        .foregroundColor(Color.red)
                }
            }
                
            else
            {
                VStack(alignment: .center){
                    Text(String(portfolioListPercentageDict)+"%")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                    Text("+" + String(roundGoodD(x: portfolioListGainDict)) + "$")
                        .font(.footnote)
                        .foregroundColor(Color.green)
                }
            }
            Button(action: {
                self.showingDetail.toggle()
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.accentColor)
            }.sheet(isPresented: $showingDetail) {
                MoreInfo()
            }
        }
    }
}

//struct RowViewPortfolio_Previews: PreviewProvider {
//    static var previews: some View {
//        RowViewPortfolio(aPortElement: compPortfolioOutputOfflineSample)
//    }
//}
