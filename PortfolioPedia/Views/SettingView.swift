//
//  SettingView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 08.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import UserNotifications

struct SettingView: View {
    @EnvironmentObject var settings: UserSettings
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Manage Subscription"), footer: Text("Add more than two companies to your portfolio and support the app development.")) {
                    Toggle("Pro Version", isOn: $settings.subscribed)
                        .onReceive([self.settings.subscribed].publisher.first()) { (value) in
                            save_UserSettings(userSettings: self.settings)
                        }
                }
                
                Section(header: Text("NOTIFICATIONS"), footer: notiFooter(toggleIsOn: $settings.notificationsEnabled)) {
                    Toggle("Enabled", isOn: $settings.notificationsEnabled)
                        .onReceive([self.settings.notificationsEnabled].publisher.first()) { (value) in
                            save_UserSettings(userSettings: self.settings)
                            value ? enableNotifications() : disableNotifications()
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
                        self.showingAlert = true
                    }) {
                        Text("Sample Portfolio")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("Your current portfolio will be replaced by sample entries to demonstrate app features."), primaryButton: .destructive(Text("Delete")) {
                            clearDirectoryFolder()
                            self.totalNumbers = TotalNumbers()
                            self.handelDicts = HandelDicts()
                            self.settings.portfolio = sampleUserInputs
                            save_UserSettings(userSettings: self.settings)
                        }, secondaryButton: .cancel())
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
                        Alert(title: Text("Important message"), message: Text("Cache files have been deleted."), dismissButton: .default(Text("Dismiss")))
                    }
                    
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("Delete Portfolio").foregroundColor(.red)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("Your portfolio will be deleted entirely. There is no undo."), primaryButton: .destructive(Text("Delete")) {
                            clearDirectoryFolder()
                            self.settings.portfolio.removeAll()
                            self.totalNumbers = TotalNumbers()
                            self.handelDicts = HandelDicts()
                        }, secondaryButton: .cancel())
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct notiFooter: View {
    @Binding var toggleIsOn: Bool
    
    var body: some View {
        VStack{
            Text("Get notified every day about half an hour after market closure to check your latest portfolio state.")
            if !notificationPermission() && toggleIsOn{
                Text("Notifications permission denied! Enable app notification in system settings and retoggle this afterwards.").foregroundColor(.red)
            }
        }
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}

