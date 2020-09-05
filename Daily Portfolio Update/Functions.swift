//
//  API_Functions.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 02.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import Foundation

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
    var userInput = userInput
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

func save_UserInputs(userInputs: [UserInput]){
    let fileName = "userInputs"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListEncoder = PropertyListEncoder()
    let encodedUserInputs = try? propertyListEncoder.encode(userInputs)
    
    try? encodedUserInputs!.write(to: archiveURL, options: .noFileProtection)
}

func load_UserInputs() -> [UserInput]{
    let fileName = "userInputs"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("plist")
    
    let propertyListDecoder = PropertyListDecoder()
    let retrievedUserInputs = try? Data(contentsOf: archiveURL)
    if let decodedUserInputs = try? propertyListDecoder.decode(Array<UserInput>.self, from: retrievedUserInputs!){
        return decodedUserInputs
    }
    
    return []
}
