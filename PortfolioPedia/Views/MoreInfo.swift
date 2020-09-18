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
    
    var body: some View {
        VStack() {
            HStack() {
                Text("Name:")
                    .font(.headline)
                    .padding(.leading, 20)
                Text(dataEntries[0].compName)
                Spacer()
            }
            .padding(.top)
            HStack() {
                Text("Market Symbol:")
                    .font(.headline)
                    .padding(.leading, 20)
                Text(dataEntries[0].compSymbol)
                Spacer()
            }
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
        MoreInfo(dataEntries: SampledataEntry["SNAP"]!)
    }
}

