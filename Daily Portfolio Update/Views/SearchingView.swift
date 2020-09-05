//
//  SearchView.swift
//  My Daily Portfolio Update
//
//  Created by Khashayar Abri on 04.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct SearchingView: View {
    @State var askingDetail = false
    @State private var searchTerm: String = ""
    @State private var backgroundColor = Color.white
    @Binding var isLoading: Bool
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            SearchBar(text: $searchTerm)
            List {
                
                ForEach(myDic_Symb2Name.values.sorted().filter{ word in
                    self.searchTerm.isEmpty ? true:
                        word.localizedCaseInsensitiveContains(self.searchTerm)}, id: \.self) {value in
                            NavigationLink(destination: AskingView(compName: value, isLoading: self.$isLoading )){
                                HStack{
                                    //                                        Image(myDic_Symb2Img[getKey(value: value)]!)
                                    //                                            .resizable()
                                    //                                            .frame(minWidth: 0, idealWidth: 32, maxWidth: 45, minHeight: 32, idealHeight: 32, maxHeight: 32, alignment: .leading)
                                    Text(value)
                                }
                            }
                }
                
            }.id(UUID())
                .navigationBarTitle(Text("Companies  🔍"), displayMode: .inline)
        }
        
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView(isLoading: .constant(false))
    }
}
