//
//  Extentions.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 24.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import Foundation
import SwiftUI

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
        return left.map { ($0 - right) }
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
    mutating func findByID(id: String) -> Int?{
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
    
    var currentUTCTimeZoneDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: self)
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array where Element == UserInput{
    func containsSameElements(as other: [Element]) -> Bool {
        let a = self.map{ $0.id }
        let b = other.map{ $0.id }
        return a.count == b.count && a.sorted() == b.sorted()
    }
}

extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
            .mask(self)
    }
}
