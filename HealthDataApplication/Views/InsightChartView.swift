//
//  InsightChartView.swift
//  HealthDataApplication
//
//  Created by User on 11.12.2023.
//

import SwiftUI
import Charts

struct InsightChartView: View {
    @EnvironmentObject var manager: HealthStore
    let insights: [HealthInsight]
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                let dict = manager.averageStats
                if let title = insights.first?.title, let insight = dict[title] {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: 150)
                        HealthInsightCell(insight: insight)
                            .frame(maxWidth: .infinity, maxHeight: 130)
                    }
                }
                Spacer()
                Chart {
                    ForEach(insights) { insight in
                        BarMark(x: .value("Month", insight.currentMonth), y: .value("Count", insight.num))
                            .foregroundStyle(.blue)
                    }
                }
                .frame(height: geometry.size.height / 2)
                .padding(30)
                Spacer()
            }
        }
    }
}
