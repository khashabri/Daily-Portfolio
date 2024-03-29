//
//  SceneDelegate.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 31.07.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit

class UserSettings: ObservableObject, Codable {
    
    @Published var userInputs: [UserInput]
    @Published var openedTimes: Int
    @Published var subscribed: Bool
    @Published var showLogos: Bool
    @Published var notificationsEnabled: Bool
    
    enum CodingKeys: CodingKey {
        case openedTimes, userInputs, subscribed, showLogos, notificationsEnabled
    }
    
    init(userInputs: [UserInput], openedTimes: Int = 0, subscribed: Bool = false, showLogos: Bool = true, notificationsEnabled: Bool = true) {
        self.userInputs = userInputs
        self.openedTimes = openedTimes
        self.subscribed = subscribed
        self.showLogos = showLogos
        self.notificationsEnabled = notificationsEnabled
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userInputs = try container.decode([UserInput].self, forKey: .userInputs)
        openedTimes = try container.decode(Int.self, forKey: .openedTimes)
        subscribed = try container.decode(Bool.self, forKey: .subscribed)
        showLogos = try container.decode(Bool.self, forKey: .showLogos)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userInputs, forKey: .userInputs)
        try container.encode(openedTimes, forKey: .openedTimes)
        try container.encode(subscribed, forKey: .subscribed)
        try container.encode(showLogos, forKey: .showLogos)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var settings = load_UserSettings()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(loadingState: .isLoading)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView:  contentView.environmentObject(settings))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        save_UserSettings(userSettings: settings)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        settings.openedTimes += 1
        settings.notificationsEnabled && notificationPermission() ? enableNotifications() : ()
//        ((settings.openedTimes % 10) == 0)  ? SKStoreReviewController.requestReview() : ()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        save_UserSettings(userSettings: settings)
    }
    
    
}


struct SceneDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
