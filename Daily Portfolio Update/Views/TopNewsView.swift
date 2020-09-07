//
//  ContentView.swift
//  DoomyTesting
//
//  Created by Khashayar Abri on 30.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import SafariServices

// MARK: - TODO: Big error handling and saving needed! + Live reacting on companiesSymbols changes

struct TopNewsView: View {
    @State var companiesSymbols: [String]
    @State var existingInputs: [String] = []
    @State var dict = [String:[Article]]()
    
    //    init() {
    //        self.buildElements()
    //    }
    
    var body: some View {
        NavigationView{
            VStack{
                List {
                    ForEach(self.dict.keys.sorted(by: <), id: \.self) {key in
                        
                        Section(header: Text(myDic_Symb2Name[key]!)) {
                            ForEach(self.dict[key]![0...min(3,self.dict[key]!.count-1)].reversed(), id: \.self) {aArticle in
                                RowView(aArticle: aArticle)
                            }
                        }
                    }
                }.onAppear { self.buildElements() }
            }
            .navigationBarTitle(Text("🌎 Top News"), displayMode: .inline)
        }
    }
    private func buildElements() {
        for compSymbol in self.companiesSymbols{
            if !self.existingInputs.contains(compSymbol){
                self.existingInputs.append(compSymbol)
                NetworkingManagerNews(compSymbol: compSymbol).getData { articles in
                self.dict[compSymbol] = articles
                }
            }
        }
    }
}

struct TopNewsView_Previews: PreviewProvider {
    static var previews: some View {
        TopNewsView(companiesSymbols: ["AAPL","AMD","TSLA"])
    }
}

struct RowView: View {
    @State var aArticle: Article
    @State var showSafari = false
    
    var body: some View {
        VStack(alignment: .leading){
            Text(aArticle.title!)
                .font(.headline)
                .padding(.vertical, 3.0)
            HStack {
                Text(aArticle.source!.name!)
                Spacer()
                Text(removeTandElse(aArticle.publishedAt!))
            }.foregroundColor(Color.gray)
                .font(.footnote)
            
            
        }.onTapGesture {
            self.showSafari.toggle()
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url:URL(string: self.aArticle.url!)!)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController,
                                context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
    
}
