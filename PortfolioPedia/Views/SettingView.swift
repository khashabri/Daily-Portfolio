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
                        Alert(title: Text("Important message"), message: Text("Sample entries have been loaded to your portfolio."), dismissButton: .default(Text("Dismiss")))
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

struct notiFooter: View {
    @Binding var toggleIsOn: Bool
    let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
    
    var body: some View {
        VStack{
            Text("Get notified every day about half an hour after market closure to check your latest portfolio state.")
            if self.notificationType == [] && toggleIsOn{
                Text("Notifications permission is denied! Enable it in system settings and retoggle this again.").foregroundColor(.red)
            }
        }
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}

