//
//  API_Functions.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 02.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import Foundation
import UserNotifications

let pass: Any = ()

func get_today() -> String {
    let lastDayDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let lastkDayString = dateFormatter.string(from: lastDayDate)
    
    return lastkDayString
}

func get_yesterday() -> String {
    let lastDayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let lastkDayString = dateFormatter.string(from: lastDayDate)
    
    return lastkDayString
}

func get_before_yesterday() -> String {
    let lastDayDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let lastkDayString = dateFormatter.string(from: lastDayDate)
    
    return lastkDayString
}

func MakeApiStringUrl(compSymbol: String, outputSize: String = "compact") -> String {
    let part1 = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol="
    let part2 = compSymbol
    let part3 = "&outputsize="
    let part4 = outputSize
    let part5 = "&apikey=4HX8NVQU9MV6J5LY"
    let overall = part1+part2+part3+part4+part5
    
    return overall
}

func cast2URL(string: String) -> URL {
    return URL(string: string) ?? URL(string: "a")!
}

func getKey(value: String) -> String {
    let idx = myDic_Symb2Name.values.firstIndex(of: value)
    let key = myDic_Symb2Name.keys[idx!]
    
    return key
}

func roundGoodD (_ x: Double) -> Double {
    return round(100 * x) / 100
}

func roundGoodS (_ x: String) -> String {
    return String(round(100 * Double(x)!) / 100)
}

func calcRateS (x: String, y: String) -> Double {
    let x = Double(x)!
    let y = Double(y)!
    if (y < 0.0009) {return 0}
    return roundGoodD((x-y)/y*100)
}

func calcRateD (x: Double, y: Double) -> Double {
    if (y < 0.0009) {return 0}
    return roundGoodD((x-y)/y*100)
}

// 223.436 -> 223,44 $"
func currencyString(_ x: Double, symbol: String = " $") -> String{
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyPlural
    formatter.locale = Locale(identifier: "en_US")
    formatter.string(from: NSNumber(value: x))
    var numFormated = String(formatter.string(from: NSNumber(value: x))?.dropLast(11) ?? "")
    if (numFormated == "-0.00") {numFormated = "0.00"}
    return numFormated+symbol
}

func currencyString(_ x: String, symbol: String = " $") -> String{
    let x = Double(x)!
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyPlural
    formatter.locale = Locale(identifier: "en_US")
    formatter.string(from: NSNumber(value: x))
    var numFormated = String(formatter.string(from: NSNumber(value: x))?.dropLast(11) ?? "")
    if (numFormated == "-0.00") {numFormated = "0.00"}
    return numFormated+symbol
}

func isAboutZero(_ x: Double) -> Bool{
    return (abs(x) < 0.0009)
}

func removeEndZeros(_ arr: [Double]) -> [Double]{
    let binary = arr.map{abs($0) < 0.0009}
    let indx = binary.lastIndex(of: false) ?? 0
    return Array(arr[0...indx])
}

func isInt(_ x: String) -> Bool{
    let x = Double(x)
    return floor(x ?? 0) == x
}

func savingKeyMaker(_ userInput: UserInput) -> String{
    let userInput = userInput
    return userInput.compSymbol + userInput.purchaseDate + String(userInput.purchaseAmount) + String(userInput.manualPurchasedPrice)
}

func save_CompPortfolioOutput(compPortfolioOutput: CompPortfolioOutput, fileName: String){
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListEncoder = PropertyListEncoder()
    let encodedComp = try? propertyListEncoder.encode(compPortfolioOutput)
    try? encodedComp!.write(to: archiveURL, options: .noFileProtection)
}

func load_CompPortfolioOutput(fileName: String) -> CompPortfolioOutput?{
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListDecoder = PropertyListDecoder()
    guard let retrievedCompData = try? Data(contentsOf: archiveURL) else { return nil }
    if let decodedComp = try? propertyListDecoder.decode(CompPortfolioOutput.self, from: retrievedCompData){
        return decodedComp
    }
    
    return nil
}

func get_yesterday(_ of: Date) -> Date {
    let lastDayDate = Calendar.current.date(byAdding: .day, value: -1, to: of)!
    return lastDayDate
}

// MARK: - FIX: todaysMarketClosure and now() should be timezone dependent

func refreshDateThreshold() -> Date{
    let calendar = Calendar.current
    let todaysMarketClosure = calendar.date(bySettingHour: 22, minute: 31, second: 0, of: Date())!
    let now = Date()
    var threshold = todaysMarketClosure
    
    (now < todaysMarketClosure) ? threshold = get_yesterday(threshold) : ()
    
    while calendar.isDateInWeekend(threshold) {
        threshold = get_yesterday(threshold)
    }
    
    return threshold
}

func now() -> Date{
    return Date()
}

func clearDirectoryFolder() {
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: .skipsHiddenFiles)
        for fileURL in fileURLs {
            if fileURL.pathExtension == "plist" {
                try FileManager.default.removeItem(at: fileURL)
            }
        }
    } catch  { print(error) }
}

func removeTandElse(_ string: String) -> String{
    var reformattedString = string.replacingOccurrences(of: "T", with: "  ")
    reformattedString = reformattedString.replacingOccurrences(of: ":00Z", with: "")
    reformattedString = reformattedString.replacingOccurrences(of: "Z", with: "")
    return reformattedString
}

func save_Articles(articles: [Article], compSymbol: String){
    let fileName = "articles_of_" + compSymbol
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListEncoder = PropertyListEncoder()
    let encodedArticles = try? propertyListEncoder.encode(articles)
    try? encodedArticles!.write(to: archiveURL, options: .noFileProtection)
}

func load_Articles(compSymbol: String) -> [Article]?{
    let fileName = "articles_of_" + compSymbol
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListDecoder = PropertyListDecoder()
    guard let retrievedArticles = try? Data(contentsOf: archiveURL) else { return nil }
    if let decodedArticles = try? propertyListDecoder.decode(Array<Article>.self, from: retrievedArticles){
        return decodedArticles
    }
    
    return nil
}

func save_Welcome(welcome: Welcome, compSymbol: String){
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "serverWelcomeData_" + compSymbol
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListEncoder = PropertyListEncoder()
    let encodedWelcome = try? propertyListEncoder.encode(welcome)
    try? encodedWelcome!.write(to: archiveURL, options: .noFileProtection)
}

func load_Welcome(compSymbol: String) -> Welcome?{
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "serverWelcomeData_" + compSymbol
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListDecoder = PropertyListDecoder()
    guard let retrievedWelcome = try? Data(contentsOf: archiveURL) else { return nil }
    if let decodedWelcome = try? propertyListDecoder.decode(Welcome.self, from: retrievedWelcome){
        return decodedWelcome
    }
    
    return nil
}

func deleteCache_Welcome(compSymbol: String){
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "serverWelcomeData_" + compSymbol
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    try? FileManager.default.removeItem(at: archiveURL)
}

func deleteCache_Articles(compSymbol: String){
    let fileName = "articles_of_" + compSymbol
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    try? FileManager.default.removeItem(at: archiveURL)
}

func deleteCache_UserInputs(){
    let fileName = "userInputs"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    try? FileManager.default.removeItem(at: archiveURL)
}

func deleteCache_CompPortfolioOutput(fileName: String){
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    try? FileManager.default.removeItem(at: archiveURL)
}

func printDirectoryContent(){
    // Get the document directory url
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
        print(directoryContents)
        
        // if you want to filter the directory contents you can do like this:
        let plistURLs = directoryContents.filter{ $0.pathExtension == "plist" }
        let plistFileNames = plistURLs.map{ $0.deletingPathExtension().lastPathComponent }
        print("plist Names:", plistFileNames)
        
    } catch {
        print(error)
    }
}

func save_UserSettings(userSettings: UserSettings){
    let fileName = "userSettings"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListEncoder = PropertyListEncoder()
    let encodedUserInputs = try? propertyListEncoder.encode(userSettings)
    
    try? encodedUserInputs!.write(to: archiveURL, options: .noFileProtection)
}

func load_UserSettings() -> UserSettings{
    let fileName = "userSettings"
    let emptyUserSettings = UserSettings(portfolio: [], subscribed: false, notificationsEnabled: false)
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListDecoder = PropertyListDecoder()
    guard let retrievedUserSettings = try? Data(contentsOf: archiveURL) else { return emptyUserSettings }
    if let decodedUserInputs = try? propertyListDecoder.decode(UserSettings.self, from: retrievedUserSettings){
        return decodedUserInputs
    }
    
    return emptyUserSettings
}

func enableNotifications(){
    // Ask for permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("All set!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "New server data available"
    content.body = "Open the app to check the latest rendite."
    content.sound = UNNotificationSound.default
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let MoDateTime = formatter.date(from: "2020/09/14 22:31")
    let DiDateTime = formatter.date(from: "2020/09/15 22:31")
    let MiDateTime = formatter.date(from: "2020/09/16 22:31")
    let DoDateTime = formatter.date(from: "2020/09/17 22:31")
    let FrDateTime = formatter.date(from: "2020/09/18 22:31")
    
    let triggerMoWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: MoDateTime!)
    let triggerDiWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: DiDateTime!)
    let triggerMiWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: MiDateTime!)
    let triggerDoWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: DoDateTime!)
    let triggerFrWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: FrDateTime!)
    
    let triggerMo = UNCalendarNotificationTrigger(dateMatching: triggerMoWeekly, repeats: true)
    let triggerDi = UNCalendarNotificationTrigger(dateMatching: triggerDiWeekly, repeats: true)
    let triggerMi = UNCalendarNotificationTrigger(dateMatching: triggerMiWeekly, repeats: true)
    let triggerDo = UNCalendarNotificationTrigger(dateMatching: triggerDoWeekly, repeats: true)
    let triggerFr = UNCalendarNotificationTrigger(dateMatching: triggerFrWeekly, repeats: true)
    
    // choose a random identifier
    let requestMo = UNNotificationRequest(identifier: "MontagsNotification", content: content, trigger: triggerMo)
    let requestDi = UNNotificationRequest(identifier: "DinstagsNotification", content: content, trigger: triggerDi)
    let requestMi = UNNotificationRequest(identifier: "MittwochsNotification", content: content, trigger: triggerMi)
    let requestDo = UNNotificationRequest(identifier: "DonnerstagsNotification", content: content, trigger: triggerDo)
    let requestFr = UNNotificationRequest(identifier: "FreitagsNotification", content: content, trigger: triggerFr)
    
    // add our notification request
    UNUserNotificationCenter.current().add(requestMo)
    UNUserNotificationCenter.current().add(requestDi)
    UNUserNotificationCenter.current().add(requestMi)
    UNUserNotificationCenter.current().add(requestDo)
    UNUserNotificationCenter.current().add(requestFr)
    
    
    
}

func disableNotifications(){
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
}

func notificationPermission() -> Bool {
    var notificationSettings: UNNotificationSettings?
    let semasphore = DispatchSemaphore(value: 0)
    
    DispatchQueue.global().async {
        UNUserNotificationCenter.current().getNotificationSettings { setttings in
            notificationSettings = setttings
            semasphore.signal()
        }
    }
    
    semasphore.wait()
    guard let authorizationStatus = notificationSettings?.authorizationStatus else { return false }
    return authorizationStatus == .authorized
}

