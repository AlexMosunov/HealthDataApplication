//
//  HealthInsight.swift
//  HealthDataApplication
//
//  Created by User on 11.12.2023.
//

import Foundation

struct HealthInsight: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var unit: String
    var num: Int
    var subtitle: String?
    var date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HealthInsight, rhs: HealthInsight) -> Bool {
        return lhs.id == rhs.id
    }
}
