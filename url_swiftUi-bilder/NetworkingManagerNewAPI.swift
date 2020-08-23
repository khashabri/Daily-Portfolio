import Foundation
import Combine
import SwiftUI
import UIKit

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

// MARK: - Class
class NetworkingManager: ObservableObject {
    var urlString: String
    
    init(symbl: String) {
        self.urlString = MakeApiStringUrl(comp_symbol: symbl)
    }
    
    func getData(completion: @escaping (CompData) -> ()){
        
        guard let url = URL(string: self.urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data,_,_) in
            guard let data = data else { return }
            
            let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
            
            DispatchQueue.main.async {
                // taking out the latest company data
                var compCharacteristics = welcome.compData[welcome.metaData.lastRefreshed]!
                compCharacteristics.makeDoubles(himself: compCharacteristics)
                
                let totDatesArr = welcome.compData.keys.sorted(by: >)
                
                compCharacteristics.Days100Before = welcome.compData.values(of: totDatesArr)
                
                let compToday = welcome.compData[totDatesArr[0]]!
                let compYesterday = welcome.compData[totDatesArr[1]]!
                let compWeekBef = welcome.compData[totDatesArr[5]]!
                let comp30DaysBef = welcome.compData[totDatesArr[22]]!
                let comp3MoBef = welcome.compData[totDatesArr[66]]!
                
                // calc pchange
                compCharacteristics.pchange = calcRateD(x: compCharacteristics.Days100Before[0], y: compCharacteristics.Days100Before[1])
                
                // saving company symbol and the last data check date
                compCharacteristics.symbol = welcome.metaData.symbol
                compCharacteristics.lastRefreshed = welcome.metaData.lastRefreshed

                // 1 Day base calculations
                compCharacteristics.volumeDayChange = calcRateS(x: compToday.s_volume, y: compYesterday.s_volume)
                
                // 30 Days base [22] calculations
                compCharacteristics.close1MChange = calcRateS(x: compToday.s_close, y: comp30DaysBef.s_close)
                compCharacteristics.volume1MChange = calcRateS(x: compToday.s_volume, y: comp30DaysBef.s_volume)
                
                // weekly Days base [5] calculations
                compCharacteristics.closeWeekChange = calcRateS(x: compToday.s_close, y: compWeekBef.s_close)
                compCharacteristics.volumeWeekChange = calcRateS(x: compToday.s_volume, y: compWeekBef.s_volume)
                
                // 3m Days base [66] calculations
                compCharacteristics.close3MChange = calcRateS(x: compToday.s_close, y: comp3MoBef.s_close)
                compCharacteristics.volume3MChange = calcRateS(x: compToday.s_volume, y: comp3MoBef.s_volume)
                
                completion(compCharacteristics)
            
            }
        }.resume()
    }
}
