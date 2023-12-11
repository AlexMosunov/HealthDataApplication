//
//  HealthInsightDetailScreen.swift
//  HealthDataApplication
//
//  Created by User on 09.12.2023.
//

import SwiftUI

struct HealthInsightDetailScreen: View {
    var insight: HealthInsight
    
    var body: some View {
        VStack {
            Text(insight.title)
                .font(.title)
            Text("Value: \(insight.number)")
                .font(.body)
            Text("Type: \(insight.subtitle)")
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle("Detail")
    }
}
struct HealthInsightDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        HealthInsightDetailScreen(insight: HealthInsight(title: "", number: "", subtitle: ""))
    }
}
