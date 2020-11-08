//
//  SettingView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 08.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import UserNotifications
import UIKit
import MessageUI

struct SettingView: View {
    @EnvironmentObject var settings: UserSettings
    @Binding var totalNumbers: TotalNumbers
    @Binding var handelDicts: HandelDicts
    @State private var showingAlert = false
    
    // for email sending
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var showingMail = false
    @State var unavailabilityText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Features"), footer: Text("Add more than two companies to your portfolio and support the app development.")) {
                    Toggle("Unlock full version", isOn: $settings.subscribed)
                        .onReceive([self.settings.subscribed].publisher.first()) { (value) in
                            save_UserSettings(userSettings: self.settings)
                        }
                }
                
                Section(footer: notiFooter(toggleIsOn: $settings.notificationsEnabled)) {
                    Toggle("Notifications", isOn: $settings.notificationsEnabled)
                        .onReceive([self.settings.notificationsEnabled].publisher.first()) { (value) in
                            save_UserSettings(userSettings: self.settings)
                            value ? enableNotifications() : disableNotifications()
                        }
                }
                
                Section(header: Text("About"), footer: Text("Company logos are provided by") + Text(" Clearbit").bold() + Text(unavailabilityText).foregroundColor(.purple)) {
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
                    Button(action: {
                        self.showingMail.toggle()
                    }) {
                        Text("Bug report / Suggestion")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $showingMail) {
                        MailView(result: self.$result)
                    }
                }
                
                Section(header: Text("Quick actions")) {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("Load a sample portfolio")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("Your current portfolio will be replaced by sample entries to demonstrate app features."), primaryButton: .destructive(Text("Replace")) {
                            clearDirectoryFolder()
                            self.totalNumbers = TotalNumbers()
                            self.handelDicts = HandelDicts()
                            self.settings.userInputs = SampleData().userInputs
                            save_UserSettings(userSettings: self.settings)
                        }, secondaryButton: .cancel())
                    }
                    
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("Delete the entire portfolio").foregroundColor(.red)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("Your portfolio will be deleted entirely. There is no undo."), primaryButton: .destructive(Text("Delete")) {
                            clearDirectoryFolder()
                            self.settings.userInputs.removeAll()
                            self.totalNumbers = TotalNumbers()
                            self.handelDicts = HandelDicts()
                        }, secondaryButton: .cancel())
                    }
                }
            }
            .onAppear{ !MFMailComposeViewController.canSendMail() ? self.unavailabilityText = "\nIn-App Email seems to not work on your device. You can still contact me via Email at khashabri@gmail.com. 📨" : ()}
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
                Button(action: {self.settingsOpener()} ){
                   Text("Notifications permission denied! Enable app notification in system").foregroundColor(.red)
                        + Text(" Settings ").foregroundColor(.blue) + Text("and retoggle this afterwards.").foregroundColor(.red)
                }
            }
        }
    }
    
    private func settingsOpener(){
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["khashabri@gmail.com"])
        vc.setSubject("PortfolioPedia: Bug Report / Suggestion")
        //        vc.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        
    }
    
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
