//
//  MoreNewsView.swift
//  Daily Portfolio Update
//
//  Created by Khashayar Abri on 08.09.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct MoreNewsView: View {
    @State var articles: [Article]
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            VStack{
                List(){
                    ForEach(articles, id: \.self) {aArticle in
                        RowView(aArticle: aArticle)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()}) { Text("Done").bold()})
        }
    }
}


struct MoreNewsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreNewsView(articles: [SampleData().article1, SampleData().article2, SampleData().article3])
    }
}

