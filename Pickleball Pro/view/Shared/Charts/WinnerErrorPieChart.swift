//
//  BarChart.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 11/18/21.
//

import SwiftUI
import Charts

private let valueFormatter = { () -> DefaultValueFormatter in
    let pFormatter = NumberFormatter()
    pFormatter.numberStyle = .percent
    pFormatter.maximumFractionDigits = 1
    pFormatter.multiplier = 1
    pFormatter.percentSymbol = " %"
    return DefaultValueFormatter(formatter: pFormatter)
}()

struct WinnerErrorPieChart: UIViewRepresentable {
    let data: [Stat.Result: Double]
    
    func makeUIView(context: Context) -> PieChartView {
        let chart = PieChartView()
        chart.chartDescription.enabled = false
        chart.usePercentValuesEnabled = true
        chart.holeColor = UIColor.systemBackground
        chart.holeRadiusPercent = 0.25
        chart.transparentCircleRadiusPercent = 0.3
        chart.rotationEnabled = false
        chart.highlightPerTapEnabled = false
        return chart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        let dataSet = PieChartDataSet(entries: data.map { PieChartDataEntry(value: $0.1, label: $0.0.pluralString) })
        dataSet.label = ""
        dataSet.colors = [UIColor.blue.withAlphaComponent(0.7), UIColor.red.withAlphaComponent(0.7)]
        let data = PieChartData(dataSet: dataSet)
        uiView.data = data
        
        // This must happen after the data is set on the chart, otherwise, it will get clobbered (https://github.com/danielgindi/Charts/issues/4690#issuecomment-897744617)
        uiView.data?.setValueFormatter(valueFormatter)
        
        // TODO: Do we want this?
        uiView.animate(yAxisDuration: 1, easingOption: .easeInOutQuad)
    }
    
    typealias UIViewType = PieChartView
}

struct WinnerErrorPieChart_Previews: PreviewProvider {
    static var previews: some View {
        WinnerErrorPieChart(data: [
            Stat.Result.winner: 200.0/350.0,
            Stat.Result.error: 150.0/350.0,
        ])
            .preferredColorScheme(.dark)
    }
}
