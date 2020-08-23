//
//  SearchView.swift
//  My Daily Portfolio Update
//
//  Created by Khashayar Abri on 04.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @State private var searchTerm: String = ""
    @State private var backgroundColor = Color.white
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationView {
            VStack {
            
                SearchBar(text: $searchTerm)
                
                List {

                    ForEach(myDic_Symb2Name.values.sorted().filter{ word in
                            self.searchTerm.isEmpty ? true:
                                word.localizedCaseInsensitiveContains(self.searchTerm)}, id: \.self) {value in
                                        Text(value)
                                        .onTapGesture {
                                            self.settings.compNames.append(getKey(value: value))
                                            
                                            self.presentationMode.wrappedValue.dismiss()
                                            
                                        }
                        }
                    
                }.id(UUID())
            }
            .navigationBarTitle(Text("Companies  🔍"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing sheet view...")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
