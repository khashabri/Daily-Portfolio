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
    @State var dict = [String:[Article]]()
    
    //    init() {
    //        self.buildElements()
    //    }
    
    var body: some View {
        NavigationView{
            VStack{
                List {
                    ForEach(self.dict.keys.sorted(by: <), id: \.self) {key in
                        
                        Section(header: customHeader(Name: myDic_Symb2Name[key]!, articles: self.dict[key]!)) {
                            ForEach(self.dict[key]![0...min(3,self.dict[key]!.count-1)], id: \.self) {aArticle in
                                RowView(aArticle: aArticle)
                            }
                        }
                    }
                }.onAppear { self.buildElements() }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        self.buildElements()
                }
            }
            .navigationBarTitle(Text("🌎 Top News"), displayMode: .inline)
        }
    }
    public func buildElements() {
        let myGroup = DispatchGroup()
        var tmpDict = [String:[Article]]()
        var changeHappend = false
        
        for compSymbol in self.companiesSymbols{
            myGroup.enter()
            
            NetworkingManagerNews(compSymbol: compSymbol).getData { articles in
                tmpDict[compSymbol] = articles
                
                if let latestArticleTitle = self.dict[compSymbol]?[0].title{
                    if (tmpDict[compSymbol]![0].title != latestArticleTitle) {changeHappend = true}
                }else{
                    changeHappend = true
                }
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            changeHappend ? self.dict = tmpDict : ()
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
                .minimumScaleFactor(0.8)
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
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
    
}

struct customHeader: View {
    
    @State var Name: String
    @State var articles: [Article]
    @State var showMore = false
    
    var body: some View {
        HStack {
            Text(self.Name)
            Spacer()
            Button(action: { self.showMore.toggle()}){
                HStack{
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
                .sheet(isPresented: $showMore) {MoreNewsView(articles: self.articles)}
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.1)
    }
}
