//
//  BarChart.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 11/18/21.
//

import SwiftUI
import Charts

private let shotTypes = Stat.ShotType.allCases.sorted { lhs, rhs in
    lhs.trackingOrder < rhs.trackingOrder
}

struct ShotTypeBarChart: UIViewRepresentable {
    
    let data: [Stat.ShotType: (winners: Double, errors: Double)]
    var winners: BarChartDataSet {
        let dataset = BarChartDataSet(
            entries: shotTypes.indexed().map {
                BarChartDataEntry(x: Double($0.index), y: data[$0.element]?.winners ?? 0.0)
            },
            label: "Winners"
        )
        dataset.setColor(UIColor.blue.withAlphaComponent(0.7))
        dataset.drawValuesEnabled = false
        return dataset
    }
    var errors: BarChartDataSet {
        let dataset = BarChartDataSet(
            entries: shotTypes.indexed().map {
                BarChartDataEntry(x: Double($0.index), y: data[$0.element]?.errors ?? 0.0)
            },
            label: "Errors"
        )
        dataset.setColor(UIColor.red.withAlphaComponent(0.7))
        dataset.drawValuesEnabled = false
        return dataset
    }
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = Double(shotTypes.count)
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 1
        xAxis.valueFormatter = XAxisValueFormatter()
        
        chart.leftAxis.axisMinimum = 0
        
        chart.rightAxis.enabled = false
        
        chart.highlightPerTapEnabled = false
        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        let data = BarChartData(dataSets: [winners, errors])
        // 2 * (0.4 + 0.05) + 0.1 = 1
        data.barWidth = 0.4
        data.groupBars(fromX: 0, groupSpace: 0.1, barSpace: 0.05)
        uiView.data = data
        
        uiView.animate(yAxisDuration: 1, easingOption: .easeInOutQuad)
    }
    
    typealias UIViewType = BarChartView
}

class XAxisValueFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return shotTypes[safe: Int(value)]?.rawValue.capitalized ?? ""
    }
}

struct ShotTypeBarChart_Previews: PreviewProvider {
    static var previews: some View {
        ShotTypeBarChart(data: [
            Stat.ShotType.drop: (21.4, 11.4),
            Stat.ShotType.dink: (11.9, 21.9),
            Stat.ShotType.drive: (46.1, 36.1),
            Stat.ShotType.volley: (27, 17),
            Stat.ShotType.lob: (8.3, 18.3),
            Stat.ShotType.overhead: (5.3, 7.3),
            Stat.ShotType.serve: (25.0, 2.0)
        ])
    }
}
