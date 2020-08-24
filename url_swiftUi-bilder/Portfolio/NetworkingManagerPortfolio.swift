import Foundation
import Combine
import SwiftUI
import UIKit

extension String {
    func convertToNextDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let myDate = dateFormatter.date(from: self)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: myDate)
        return dateFormatter.string(from: tomorrow!)
    }
}

extension Array where Element == Double {
    public static func * (left: Double, right: [Double]) -> [Double] {

        return right.map { $0 * left }
    }

    public static func - (left: [Double], right: Double) -> [Double] {

        return left.map { roundGoodD(x: ($0 - right)) }
    }
    
    public static func + (left: [Double], right: [Double]) -> [Double] {
        
        var left = left
        var right = right
        
        let lenDiff = abs(left.count-right.count)
        let padding = [Double](repeating: 0.0, count: lenDiff)

        if left.count < right.count{
            left += padding
        }
        else{
            right += padding
        }

        return zip(left,right).map(+)
    }
    
    public static func - (left: [Double], right: [Double]) -> [Double] {
        
        var left = left
        var right = right
        
        let lenDiff = abs(left.count-right.count)
        let padding = [Double](repeating: 0.0, count: lenDiff)

        if left.count < right.count{
            left += padding
        }
        else{
            right += padding
        }

        return zip(left,right).map(-)
    }
}

extension Dictionary where Key == String , Value == CompData {
    func values(of: [String]) -> [Double]{
        var tmp: [Double] = []
        for key in of{
            tmp.append(Double(self[key]!.s_close)!)
        }
        return tmp
    }
}

// MARK: - User Input
struct UserInput: Equatable{
    let compName: String
    lazy var compSymbol = getKey(value: compName)
    let purchaseDate: String
    let purchaseAmount: Double
}

// MARK: - Company Portfolio Output
struct CompPortfolioOutput: Identifiable{
    var id = UUID()
    var compName: String = ""
    var compSymbol: String = ""
    var purchaseDate: String = ""
    var purchasePrice: Double = 0
    var purchaseAmount: Double = 0
    var totalInvestment: Double = 0
    var totalCurrentValue: Double = 0
    var gainHistory: [Double] = []
    var currentGain: Double = 0
}

//// MARK: - Class
class NetworkingManagerPortfolio: ObservableObject {
    var urlString: String
    var compPortfolioOutput = CompPortfolioOutput()

    init(userInput: UserInput) {
        var userInput = userInput
        
        self.compPortfolioOutput.compName = userInput.compName
        self.compPortfolioOutput.compSymbol = userInput.compSymbol
        self.compPortfolioOutput.purchaseDate = userInput.purchaseDate
        self.compPortfolioOutput.purchaseAmount = userInput.purchaseAmount
        
        self.urlString = MakeApiStringUrl(comp_symbol: compPortfolioOutput.compSymbol, outputsize: "full")
    }

    func getData(completion: @escaping (CompPortfolioOutput) -> ()){

        guard let url = URL(string: self.urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data,_,_) in
            guard let data = data else { return }

            let welcome = try! JSONDecoder().decode(Welcome.self, from: data)

            DispatchQueue.main.async {

                var workingDate = self.compPortfolioOutput.purchaseDate
                let totDatesArr = welcome.compData.keys.sorted(by: >)
                while !totDatesArr.contains(workingDate) {
                    workingDate = workingDate.convertToNextDate()
                }
                let thatDatePosition = totDatesArr.firstIndex(of: workingDate)!
                let usefulDates = Array(totDatesArr[0...thatDatePosition])
                let prices = welcome.compData.values(of: usefulDates)
                let thatTimePrice = prices.last!

                self.compPortfolioOutput.gainHistory = self.compPortfolioOutput.purchaseAmount * (prices - thatTimePrice)

                self.compPortfolioOutput.currentGain = calcRateD(x: prices.first!, y: prices.last!)
                
                self.compPortfolioOutput.totalInvestment = self.compPortfolioOutput.purchaseAmount * prices.last!
                
                self.compPortfolioOutput.purchasePrice = prices.last!
                
                self.compPortfolioOutput.totalCurrentValue = self.compPortfolioOutput.purchaseAmount * prices.first!

                completion(self.compPortfolioOutput)
            }
        }.resume()
    }
}

// MARK: - Sample Offline Data
func JsonOfflineCompPortfolioOutput() -> CompPortfolioOutput {
    let url = Bundle.main.url(forResource: "AmdOfflineApiData", withExtension: ".txt")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)

    var compPortfolioOutput = CompPortfolioOutput(compName: "Apple Inc.", compSymbol: "aapl", purchaseDate: "2020-03-19", purchaseAmount: 12)
    
    let workingDate = compPortfolioOutput.purchaseDate
    let totDatesArr = welcome.compData.keys.sorted(by: >)

    let thatDatePosition = totDatesArr.firstIndex(of: workingDate)!
    let usefulDates = Array(totDatesArr[0...thatDatePosition])
    let prices = welcome.compData.values(of: usefulDates)
    let thatTimePrice = prices.last!

    compPortfolioOutput.gainHistory = compPortfolioOutput.purchaseAmount * (prices - thatTimePrice)

    compPortfolioOutput.currentGain = roundGoodD(x: (prices.first! - prices.last!) / prices.last!)
    
    compPortfolioOutput.totalInvestment = compPortfolioOutput.purchaseAmount * prices.last!
    
    compPortfolioOutput.purchasePrice = prices.last!
    
    compPortfolioOutput.totalCurrentValue = compPortfolioOutput.purchaseAmount * prices.first!

    return compPortfolioOutput
}
