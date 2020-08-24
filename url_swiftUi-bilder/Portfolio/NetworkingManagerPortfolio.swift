import Foundation
import Combine

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
    var priceHistory: [Double] = []
    
    // Additionals
    var priceChange1D: Double = 0
    var priceChange5D: Double = 0
    var priceChange1M: Double = 0
    var priceChange1Y: Double = 0
    
    var volumeChange1D: Double = 0
    var volumeChange5D: Double = 0
    var volumeChange1M: Double = 0
    var volumeChange1Y: Double = 0
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
                
                let date0D = totDatesArr[0]
                let date1D = totDatesArr[1]
                let date5D = totDatesArr[5]
                let date1M = totDatesArr[22]
                let date1Y = totDatesArr[264]
                
                // Making up watchlist data
                self.compPortfolioOutput.priceChange1D = calcRateS(x: welcome.compData[date0D]!.s_close, y: welcome.compData[date1D]!.s_close)
                self.compPortfolioOutput.priceChange5D = calcRateS(x: welcome.compData[date0D]!.s_close, y: welcome.compData[date5D]!.s_close)
                self.compPortfolioOutput.priceChange1M = calcRateS(x: welcome.compData[date0D]!.s_close, y: welcome.compData[date1M]!.s_close)
                self.compPortfolioOutput.priceChange1Y = calcRateS(x: welcome.compData[date0D]!.s_close, y: welcome.compData[date1Y]!.s_close)
                
                self.compPortfolioOutput.volumeChange1D = calcRateS(x: welcome.compData[date0D]!.s_volume, y: welcome.compData[date1D]!.s_volume)
                self.compPortfolioOutput.volumeChange5D = calcRateS(x: welcome.compData[date0D]!.s_volume, y: welcome.compData[date5D]!.s_volume)
                self.compPortfolioOutput.volumeChange1M = calcRateS(x: welcome.compData[date0D]!.s_volume, y: welcome.compData[date1M]!.s_volume)
                self.compPortfolioOutput.volumeChange1Y = calcRateS(x: welcome.compData[date0D]!.s_volume, y: welcome.compData[date1Y]!.s_volume)
                
                
                // Making up portfolio data
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
                
                self.compPortfolioOutput.priceHistory = prices
                                
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
