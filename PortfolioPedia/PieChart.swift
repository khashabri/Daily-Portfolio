import SwiftUI

let sampleChartDataModel = [ ChartCellModel(color: Color.red, value: 123, name: "Math"),
                             ChartCellModel(color: Color.yellow, value: 233, name: "Physics"),
                             ChartCellModel(color: Color.pink, value: 73, name: "Chemistry"),
                             ChartCellModel(color: Color.blue, value: 731, name: "Litrature"),
                             ChartCellModel(color: Color.green, value: 51, name: "Art")]

struct PieChartCell: Shape {
    let startAngle: Angle
    let endAngle: Angle
    func path(in rect: CGRect) -> Path {
        let center = CGPoint.init(x: (rect.origin.x + rect.width)/2, y: (rect.origin.y + rect.height)/2)
        let radii = min(center.x, center.y)
        let path = Path { p in
            p.addArc(center: center,
                     radius: radii,
                     startAngle: startAngle,
                     endAngle: endAngle,
                     clockwise: true)
            p.addLine(to: center)
        }
        return path
    }
}

struct InnerCircle: Shape {
    let ratio: CGFloat
    func path(in rect: CGRect) -> Path {
        let center = CGPoint.init(x: (rect.origin.x + rect.width)/2, y: (rect.origin.y + rect.height)/2)
        let radii = min(center.x, center.y) * ratio
        let path = Path { p in
            p.addArc(center: center,
                     radius: radii,
                     startAngle: Angle(degrees: 0),
                     endAngle: Angle(degrees: 360),
                     clockwise: true)
            p.addLine(to: center)
        }
        return path
    }
}

struct DonutChart: View {
    @State private var selectedCell: UUID = UUID()
    
    let dataModel: ChartDataModel
    let onTap: (ChartCellModel?) -> ()
    var body: some View {
        ZStack {
            PieChart(dataModel: dataModel, onTap: onTap)
            InnerCircle(ratio: 1/3).foregroundColor(.white)
        }
    }
}

struct PieChart: View {
    @State private var selectedCell: UUID = UUID()
    
    let dataModel: ChartDataModel
    let onTap: (ChartCellModel?) -> ()
    var body: some View {
        ZStack {
            ForEach(dataModel.chartCellModel) { dataSet in
                PieChartCell(startAngle: self.dataModel.angle(for: dataSet.value), endAngle: self.dataModel.startingAngle)
                    .foregroundColor(dataSet.color)
                    .onTapGesture {
                        withAnimation {
                            if self.selectedCell == dataSet.id {
                                self.onTap(nil)
                                self.selectedCell = UUID()
                            } else {
                                self.selectedCell = dataSet.id
                                self.onTap(dataSet)
                            }
                        }
                    }.scaleEffect((self.selectedCell == dataSet.id) ? 1.05 : 1.0)
            }
        }
    }
}

struct ChartCellModel: Identifiable {
    let id = UUID()
    let color: Color
    let value: CGFloat
    let name: String
}

final class ChartDataModel: ObservableObject {
    var chartCellModel: [ChartCellModel]
    var startingAngle = Angle(degrees: 0)
    private var lastBarEndAngle = Angle(degrees: 0)
    
    
    init(dataModel: [ChartCellModel]) {
        chartCellModel = dataModel
    }
    
    var totalValue: CGFloat {
        chartCellModel.reduce(CGFloat(0)) { (result, data) -> CGFloat in
            result + data.value
        }
    }
    
    func angle(for value: CGFloat) -> Angle {
        if startingAngle != lastBarEndAngle {
            startingAngle = lastBarEndAngle
        }
        lastBarEndAngle += Angle(degrees: Double(value / totalValue) * 360 )
        return lastBarEndAngle
    }
}

struct PieChartView: View {
    @State var handelDicts: HandelDicts
    @State var selectedPie: String = ""
    @State var selectedDonut: String = ""
    
    var body: some View {
        VStack {
            VStack {
                PieChart(dataModel: ChartDataModel.init(dataModel: makeChartDataModel()), onTap: {
                    dataModel in
                    if let dataModel = dataModel {
                        self.selectedPie = "Company Name: \(dataModel.name)\nCurrent investment value: \(dataModel.value) $"
                    } else {
                        self.selectedPie = ""
                    }
                })
                .frame(width: 150, height: 150, alignment: .center)
                .padding()
                Text(selectedPie)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    ForEach(makeChartDataModel()) { dataSet in
                        VStack {
                            Circle()
                                .foregroundColor(dataSet.color)
                                .frame(width: 25, height: 25)
                            Text(dataSet.name).font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                        }.padding(.horizontal)
                    }
                }
                .padding()
            }
            
        }
    }
    
    private func makeChartDataModel() -> [ChartCellModel]{
        var tmp = [ChartCellModel]()
        var colorsArray = [Color.red, Color.yellow, Color.blue, Color.green, Color.black, Color.gray, Color.orange, Color.purple]
        
        for key in handelDicts.portfolioListInvestDict.keys.sorted(){
            tmp.append(ChartCellModel(color: colorsArray.removeFirst() , value: CGFloat(roundGoodD(handelDicts.portfolioListInvestDict[key]! + handelDicts.portfolioListGainDict[key]!)), name: handelDicts.companiesEntriesDict[key]![0].compName))
        }
        
        return tmp
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(handelDicts: SampleData().handelDicts)
    }
}
