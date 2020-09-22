import Foundation
import Combine

enum NetworkError: Error {
    case badURL
}

//// MARK: - Class
class NetworkingManagerPortfolio: ObservableObject {
    var urlString: String
    var compPortfolioOutput = CompPortfolioOutput()
    var welcome: Welcome?
    var manualPurchasedPrice: Double? = nil
    
    init(userInput: UserInput) {
        let userInput = userInput
        
        self.compPortfolioOutput.id = userInput.id // bijectiv relation
        self.compPortfolioOutput.savingKey = savingKeyMaker(userInput)
        self.compPortfolioOutput.compName = userInput.compName
        self.compPortfolioOutput.compSymbol = userInput.compSymbol
        self.compPortfolioOutput.purchaseDate = userInput.purchaseDate
        self.compPortfolioOutput.purchaseAmount = userInput.purchaseAmount
        
        self.urlString = MakeApiStringUrl(compSymbol: compPortfolioOutput.compSymbol, outputSize: "full")
        
        if !userInput.manualPurchasedPrice.isZero { self.manualPurchasedPrice = userInput.manualPurchasedPrice }
    }
    
    func getData(completion: @escaping (Result<CompPortfolioOutput, NetworkError>) -> ()){
        
        if let loadedCompPortfolioOutput = load_CompPortfolioOutput(fileName: compPortfolioOutput.savingKey){
            if loadedCompPortfolioOutput.lastServerCheckTime! >= refreshDateThreshold(){
                completion(.success(loadedCompPortfolioOutput))
                return
            }
        }
        
        if let loadedWelcome = load_Welcome(compSymbol: self.compPortfolioOutput.compSymbol){
            if loadedWelcome.lastServerCheckTime! >= refreshDateThreshold(){
                self.welcome = loadedWelcome
                self.makeCalculations()
                
                save_CompPortfolioOutput(compPortfolioOutput: self.compPortfolioOutput, fileName: self.compPortfolioOutput.savingKey)
                
                completion(.success(self.compPortfolioOutput))
                return
            }
        }
        guard let url = URL(string: self.urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data,_,_) in
            guard let data = data else { return }
            
            do{
                self.welcome = try JSONDecoder().decode(Welcome.self, from: data)
                DispatchQueue.main.async {
                    
                    self.makeCalculations()
                    
                    save_CompPortfolioOutput(compPortfolioOutput: self.compPortfolioOutput, fileName: self.compPortfolioOutput.savingKey)
                    save_Welcome(welcome: self.welcome!, compSymbol: self.compPortfolioOutput.compSymbol)
                    
                    completion(.success(self.compPortfolioOutput))
                    
                }
            } catch {
//                print(error)
                completion(.failure(.badURL))
                return
            }
            
            
        }.resume()
        
    }
    
    func makeCalculations(){
        var workingDate = self.compPortfolioOutput.purchaseDate
        let totDatesArr = welcome!.compData.keys.sorted(by: >)
        
        let date0D = totDatesArr[0]
        let date1D = totDatesArr[1]
        let date5D = totDatesArr[5]
        let date1M = totDatesArr[22]
        let date1Y = totDatesArr[264]
        
        // Make up day statistics
        self.compPortfolioOutput.open = (self.welcome!.compData[date0D]?.s_open)!
        self.compPortfolioOutput.close = (self.welcome!.compData[date0D]?.s_close)!
        self.compPortfolioOutput.high = (self.welcome!.compData[date0D]?.s_high)!
        self.compPortfolioOutput.low = (self.welcome!.compData[date0D]?.s_low)!
        self.compPortfolioOutput.volume = (self.welcome!.compData[date0D]?.s_volume)!
        
        // Making up watchlist data
        self.compPortfolioOutput.priceChange1D = calcRateS(x: self.welcome!.compData[date0D]!.s_close, y: self.welcome!.compData[date1D]!.s_close)
        self.compPortfolioOutput.priceChange5D = calcRateS(x: self.welcome!.compData[date0D]!.s_close, y: self.welcome!.compData[date5D]!.s_close)
        self.compPortfolioOutput.priceChange1M = calcRateS(x: self.welcome!.compData[date0D]!.s_close, y: self.welcome!.compData[date1M]!.s_close)
        self.compPortfolioOutput.priceChange1Y = calcRateS(x: self.welcome!.compData[date0D]!.s_close, y: self.welcome!.compData[date1Y]!.s_close)
        
        self.compPortfolioOutput.volumeChange1D = calcRateS(x: self.welcome!.compData[date0D]!.s_volume, y: self.welcome!.compData[date1D]!.s_volume)
        self.compPortfolioOutput.volumeChange5D = calcRateS(x: self.welcome!.compData[date0D]!.s_volume, y: self.welcome!.compData[date5D]!.s_volume)
        self.compPortfolioOutput.volumeChange1M = calcRateS(x: self.welcome!.compData[date0D]!.s_volume, y: self.welcome!.compData[date1M]!.s_volume)
        self.compPortfolioOutput.volumeChange1Y = calcRateS(x: self.welcome!.compData[date0D]!.s_volume, y: self.welcome!.compData[date1Y]!.s_volume)
        
        
        // Making up portfolio data
        while !totDatesArr.contains(workingDate) {
            workingDate = workingDate.convertToNextDate()
        }
        let thatDatePosition = totDatesArr.firstIndex(of: workingDate)!
        let usefulDates = Array(totDatesArr[0...thatDatePosition])
        let prices = self.welcome!.compData.values(of: usefulDates)
        
        let thatTimePrice: Double = self.manualPurchasedPrice ?? prices.last!
        
        self.compPortfolioOutput.gainHistory = self.compPortfolioOutput.purchaseAmount * (prices - thatTimePrice)
        
        self.compPortfolioOutput.currentGain = calcRateD(x: prices.first!, y: thatTimePrice)
        
        self.compPortfolioOutput.totalInvestment = self.compPortfolioOutput.purchaseAmount * thatTimePrice
        
        self.compPortfolioOutput.purchasePrice = thatTimePrice
        
        self.compPortfolioOutput.totalCurrentValue = self.compPortfolioOutput.purchaseAmount * prices.first!
        
        self.compPortfolioOutput.lastRefreshed = self.welcome!.metaData.lastRefreshed
        
        self.compPortfolioOutput.priceHistory = prices
        
        // get dividends
        var filteredDict = self.welcome!.compData.filter{ Double($0.value.s_dividend) != 0 }
        self.compPortfolioOutput.dividendDict = filteredDict.mapValues { value in value.s_dividend }
        
        // get splits
        filteredDict = self.welcome!.compData.filter{ Double($0.value.s_split_coeff) != 1 }
        self.compPortfolioOutput.splitsDict = filteredDict.mapValues { value in value.s_split_coeff }
        
        self.compPortfolioOutput.lastServerCheckTime = now()
        self.welcome!.lastServerCheckTime = now()
    }
}


// MARK: - Class
class NetworkingManagerNews: ObservableObject {
    var urlString: String
    let compSymbol: String
    
    init(compSymbol: String) {
        self.compSymbol = compSymbol
        let name = myDic_Symb2Name[compSymbol]!
        let reformattedString = name.replacingOccurrences(of: " ", with: "%20")
        self.urlString = "http://newsapi.org/v2/everything?q=" + reformattedString + "&from=2020-09-01&sortBy=publishedAt&language=en&apiKey=1da1fd527f8542cb87bd34bfb3d78979"
        // alternativ: sortBy=popularity
    }
    
    func getData(completion: @escaping ([Article]) -> ()){
        
        if let loadedArticles = load_Articles(compSymbol: self.compSymbol){
            if let lastServerCheckTime = loadedArticles[0].lastServerCheckTime{
                if (Date() - lastServerCheckTime)/3600 < 1{
                    completion(loadedArticles)
                    return
                }
            }
        }
        
        guard let url = URL(string: self.urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data,_,_) in
            guard let data = data else { return }
            
            var welcomeNews = try! JSONDecoder().decode(WelcomeNews.self, from: data)
            welcomeNews.articles[0].lastServerCheckTime = now()
            
            DispatchQueue.main.async {
                save_Articles(articles: welcomeNews.articles, compSymbol: self.compSymbol)
                
                completion(welcomeNews.articles)
                
            }
        }.resume()
    }
}
