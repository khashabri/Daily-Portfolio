//
//  RowViewPortfolio.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct RowViewPortfolio: View {
    @State var aPortElement: CompPortfolioOutput
    
    var body: some View {
        HStack{
            HStack{
                //                LogoView(name_of_company: "Apple").padding(.trailing, 12.0)
                VStack(alignment: .leading) {
                    Text(aPortElement.compName)
                        .font(.headline)
                    
                    Text(String(aPortElement.purchaseAmount) + " @ " + String(aPortElement.purchasePrice))
                        .font(.footnote)
                }
            }
            Spacer()
            
            if aPortElement.currentGain < 0
            {
                VStack(alignment: .center){
                    Text(String(aPortElement.currentGain)+"%")
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                    Text(String(roundGoodD(x: aPortElement.gainHistory[0])))
                        .font(.footnote)
                        .foregroundColor(Color.red)
                }
            }
                
            else
            {
                VStack(alignment: .center){
                    Text(String(aPortElement.currentGain)+"%")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                    Text("+" + String(roundGoodD(x: aPortElement.gainHistory[0])))
                        .font(.footnote)
                        .foregroundColor(Color.green)
                }
            }
        }
    }
}

struct RowViewPortfolio_Previews: PreviewProvider {
    static var previews: some View {
        RowViewPortfolio(aPortElement: compPortfolioOutputOfflineSample)
    }
}
