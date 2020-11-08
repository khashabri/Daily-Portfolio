//
//  MoreInfo.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct MoreInfo: View {
    @State var dataEntries: [CompPortfolioOutput]
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack() {
            HStack() {
                if settings.showLogos{
                    Image(myDic_Symb2Img[dataEntries[0].compSymbol]!)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(10)
                        .padding(.leading)
                        .padding(.leading)
                }
                VStack() {
                    HStack() {
                        Text("Name:")
                            .font(.headline)
                            .padding(.leading, 10)
                        Text(dataEntries[0].compName)
                        Spacer()
                    }
                    HStack() {
                        Text("Market Symbol:")
                            .font(.headline)
                            .padding(.leading, 10)
                        Text(dataEntries[0].compSymbol)
                        Spacer()
                    }
                }
            }
            .frame(height: 45)
            .padding(.top, 9)
            Spacer()
            InfoSheet(dataEntries: dataEntries)
        }
        .minimumScaleFactor(0.1)
        .lineLimit(1)
        
        .navigationBarTitle("Overview", displayMode: .inline)        
    }
}


struct MoreInfo_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfo(dataEntries: SampleData().companiesEntriesDict["SNAP"]!)
    }
}

