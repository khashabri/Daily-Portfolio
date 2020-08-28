//
//  DataTypes.swift
//  Daily Portfolio Update
//
//  Created by Khashayar Abri on 28.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct Welcome: Codable & Decodable  {
    let metaData: MetaData
    var compData: [String: CompData]
    
    enum CodingKeys: String, CodingKey, Decodable {
        case metaData = "Meta Data"
        case compData = "Time Series (Daily)"
    }
    
}

// MARK: - MetaData
struct MetaData: Codable & Decodable {
    let information, symbol, lastRefreshed, outputSize: String
    let timeZone: String
    
    enum CodingKeys: String, CodingKey, Decodable {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
        case outputSize = "4. Output Size"
        case timeZone = "5. Time Zone"
    }
}

// MARK: - TimeSeriesDaily
struct CompData: Codable & Identifiable & Decodable {
    var id = UUID()
    var s_open, s_high, s_low, s_close, s_volume: String
    
    var symbol: String = ""
    var lastRefreshed: String = ""
    
    // making some Doubles out of Strings
    var open: Double = 0
    var high: Double = 0
    var low: Double  = 0
    var close: Double  = 0
    var volume: Double  = 0
    
    // Additional Data
    var pchange: Double = 0
    var volumeDayChange: Double = 0
    
    // 30 Days base [22]
    var close1MChange: Double = 0
    var volume1MChange: Double = 0
    
    // weekly Days base [5]
    var closeWeekChange: Double = 0
    var volumeWeekChange: Double = 0
    
    // 3m Days base [5]
    var close3MChange: Double = 0
    var volume3MChange: Double = 0
    
    var Days100Before: [Double]  = []
    
    enum CodingKeys: String, CodingKey, Decodable {
        case s_open = "1. open"
        case s_high = "2. high"
        case s_low = "3. low"
        case s_close = "4. close"
        case s_volume = "5. volume"
        
    }
    
    mutating func makeDoubles(himself: CompData){
        self.open = Double(himself.s_open)!
        self.high = Double(himself.s_high)!
        self.low = Double(himself.s_low)!
        self.close = Double(himself.s_close)!
        self.volume = Double(himself.s_volume)!
    }
}


// MARK: - User Input
struct UserInput: Identifiable, Equatable{
    let id = UUID()
    let compName: String
    lazy var compSymbol = getKey(value: compName)
    let purchaseDate: String
    let purchaseAmount: Double
}

// MARK: - Company Portfolio Output
struct CompPortfolioOutput: Identifiable{
    var id = UUID()
    var lastRefreshed: String = ""
    var compName: String = ""
    var compSymbol: String = ""
    var purchaseDate: String = ""
    var purchasePrice: Double = 0
    var purchaseAmount: Double = 0
    var totalInvestment: Double = 0
    var totalCurrentValue: Double = 0
    var gainHistory: [Double] = []
    var currentGain: Double = 0
    var priceHistory: [Double] = []
    
    // Additionals
    // Daily statistics
    var open: String = ""
    var close: String = ""
    var high: String = ""
    var low: String = ""
    var volume: String = ""
    
    // Time characteristics
    var priceChange1D: Double = 0
    var priceChange5D: Double = 0
    var priceChange1M: Double = 0
    var priceChange1Y: Double = 0
    
    var volumeChange1D: Double = 0
    var volumeChange5D: Double = 0
    var volumeChange1M: Double = 0
    var volumeChange1Y: Double = 0
}
