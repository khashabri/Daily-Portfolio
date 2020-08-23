//
//  ChartView.swift
//  Stockpedia
//
//  Created by Khashayar Abri on 06.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct ChartView: View {
    @State var tabIndex:Int = 0
    
        var body: some View {
            TabView(selection: $tabIndex) {
                BarCharts().tabItem { Group{
                        Image(systemName: "chart.bar")
                        Text("Bar charts")
                    }}.tag(0)
                LineCharts().tabItem { Group{
                        Image(systemName: "waveform.path.ecg")
                        Text("Line charts")
                    }}.tag(1)
                PieCharts().tabItem { Group{
                        Image(systemName: "chart.pie")
                        Text("Pie charts")
                    }}.tag(2)
                LineChartsFull().tabItem { Group{
                    Image(systemName: "waveform.path.ecg")
                    Text("Full screen line charts")
                }}.tag(3)
            }
        }
    }

    struct BarCharts:View {
        var body: some View {
            VStack{
                BarChartView(data: ChartData(points: [0,-8,23,54]), title: "Apple", style: Styles.barChartStyleNeonBlueLight, form: ChartForm.large, dropShadow: false)
            }
        }
    }

    struct LineCharts:View {
        var body: some View {
            VStack{
                
                LineChartView(data: [437.4900, 438.1800, 437.9900, 437.8200, 437.9760, 437.5200, 437.6650, 437.9800, 437.7020, 438.2300, 438.3949, 438.1782, 437.9123, 438.0676, 437.5200, 437.0450, 437.2630, 436.42, 437.4900, 438.1800, 437.9900, 437.8200, 437.9760, 437.5200, 437.6650, 437.9800, 437.7020, 438.2300, 438.3949, 438.1782, 437.9123, 438.0676, 437.5200, 437.0450, 437.2630, 436.42,437.4900, 438.1800, 437.9900, 437.8200, 437.9760, 437.5200, 437.6650, 437.9800, 437.7020, 438.2300, 438.3949, 438.1782, 437.9123, 438.0676, 437.5200, 437.0450, 437.2630, 436.42,437.4900, 438.1800, 437.9900, 437.8200, 437.9760, 437.5200, 437.6650, 437.9800, 437.7020, 438.2300, 438.3949, 438.1782, 437.9123, 438.0676, 437.5200, 437.0450, 437.2630, 436.42,437.4900, 438.1800, 437.9900, 437.8200, 437.9760, 437.5200, 437.6650, 437.9800, 437.7020, 438.2300, 438.3949, 438.1782, 437.9123, 438.0676, 437.5200, 443.0450, 440.2630, 445.42], title: "Apple Inc.", legend: "Today's changes", form: ChartForm.large, dropShadow: true)
                    .padding(.top, 30.0)
                Spacer()
            }
            
        }
    }

    struct PieCharts:View {
        var body: some View {
            VStack{
                PieChartView(data: [8,23,54,32,12,37,7,23,43], title: "Title")
            }
        }
    }

    struct LineChartsFull: View {
        var body: some View {
            VStack{
                LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
                // legend is optional, use optional .padding()
            }
        }
    }

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
