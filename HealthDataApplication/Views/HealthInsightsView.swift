//
//  HealthInsightsView.swift
//  HealthDataApplication
//
//  Created by User on 09.12.2023.
//

import SwiftUI

import SwiftUI

// Model representing a health insight
struct HealthInsight {
    var title: String
    var number: String
    var subtitle: String
}

struct MainView: View {
    @EnvironmentObject var manager: HealthStore
    var body: some View {
        if manager.isAuthorised {
            HealthInsightsView()
        } else {
            ContentView()
        }
    }
}

struct HealthInsightsView: View {
    let healthInsights: [HealthInsight] = [
        HealthInsight(title: "My Steps", number: "10,000", subtitle: "Steps"),
        HealthInsight(title: "Distance", number: "5.2", subtitle: "Kilometers"),
        HealthInsight(title: "Time in Bed", number: "7", subtitle: "Hours"),
        HealthInsight(title: "Calories Burned", number: "350", subtitle: "Calories"),
        HealthInsight(title: "Total Activity", number: "2", subtitle: "Hours")
    ]
    
    var body: some View {
        NavigationView {
            List(healthInsights, id: \.title) { insight in
                VStack{
                    Spacer()
                    NavigationLink(destination: HealthInsightDetailScreen(insight: insight)) {
                        HealthInsightCell(insight: insight)
                        
                    }
                    Spacer()
                }
                .frame(height: 120)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
  
            }
            .navigationTitle("Health Insights")
        }
    }
}

struct HealthInsightCell: View {
    var insight: HealthInsight
    
    var body: some View {
            VStack(alignment: .leading) {
                Text(insight.title)
                    .padding(.leading, 8)
                    .font(.headline)
                
                VStack(alignment: .center) {
                    Text(insight.number)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)

                    
                    Text(insight.subtitle)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                
            }
    }
}

struct RoundedCornersShapeView: View {
    var body: some View {
        RoundedCornersShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 20)
            .fill(Color.yellow)
            .frame(height: 100, alignment: .bottomTrailing)
            .padding(10)
    }
}

struct RoundedCornersShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }

    let corners: UIRectCorner
    let radius: CGFloat
}


struct HealthInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthInsightsView()
    }
}
