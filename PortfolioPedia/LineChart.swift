//
//  ContentView.swift
//  LineChartExample
//
//  Created by Paul Hudson on 15/09/2020.
//

import SwiftUI
import Foundation

struct DataPoint {
    let value: Double
}

struct LineChartShape: Shape {
    let dataPoints: [Double]
    let drawLine: Bool
    let markPoints: Bool
    
    let pointSize: CGFloat = 2
    let maxValue: Double
    let absMaxValue: Double
    let minValue: Double
    let maxValueIndex: Int
    let minValueIndex: Int
    
    init(dataPoints: [Double], drawLine: Bool, markPoints: Bool) {
        self.dataPoints = dataPoints
        self.drawLine = drawLine
        self.markPoints = markPoints
        
        self.absMaxValue = dataPoints.map(abs).max() ?? 1
        self.maxValue = dataPoints.max() ?? 1
        self.minValue = dataPoints.min() ?? 0
        self.minValueIndex = 0
        self.maxValueIndex = 0
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let drawRect = rect.insetBy(dx: pointSize, dy: pointSize)
        
        let xMultiplier = drawRect.width / CGFloat(dataPoints.count - 1)
        let yMultiplier = drawRect.height / CGFloat(absMaxValue) / 2
        
        for (index, value) in dataPoints.enumerated() {
            var x = xMultiplier * CGFloat(index)
            var y = yMultiplier * CGFloat(value)
            
            y = drawRect.height/2 - y
            
            x += drawRect.minX
            y += drawRect.minY
            
            if  drawLine{
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            if index == dataPoints.endIndex - 1 || index == 0 {
                x -= pointSize / 2
                y -= pointSize / 2

                path.addEllipse(in: CGRect(x: x-1, y: y, width: 4, height: pointSize))
            }
            
            if  markPoints && (value == maxValue || value == minValue) {
                x -= pointSize / 2
                y -= pointSize / 2
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: drawRect.height))
            }
            
        }
        
        return path
    }
}

struct LineChart: View {
    @Environment(\.colorScheme) var colorScheme
    
    let yDataPoints: [Double]
    let withYLabels: Bool
    let withAnimation: Bool
    
    let xDataPoints = [String]()
    
    let markPoints: Bool = false
    
    
    let withXLabels: Bool = false
    let ySteps: Int = 8
    let xSteps: Int = 3
    
    var nonDarkModelineColor = LinearGradient(gradient: Gradient(colors: [Color(Color.RGBColorSpace.sRGB, red: 0, green: 0, blue: 1, opacity: 0.8), Color(Color.RGBColorSpace.sRGB, red: 0, green: 0, blue: 1, opacity: 1)]), startPoint: .leading, endPoint: .trailing)
    var darkModelineColor = LinearGradient(gradient: Gradient(colors: [Color(Color.RGBColorSpace.sRGB, red: 1, green: 1, blue: 0, opacity: 0.8), Color(Color.RGBColorSpace.sRGB, red: 1, green: 1, blue: 0, opacity: 1)]), startPoint: .leading, endPoint: .trailing)
    
    var lineWidth: CGFloat = 2
    
    // for Animation
    @State private var percentage: CGFloat = .zero
    
    var body: some View {
        VStack{
            HStack{
                if withYLabels{
                    VStack {
                        Spacer()
                        ForEach(calcYLabels(stepNumb: ySteps), id: \.self) { label in
                            ZStack {
                                Text(String(label))
                                    .minimumScaleFactor(0.1)
                                    .animation(nil)
                                    .offset(y: -8.5)
                            }
                            Spacer()
                        }
                    }
                }
                
                ZStack {
                    if withYLabels{
                        VStack {
                            ForEach(calcYLabels(stepNumb: ySteps), id: \.self) { label in
                                ZStack {
                                    Text(String(label))
                                        .minimumScaleFactor(0.1)
                                        .padding(.horizontal)
                                        .animation(nil)
                                        .foregroundColor(.clear)
                                    Divider()
                                }.offset(y: -8.5)
                                Spacer()
                            }
                        }
                    }
                    if withXLabels{
                        HStack {
                            ForEach(0...xSteps, id: \.self) { _ in
                                ZStack{
                                    Divider()
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    LineChartShape(dataPoints: yDataPoints, drawLine: true, markPoints: false)
                        .trim(from: 0, to: percentage) // breaks path by parts, animatable
                        .stroke(colorScheme == .dark ? darkModelineColor : nonDarkModelineColor, lineWidth: lineWidth)
                        .border(colorScheme == .dark ? Color.white : Color.black)
                        .animation(.easeOut(duration: withAnimation ? 1 : 0)) // animate
                        .onAppear {
                            self.percentage = 1 // activates animation for 0 to the end of frame
                        }
                    
                    if markPoints{
                        LineChartShape(dataPoints: yDataPoints, drawLine: false, markPoints: true)
                            .stroke(Color.orange, style: StrokeStyle( lineWidth: 2, dash: [5]))
                    }
                }
            }
            
            if withXLabels{
                HStack {
                    ForEach(calcXLabels(stepNumb: xSteps), id: \.self) { label in
                        Text(label)
                            .frame(width: 70)
                            .animation(nil)
                        Spacer()
                    }
                }
                .minimumScaleFactor(0.01)
                .lineLimit(1)
            }
        }
    }
    
    private func calcYLabels(stepNumb: Int) -> [Int]{
        var tmp = [Int]()
        let absMax = yDataPoints.map(abs).max() ?? 1
        
        for i in (0...stepNumb-1){
            let stepSize = (2*absMax)/Double(stepNumb)
            tmp.append(Int(absMax - Double(i) * stepSize))
        }
        return tmp
    }
    
    private func calcXLabels(stepNumb: Int) -> [String]{
        var tmp = [String]()
        
        for i in (0...stepNumb){
            let stepSize = xDataPoints.count/stepNumb
            tmp.append(xDataPoints[xDataPoints.count - i * stepSize])
        }
        return tmp
    }
}

struct myChartView: View {
    var yDataPoints: [Double]

    var body: some View {
        VStack{
            LineChart(yDataPoints: yDataPoints, withYLabels: true, withAnimation: false)
                .frame(width: 350, height: 200, alignment: .center)
        }
    }
}

struct myChartView_Previews: PreviewProvider {
    static var previews: some View {
        myChartView(yDataPoints: SampleData().totalNumbers.totalGainHistory.reversed())
    }
}
