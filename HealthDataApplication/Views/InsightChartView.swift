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
                if let insight = insights.first {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                        HealthInsightCell(insight: insight)
                    }
                }
                Spacer()
                Chart {
                    ForEach(insights) { insight in
                        BarMark(x: .value("Date", insight.date), y: .value("Count", insight.num))
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
