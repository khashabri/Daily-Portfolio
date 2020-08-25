//
//  MoreInfo.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct MoreInfo: View {
    @State var aPortElement: CompPortfolioOutput
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack() {
                HStack() {
                    Text("Name:")
                        .font(.headline)
                        .padding(.leading, 20)
                    Text(aPortElement.compName)
                    Spacer()
                }
                .padding(.top)
                HStack() {
                    Text("Market Symbol:")
                        .font(.headline)
                        .padding(.leading, 20)
                    Text(aPortElement.compSymbol)
                    Spacer()
                }
                Spacer()
                InfoSheet(aPortElement: aPortElement)
            }
            .navigationBarTitle("Apple Inc.", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing sheet view...")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}


struct MoreInfo_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfo(aPortElement: compPortfolioOutputOfflineSample)
    }
}

