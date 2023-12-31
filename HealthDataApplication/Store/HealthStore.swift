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
    @Published var statisticsDictionary: [String: HealthInsight] = [:]
    @Published var averageStats: [String: HealthInsight] = [:]
    var healthStore: HKHealthStore?
    var lastError: Error?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            lastError = HealthKitError.healthDataNotAvailable
        }
    }
    
    static let typeIdentifiers: [String] = [
        HKQuantityTypeIdentifier.stepCount.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
        HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
        HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
        HKCategoryTypeIdentifier.sleepAnalysis.rawValue,
    ]
    
    private static var allHealthDataTypes: [HKSampleType] {
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }
    
    private static var stepsCountSample : HKObjectType {
        getSampleType(for: HKQuantityTypeIdentifier.stepCount.rawValue)!
    }
    
    var isAuthorised: Bool {
        let auth = healthStore?.authorizationStatus(for: HealthStore.stepsCountSample)
        return auth == .sharingAuthorized
    }
    
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            lastError = HealthKitError.healthDataNotAvailable
            return false
        }
        print(1)
        guard let healthStore = healthStore else {
            print(2)
            lastError = HealthKitError.healthDataNotAvailable
            throw HealthKitError.healthDataNotAvailable
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: Set(HealthStore.allHealthDataTypes), read: Set(HealthStore.allHealthDataTypes))
            return true
        } catch {
            print(error)
            lastError = error
            return false
        }
    }
    
    func getSortedObjectsWithSameTitle(title: String) -> [HealthInsight] {
        let objectsWithSameTitle = statisticsDictionary.values.filter { $0.title == title }
        let uniqueObjects = Array(Set(objectsWithSameTitle))
        let sortedObjects = uniqueObjects.sorted(by: { $0.date < $1.date })
        return sortedObjects
    }
    
    func calculateStatistics() async throws {
        guard let healthStore = self.healthStore else { return }
        guard statisticsDictionary.isEmpty else { return }
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.date(byAdding: .month, value: -6, to: Date())
        let endDate = Date()
        
        let everyDay = DateComponents(day:1)
        let thisWeek = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let types: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .distanceWalkingRunning,
            .activeEnergyBurned
        ]
        
        let categoryTypes: [HKCategoryTypeIdentifier] = [
            .sleepAnalysis
        ]

        for type in  types {
            guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
                continue
            }
            let predicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: thisWeek)
            
            let statisticsDescriptior = HKStatisticsCollectionQueryDescriptor(
                predicate: predicate, options: .cumulativeSum,
                anchorDate: endDate, intervalComponents: everyDay
            )
            let result = try await statisticsDescriptior.result(for: healthStore)
            
            guard let startDate = startDate else { return }
            
            result.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                let statisticsQuantity = getStatisticsQuantity(for: statistics, with: .cumulativeSum)

                if let unit = preferredUnit(for: type.rawValue),
                   let value = statisticsQuantity?.doubleValue(for: unit) {
                    let insight = HealthInsight(
                        title: HealthDataType.typeTitles[type.rawValue] ?? type.rawValue,
                        unit: unit.unitString, num: Int(value), date: statistics.startDate, currentDay: statistics.startDate.formattedCurrentDate(), currentMonth:  statistics.startDate.monthYearFormatted()
                    )
                    DispatchQueue.main.async {
                        self.statisticsDictionary["\(insight.title) \(insight.date)"] = insight
                    }
                    
                }
            }
        }
        
        for categoryType in categoryTypes {
            guard let sleepType = HKObjectType.categoryType(forIdentifier: categoryType) else {
                continue
            }
            
            // we create a predicate to filter our data
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            // I had a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, result, error) in
                if error != nil {
                    return
                }
                
                if let result = result {
                    result
                        .compactMap({ $0 as? HKCategorySample })
                        .forEach({ sample in
                            guard let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value) else {
                                return
                            }
                            let timeInterval = sample.endDate.timeIntervalSince(sample.startDate)
                            let hours = Int(timeInterval) / 3600
                            let minutes = Int(timeInterval) / 60 % 60
                            let insight = HealthInsight(
                                title: HealthDataType.typeTitles[categoryType.rawValue] ?? categoryType.rawValue,
                                unit: "daily sleep time", num: hours,
                                subtitle: "\(hours)hr \(minutes)min", date: sample.startDate, currentDay: sample.startDate.formattedCurrentDate(), currentMonth: sample.startDate.monthYearFormatted()
                            )
                            DispatchQueue.main.async {
                                self.statisticsDictionary["\(insight.title) \(insight.date)"] = insight
                            }
                        })
                }
            }
            
            // finally, we execute our query
            healthStore.execute(query)
            
        }
        
        let average = calculateAverageNum(for: statisticsDictionary)
        print("AVERAGE")
        print(average)
        DispatchQueue.main.async {
            self.averageStats = average
        }

    }
    
    func calculateAverageNum(for insightsDictionary: [String: HealthInsight]) -> [String: HealthInsight] {
        var averageInsights: [String: HealthInsight] = [:]
        var sumValues: [String: Int] = [:]
        var countValues: [String: Int] = [:]
        // Calculate total sum and count for each title
        for (_, insight) in insightsDictionary {
            let title = insight.title
            if sumValues[title] == nil {
                sumValues[title] = 0
                countValues[title] = 0
            }
            
            sumValues[title]! += insight.num
            countValues[title]! += 1
        }
        
        // Calculate average for each title and create updated HealthInsight objects
        for (title, sum) in sumValues {
            let count = countValues[title] ?? 1
            let average = sum / count
                let updatedInsight = HealthInsight(
                    title: "average daily \(title)",
                    unit: "",
                    num: average,
                    date: Date(),
                    currentDay: "", currentMonth: ""
                )
                averageInsights[title] = updatedInsight
        }
        
        return averageInsights
    }
    
    private func filterDictionaryByUniqueDays() {
        var filteredDictionary: [String: HealthInsight] = [:]

        for (_, insight) in statisticsDictionary {
            let key = "\(insight.title) \(insight.date)"
            if let value = filteredDictionary[key] {
                if value.currentDay == insight.currentDay && value.title == insight.title {
                    filteredDictionary[key] = nil
                } else {
                    filteredDictionary[key] = insight
                }
            }
        }
        statisticsDictionary = filteredDictionary
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
func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
    var statisticsQuantity: HKQuantity?
    
    switch statisticsOptions {
    case .cumulativeSum:
        statisticsQuantity = statistics.sumQuantity()
    case .discreteAverage:
        statisticsQuantity = statistics.averageQuantity()
    default:
        break
    }
    
    return statisticsQuantity
}

func preferredUnit(for sampleIdentifier: String) -> HKUnit? {
    return preferredUnit(for: sampleIdentifier, sampleType: nil)
}

private func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
    var unit: HKUnit?
    let sampleType = sampleType ?? getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .stepCount:
            unit = .count()
        case .distanceWalkingRunning, .sixMinuteWalkTestDistance:
            unit = .meter()
        case .activeEnergyBurned:
            unit = .kilocalorie()
        case .appleExerciseTime, .appleStandTime:
            unit = .minute()
        default:
            break
        }
    }
    
    return unit
}

