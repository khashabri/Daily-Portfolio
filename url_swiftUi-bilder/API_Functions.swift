//
//  API_Functions.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 02.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import Foundation


// heutiges Datum in eienr nützlichen Format
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

//func MakeApiStringUrl(comp_symbol: String) -> String {
//    let part1 = "http://api.marketstack.com/v1/eod?access_key=d11faf59cb9bd43de2000104c84dce14&symbols="
//    let part2 = comp_symbol
//    let part3 = "%20&%20date_from="
//    // let part4 = get_before_yesterday()
//    let part4 = ""
//    let overall = part1+part2+part3+part4
//
//    return overall
//}

func MakeApiStringUrl(comp_symbol: String, outputsize: String = "compact") -> String {
    let part1 = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol="
    let part2 = comp_symbol
    let part3 = "&outputsize="
    let part4 = outputsize
    let part5 = "&apikey=4HX8NVQU9MV6J5LY"
    let overall = part1+part2+part3+part4+part5

    return overall
}


func get_api_data(s_url: String) -> String {
    var contents = ""
    let url = calc_url(link_tmp: s_url)
    contents = try! String(contentsOf: url)

    return contents
}

func calc_url(link_tmp: String) -> URL {
    return URL(string: link_tmp) ?? URL(string: "a")!
}

func getKey(value: String) -> String {
    let idx = myDic_Symb2Name.values.firstIndex(of: value)
    let key = myDic_Symb2Name.keys[idx!]

    return key
}

func roundGoodD (x: Double) -> Double {
    return round(100 * x) / 100
}

func roundGoodS (x: String) -> String {
    return String(round(100 * Double(x)!) / 100)
}

func calcRateS (x: String, y: String) -> Double {
    let x = Double(x)!
    let y = Double(y)!
    return roundGoodD(x: (x-y)/y*100)
}

func calcRateD (x: Double, y: Double) -> Double {
    return roundGoodD(x: (x-y)/y*100)
}



