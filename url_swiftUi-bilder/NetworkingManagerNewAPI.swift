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
                var arrayOfTodayCompData = welcome.compData[welcome.metaData.lastRefreshed]!
                arrayOfTodayCompData.makeDoubles(himself: arrayOfTodayCompData)
                
                // sorting the total recieved compData
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-dd-mm"
                
                var sortedCompData = welcome.compData.map { (formatter.date(from: $0)!, $0, $1) }
                .sorted { $0.0 < $1.0 }
                .map { ($0.1, $0.2) }
                
                sortedCompData = sortedCompData.reversed()
                
                // attaching the last 100 days prices to arrayOfTodayCompData
                for (_, value) in sortedCompData{
                    arrayOfTodayCompData.Days100Before.append(Double(value.s_close)!)
                }
                
                // calc pchange
                arrayOfTodayCompData.pchange = calcRateD(x: arrayOfTodayCompData.Days100Before[0], y: arrayOfTodayCompData.Days100Before[1])
                
                // saving company symbol and the last data check date
                arrayOfTodayCompData.symbol = welcome.metaData.symbol
                arrayOfTodayCompData.lastRefreshed = welcome.metaData.lastRefreshed

                // 1 Day base calculations
                arrayOfTodayCompData.volumeDayChange = calcRateS(x: sortedCompData[0].1.s_volume, y: sortedCompData[1].1.s_volume)
                
                // 30 Days base [22] calculations
                arrayOfTodayCompData.close1MChange = calcRateS(x: sortedCompData[0].1.s_close, y: sortedCompData[22].1.s_close)
                arrayOfTodayCompData.volume1MChange = calcRateS(x: sortedCompData[0].1.s_volume, y: sortedCompData[22].1.s_volume)
                
                // weekly Days base [5] calculations
                arrayOfTodayCompData.closeWeekChange = calcRateS(x: sortedCompData[0].1.s_close, y: sortedCompData[5].1.s_close)
                arrayOfTodayCompData.volumeWeekChange = calcRateS(x: sortedCompData[0].1.s_volume, y: sortedCompData[5].1.s_volume)
                
                // 3m Days base [66] calculations
                arrayOfTodayCompData.close3MChange = calcRateS(x: sortedCompData[0].1.s_close, y: sortedCompData[66].1.s_close)
                arrayOfTodayCompData.volume3MChange = calcRateS(x: sortedCompData[0].1.s_volume, y: sortedCompData[66].1.s_volume)
                
                print(welcome.compData)
//                print("###############")
//                print(arrayOfTodayCompData)
                completion(arrayOfTodayCompData)
                
//                print(roundGoodS(x: arrayOfTodayCompData.s_low))
            }
        }.resume()
    }
}
