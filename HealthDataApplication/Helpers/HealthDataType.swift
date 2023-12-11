//
//  HealthDataType.swift
//  HealthDataApplication
//
//  Created by User on 11.12.2023.
//

import Foundation
enum HealthDataType: String {
    case stepCount = "HKQuantityTypeIdentifierStepCount"
    case distanceWalkingRunning = "HKQuantityTypeIdentifierDistanceWalkingRunning"
    case sixMinuteWalkTestDistance = "HKQuantityTypeIdentifierSixMinuteWalkTestDistance"
    case activeEnergyBurned = "HKQuantityTypeIdentifierActiveEnergyBurned"
    case appleExerciseTime = "HKQuantityTypeIdentifierAppleExerciseTime"
    case sleepAnalysis = "HKCategoryTypeIdentifierSleepAnalysis"
    case appleStandTime = "HKQuantityTypeIdentifierAppleStandTime"
    
    static let typeIdentifiers: [String] = [
        stepCount.rawValue,
        distanceWalkingRunning.rawValue,
        sixMinuteWalkTestDistance.rawValue,
        activeEnergyBurned.rawValue,
        appleExerciseTime.rawValue,
        sleepAnalysis.rawValue,
        appleStandTime.rawValue
    ]
    
    // Create a dictionary to map raw values to descriptive titles
    static let typeTitles: [String: String] = [
        stepCount.rawValue: "Steps count",
        distanceWalkingRunning.rawValue: "Distance Walking/Running",
        sixMinuteWalkTestDistance.rawValue: "Six Minute Walk Test Distance",
        activeEnergyBurned.rawValue: "Active Energy Burned",
        appleExerciseTime.rawValue: "Apple Exercise Time",
        sleepAnalysis.rawValue: "Sleep Analysis",
        appleStandTime.rawValue: "Apple Stand Time"
    ]
}
