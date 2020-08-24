//
//  SwiftUIView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 31.07.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

var offlineData: [CompData] = [JsonOfflineCompData()]
var settingsForPreview = UserSettings()

struct ContentView: View {
    @State var wholeData: [CompData] = []
    @State var existingNames: [String] = ["AAPL", "SNAP"]
    @State var isSearching: Bool = false
    @State var searchTerm: String = ""
    @State var lastUpdateDate: String = ""
    @State private var showModal = false
    @State private var showUpdateTime = true
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        TabView {
            VStack {
                NavigationView {
                    List() {
                        
                        ForEach(wholeData) {one_of_companies in
                            NavigationLink(destination: MoreDetailsView(aCompanyData: one_of_companies)) {
                                RowView(aCompanyData: one_of_companies)
                            }
                        }
                        .onDelete(perform: self.deleteRow)
                        .onMove(perform: self.move)
                        .onAppear(){self.showUpdateTime = true}
                        .onDisappear(){self.showUpdateTime = false}
                        
                    }
                    .onAppear { self.buildElements() }
                        
                    .navigationBarItems(leading: EditButton(),trailing: Button(action: {
                        self.showModal = true
                    })
                    {
                        Image(systemName: "plus")
                        .resizable()
                        .padding(6)
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                        .offset(x: -5, y: 0)
                    }).sheet(isPresented: self.$showModal, content: {
                        SearchView().environmentObject(self.settings).onDisappear{ self.buildElements()}
                    })
                    .navigationBarTitle(Text("Watchlist"))
                    
                }
            
//                HStack {
//                    Text("Updated On: " + lastUpdateDate)
//                        .fontWeight(.semibold)
//                        .padding(.leading, 5.0)
//                    Spacer()
//                    Button(action: self.refreshList) {
//                        Image(systemName: "arrow.2.circlepath")
//                    }
//                    .padding(.trailing, 18.0)
//                }.padding(.all)
                
            }
                
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Watchlist")
            }
            
            PortfolioView()
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Portfolio")
            }
            
            SettingView()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.wholeData.remove(atOffsets: indexSet)
        self.settings.compNames.remove(atOffsets: indexSet)
    }
    
    private func buildElements() {
        for name in self.settings.compNames {
            print(name)
            print(self.settings.compNames)
            if !self.existingNames.contains(name){
                existingNames.append(name)
                NetworkingManager(symbl: name).getData { compData in
                    self.wholeData.append(compData)
                    self.lastUpdateDate = String(compData.lastRefreshed.prefix(10))
                }
            }
        }
    }
    
    private func refreshList() {
        self.wholeData.removeAll()
        self.existingNames.removeAll()
        buildElements()
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        wholeData.move(fromOffsets: source, toOffset: destination)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(settingsForPreview)
    }
}
