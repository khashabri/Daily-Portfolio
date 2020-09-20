//
//  SettingView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 08.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var settings: UserSettings
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    @State private var showingAlert = false
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Manage Subscription"), footer: Text("Add more than two companies to your portfolio and support the app development.")) {
                    Toggle(isOn: $settings.subscribed) {
                        Text("Pro Version")
                    }.onTapGesture {
                        save_UserSettings(userSettings: self.settings)
                    }
                }
                
                Section(header: Text("NOTIFICATIONS")) {
                    Toggle(isOn: $settings.notificationsEnabled) {
                        Text("Enabled")
                    }.onTapGesture {
                        save_UserSettings(userSettings: self.settings)
                    }
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                    }
                    HStack {
                        Text("Copyright")
                        Spacer()
                        Text("@ khashabri")
                    }
                }
                
                Section {
                    Button(action: {
                        clearDirectoryFolder()
                        self.totalNumbers = TotalNumbers()
                        self.handelDicts = HandelDicts()
                        self.settings.portfolio = sampleUserInputs
                        save_UserSettings(userSettings: self.settings)
                        self.showingAlert = true
                    }) {
                        Text("Sample Portfolio")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Important message"), message: Text("Sample entries has been loaded to your portfolio."), dismissButton: .default(Text("Dismiss")))
                    }
                    
                    Button(action: {
                        clearDirectoryFolder()
                        self.totalNumbers = TotalNumbers()
                        self.handelDicts = HandelDicts()
                        self.showingAlert = true
                        
                    }) {
                        Text("Delete Catched Server Data")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Important message"), message: Text("Cache files has been deleted."), dismissButton: .default(Text("Dismiss")))
                    }
                    
                    Button(action: {
                        clearDirectoryFolder()
                        self.settings.portfolio.removeAll()
                        self.totalNumbers = TotalNumbers()
                        self.handelDicts = HandelDicts()
                        self.showingAlert = true
                    }) {
                        Text("Delete Portfolio").foregroundColor(.red)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Important message"), message: Text("Your portfolio has been deleted entirely."), dismissButton: .default(Text("Dismiss")))
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
