//
//  Extentions.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import Foundation

extension String {
    // calc next day for a string date
    func convertToNextDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let myDate = dateFormatter.date(from: self)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: myDate)
        return dateFormatter.string(from: tomorrow!)
    }
}

extension Array where Element == Double {
    // 2 * [Double]
    public static func * (left: Double, right: [Double]) -> [Double] {
        
        return right.map { $0 * left }
    }
    
    // [Double] - 2
    public static func - (left: [Double], right: Double) -> [Double] {
        
        return left.map { roundGoodD(($0 - right)) }
    }
    
    // [Double] + [Double]
    public static func + (left: [Double], right: [Double]) -> [Double] {
        
        var left = left
        var right = right
        
        let lenDiff = abs(left.count-right.count)
        let padding = [Double](repeating: 0.0, count: lenDiff)
        
        // += merges two arrays. + adds them elementarwise
        (left.count < right.count) ? (left += padding) : (right += padding)
        
        return zip(left,right).map(+)
    }
    
    // [Double] - [Double]
    public static func - (left: [Double], right: [Double]) -> [Double] {
        
        var left = left
        var right = right
        
        let lenDiff = abs(left.count-right.count)
        let padding = [Double](repeating: 0.0, count: lenDiff)
        
        (left.count < right.count) ? (left += padding) : (right += padding)
        
        return zip(left,right).map(-)
    }
}

extension Array where Element == UserInput{
    mutating func findByID(id: UUID) -> Int?{
        return self.firstIndex{ $0.id == id}
    }
}

extension Dictionary where Key == String , Value == CompData {
    // get values for multiple keys
    func values(of: [String]) -> [Double]{
        var tmp: [Double] = []
        for key in of{
            tmp.append(Double(self[key]!.s_close)!)
        }
        return tmp
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
