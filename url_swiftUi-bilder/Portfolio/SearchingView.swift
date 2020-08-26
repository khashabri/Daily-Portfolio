//
//  SearchView.swift
//  My Daily Portfolio Update
//
//  Created by Khashayar Abri on 04.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct SearchingView: View {
    @State private var searchTerm: String = ""
    @State private var backgroundColor = Color.white
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
            VStack {
                
                SearchBar(text: $searchTerm)
                
                List {
                    
                    ForEach(myDic_Symb2Name.values.sorted().filter{ word in
                        self.searchTerm.isEmpty ? true:
                            word.localizedCaseInsensitiveContains(self.searchTerm)}, id: \.self) {value in
                                Text(value)
                                    .onTapGesture {
                                        let compSymbol = getKey(value: value)
                                        let userInput = UserInput(compName: value, compSymbol: compSymbol, purchaseDate: "2019-08-10", purchaseAmount: 5)
                                        self.settings.portfolio.append(userInput)
                                        
                                        self.presentationMode.wrappedValue.dismiss()
                                        
                                }
                    }
                    
                }.id(UUID())
            }
            .navigationBarTitle(Text("Companies  🔍"), displayMode: .inline)
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView()
    }
}
