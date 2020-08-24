import Foundation
import Combine
import SwiftUI
import UIKit


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
        
        self.urlString = MakeApiStringUrl(compSymbol: compPortfolioOutput.compSymbol, outputSize: "full")
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
                
                self.compPortfolioOutput.lastRefreshed = welcome.metaData.lastRefreshed
                
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
    
    compPortfolioOutput.lastRefreshed = welcome.metaData.lastRefreshed
    
    return compPortfolioOutput
}
