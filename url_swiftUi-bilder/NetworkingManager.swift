//import Foundation
//import Combine
//import SwiftUI
//import UIKit
//
//
//// MARK: - Welcome
//struct Welcome: Codable & Decodable {
//    let pagination: Pagination
//    var data: [CompData]
//}
//
//// MARK: - CompData
//struct CompData: Codable & Identifiable & Decodable {
//    var id = UUID()
//    let datumOpen, high, low, close: Double
//    let volume: Int
//    let adjHigh, adjLow, adjClose, adjOpen: Double
//    let adjVolume: Int
//    let symbol, exchange: String
//    let date: String
//    var pchange: Double = 0
//    var totalProgress: [Double] = [0]
//
//        enum CodingKeys: String, CodingKey, Decodable {
//        case datumOpen = "open"
//        case high, low, close, volume
//        case adjHigh = "adj_high"
//        case adjLow = "adj_low"
//        case adjClose = "adj_close"
//        case adjOpen = "adj_open"
//        case adjVolume = "adj_volume"
//        case symbol, exchange, date
//        }
//}
//
//
//// MARK: - Pagination
//struct Pagination: Codable & Decodable {
//    let limit, offset, count, total: Int
//}
//
//
//// MARK: - Class
//class NetworkingManager: ObservableObject {
//    var urlString: String
//
//    init(symbl: String) {
//        self.urlString = MakeApiStringUrl(comp_symbol: symbl)
//    }
//    func getData(completion: @escaping (CompData) -> ()){
//
//        guard let url = URL(string: self.urlString) else { return }
//
//        URLSession.shared.dataTask(with: url) { (data,_,_) in
//            guard let data = data else { return }
//
//            let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
//
//            DispatchQueue.main.async {
//                let price_change = (welcome.data[0].close - welcome.data[1].close)/welcome.data[1].close * 100
//                var compData = welcome.data[0]
//                compData.pchange = (price_change*100).rounded()/100
//
//                completion(compData)
//                print(welcome.data)
//                print(price_change)
//            }
//        }.resume()
//    }
//}
//
