import Foundation
import Combine

//// MARK: - Class
class NetworkingManagerPortfolio: ObservableObject {
    var urlString: String
    var compPortfolioOutput = CompPortfolioOutput()
    var manualPurchasedPrice: Double? = nil
    
    init(userInput: UserInput) {
        var userInput = userInput
        
        self.compPortfolioOutput.id = userInput.id // bijectiv relation
        self.compPortfolioOutput.savingKey = savingKeyMaker(userInput)
        self.compPortfolioOutput.compName = userInput.compName
        self.compPortfolioOutput.compSymbol = userInput.compSymbol
        self.compPortfolioOutput.purchaseDate = userInput.purchaseDate
        self.compPortfolioOutput.purchaseAmount = userInput.purchaseAmount
        
        self.urlString = MakeApiStringUrl(compSymbol: compPortfolioOutput.compSymbol, outputSize: "full")
        
        if !userInput.manualPurchasedPrice.isZero { self.manualPurchasedPrice = userInput.manualPurchasedPrice }
    }
    
//    func save() {
//        if let encoded = try? JSONEncoder().encode(self.compPortfolioOutput) {
//            UserDefaults.standard.set(encoded, forKey: self.compPortfolioOutput.savingKey)
//        }
//    }
//    
//    func load() -> CompPortfolioOutput {
//        if let data = UserDefaults.standard.data(forKey: self.compPortfolioOutput.savingKey) {
//            if let decoded = try? JSONDecoder().decode(CompPortfolioOutput.self, from: data) {
//                self.compPortfolioOutput = decoded
//                
//                print("####### Loaded Data #######")
//                //                print(compPortfolioOutput)
//                return compPortfolioOutput
//            }
//        }
//        return CompPortfolioOutput()
//    }
    
    func getData(completion: @escaping (CompPortfolioOutput) -> ()){
        
        if let loadedCompPortfolioOutput = load_CompPortfolioOutput(fileName: compPortfolioOutput.savingKey){
            if loadedCompPortfolioOutput.lastRefreshed == "2020-09-04"{
                completion(loadedCompPortfolioOutput)
                return
            }
        }
        
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
                
                // Make up day statistics
                self.compPortfolioOutput.open = (welcome.compData[date0D]?.s_open)!
                self.compPortfolioOutput.close = (welcome.compData[date0D]?.s_close)!
                self.compPortfolioOutput.high = (welcome.compData[date0D]?.s_high)!
                self.compPortfolioOutput.low = (welcome.compData[date0D]?.s_low)!
                self.compPortfolioOutput.volume = (welcome.compData[date0D]?.s_volume)!
                
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
                
                let thatTimePrice: Double = self.manualPurchasedPrice ?? prices.last!
                
                self.compPortfolioOutput.gainHistory = self.compPortfolioOutput.purchaseAmount * (prices - thatTimePrice)
                
                self.compPortfolioOutput.currentGain = calcRateD(x: prices.first!, y: thatTimePrice)
                
                self.compPortfolioOutput.totalInvestment = self.compPortfolioOutput.purchaseAmount * thatTimePrice
                
                self.compPortfolioOutput.purchasePrice = thatTimePrice
                
                self.compPortfolioOutput.totalCurrentValue = self.compPortfolioOutput.purchaseAmount * prices.first!
                
                self.compPortfolioOutput.lastRefreshed = welcome.metaData.lastRefreshed
                
                self.compPortfolioOutput.priceHistory = prices
                
                // get max last 5 dividends
                var maxN = 5
                var filteredDict = welcome.compData.filter{ Double($0.value.s_dividend) != 0 }
                var keys = filteredDict.keys.sorted(by: >)
                (keys.count > maxN) ? keys = Array(keys[0...maxN]) : ()
                
                for key in keys{
                    self.compPortfolioOutput.dividendDict[key] = filteredDict[key]?.s_dividend
                }
                
                // get max last 3 splits
                maxN = 2
                filteredDict = welcome.compData.filter{ Double($0.value.s_split_coeff) != 1 }
                keys = filteredDict.keys.sorted(by: >)
                (keys.count > maxN) ? keys = Array(keys[0...maxN]) : ()
                
                for key in keys{
                    self.compPortfolioOutput.splitsDict[key] = filteredDict[key]?.s_split_coeff
                }
                
                save_CompPortfolioOutput(compPortfolioOutput: self.compPortfolioOutput, fileName: self.compPortfolioOutput.savingKey)
                print("####### Saved Data #######")
                
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
    
    compPortfolioOutput.currentGain = roundGoodD((prices.first! - prices.last!) / prices.last!)
    
    compPortfolioOutput.totalInvestment = compPortfolioOutput.purchaseAmount * prices.last!
    
    compPortfolioOutput.purchasePrice = prices.last!
    
    compPortfolioOutput.totalCurrentValue = compPortfolioOutput.purchaseAmount * prices.first!
    
    compPortfolioOutput.lastRefreshed = welcome.metaData.lastRefreshed
    
    return compPortfolioOutput
}
