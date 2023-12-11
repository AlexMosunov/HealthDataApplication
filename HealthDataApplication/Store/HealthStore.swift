//
//  HealthStore.swift
//  HealthDataApplication
//
//  Created by User on 08.12.2023.
//

import Foundation
import HealthKit

enum HealthKitError: Error {
    case healthDataNotAvailable
}

class HealthStore: ObservableObject {
    var healthStore: HKHealthStore?
    var lastError: Error?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            lastError = HealthKitError.healthDataNotAvailable
        }
    }
    
    private static var allHealthDataTypes: [HKSampleType] {
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue,
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
            HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue,
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
            HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
//            HKQuantityTypeIdentifier.appleExerciseTime.rawValue,
            HKCategoryTypeIdentifier.sleepAnalysis.rawValue
        ]
        
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }

    private static var stepsCountSample : HKObjectType {
        getSampleType(for: HKQuantityTypeIdentifier.stepCount.rawValue)!
    }
    
    var isAuthorised: Bool {
        let auth = healthStore?.authorizationStatus(for: HealthStore.stepsCountSample)
        print("auth - \(auth?.rawValue)")
        print("sharingAuthorized - \(auth == .sharingAuthorized)")
        print("notDetermined - \(auth == .notDetermined)")
        print("sharingDenied - \(auth == .sharingDenied)")
        return auth == .sharingAuthorized
    }
    
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            lastError = HealthKitError.healthDataNotAvailable
            return false
        }
        print(1)
        guard let healthStore else {
            print(2)
            lastError = HealthKitError.healthDataNotAvailable
            throw HealthKitError.healthDataNotAvailable
        }
        
        do {
            print(3)
            let ress = try await healthStore.requestAuthorization(toShare: Set(HealthStore.allHealthDataTypes), read: Set(HealthStore.allHealthDataTypes))
            print("ress = \(ress)")
            print(4)
            return true
        } catch {
            print(5)
            print(error)
            lastError = error
            return false
        }
        
    }
}


func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    
    return nil
}
