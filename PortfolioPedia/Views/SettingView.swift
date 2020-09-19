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
    
    @State var username: String = ""
    @State var isPrivate: Bool = true
    @State var notificationsEnabled: Bool = false
    @State private var previewIndex = 0
    var previewOptions = ["Always", "When Unlocked", "Never"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PROFILE")) {
                    TextField("Username", text: $username)
                    Toggle(isOn: $isPrivate) {
                        Text("Private Account")
                    }
                }
                
                Section(header: Text("NOTIFICATIONS")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enabled")
                    }
                    Picker(selection: $previewIndex, label: Text("Show Previews")) {
                        ForEach(0 ..< previewOptions.count) {
                            Text(self.previewOptions[$0])
                        }
                    }
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.2.1")
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
                        self.settings.portfolio.removeAll()
                        self.totalNumbers = TotalNumbers()
                        self.handelDicts = HandelDicts()
                    }) {
                        Text("Reset All Settings")
                    }
                    Button(action: {
                        clearDirectoryFolder()
                        self.totalNumbers = TotalNumbers()
                        self.handelDicts = HandelDicts()
                        
                    }) {
                        Text("Delete Catched Server Data")
                    }
                    Button(action: {
                        clearDirectoryFolder()
                        self.totalNumbers = TotalNumbers()
                        self.handelDicts = HandelDicts()
                        settings.portfolio = sampleUserInputs
                        save_UserInputs(userInputs: sampleUserInputs)
                    }) {
                        Text("Sample Portfolio")
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
