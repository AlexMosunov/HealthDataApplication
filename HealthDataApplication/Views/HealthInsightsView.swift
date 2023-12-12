//
//  HealthInsightsView.swift
//  HealthDataApplication
//
//  Created by User on 09.12.2023.
//

import SwiftUI

struct HealthInsightsView: View {
    @EnvironmentObject var manager: HealthStore
    
    var body: some View {
        NavigationView {
            VStack {
                List(manager.statisticsDictionary.keys.sorted(), id: \.self) { insightTitle in
                    if let insight = manager.statisticsDictionary[insightTitle],
                       calendar.isDate(insight.date, inSameDayAs: .now) || calendar.isDate(insight.date, inSameDayAs: yesterday ?? .now) {
                        VStack {
                            Spacer()
                            NavigationLink(destination: InsightChartView(insights: manager.getSortedObjectsWithSameTitle(title: insight.title))) {
                                HealthInsightCell(insight: insight)
                            }
                            Spacer()
                        }
                        .frame(height: 140)
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                .navigationTitle("Health Insights")
            }
        }
    }
   
}

struct HealthInsightCell: View {
    var insight: HealthInsight
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(insight.title)
                .padding([.leading, .bottom],8)
                .fontWeight(.semibold)
                .font(.subheadline)
            
            VStack(alignment: .center) {
                Text(insight.subtitle ?? "\(insight.num)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.teal)
                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.top, 4)
                
                Text(insight.unit)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
            }
            Spacer()
            Text(insight.date.dayOfWeek() ?? "")
                .font(.caption)
                .fontWeight(.semibold)
                .padding([.leading, .bottom],8)
        }
    }
}

struct HealthInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthInsightsView()
    }
}
