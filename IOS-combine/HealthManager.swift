//
//  HealthManager.swift
//  IOS-combine
//
//  Created by usama farooq on 02/03/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import Foundation
import WatchConnectivity
import HealthKit

enum HealthTypePermission {
    case stepCount
    case heartRate
    case oxygenSaturation
}




class HealthManager: NSObject {
    var wcSession: WCSession
    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
     init(wcSession: WCSession = .default) {
         self.wcSession = wcSession
        super.init()
         wcSession.delegate = self
         wcSession.activate()
        getHealthKit()
    }
}

extension HealthManager {
    func getHealthKit(permission: HealthTypePermission = .stepCount) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
            // Handle error.
            print(success ? "success" : "failed")
        }
    }
    
    public func getOxygenLevel(completion: @escaping (Double?, Error?) -> Void) {

        guard let oxygenQuantityType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            fatalError("*** Unable to get oxygen saturation on this device ***")
        }

        HKHealthStore().requestAuthorization(toShare: nil, read: [oxygenQuantityType]) { (success, error) in

            guard error == nil, success == true else {
                completion(nil, error)
                return
            }

            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
            let query = HKStatisticsQuery(quantityType: oxygenQuantityType,
                                          quantitySamplePredicate: predicate,
                                          options: .mostRecent) { query, result, error in

                DispatchQueue.main.async {

                    if let err = error {
                        completion(nil, err)
                    } else {
                        guard let level = result, let sum = level.mostRecentQuantity() else {
                            completion(nil, error)
                            return
                        }
                        print("Quantity : ", sum)   // It prints 97 % and I need 97 only

                        let measureUnit0 = HKUnit(from: "%")
                        let count0 = sum.doubleValue(for: measureUnit0)
                        print("Count 0 : ", count0)   // It pronts 0.97 and I need 97 only

                        let measureUnit1 = HKUnit.count().unitMultiplied(by: HKUnit.percent())
                        let count1 = sum.doubleValue(for: measureUnit1)
                        print("Count 1 : ", count1)   // It pronts 0.97 and I need 97 only

                        let measureUnit2 = HKUnit.percent()
                        let count2 = sum.doubleValue(for: measureUnit2)
                        print("Count 2 : ", count2)   // It pronts 0.97 and I need 97 only

                        let measureUnit3 = HKUnit.count()
                        let count3 = sum.doubleValue(for: measureUnit3)
                        print("Count 3 : ", count3)   // It pronts 0.97 and I need 97 only

                        completion(count0 * 100.0, nil)
                    }
                }
            }
            HKHealthStore().execute(query)
        }
    }
    
    func sendOxygenLevel() {
        getOxygenLevel {[weak self] oxygen, error in
            guard let self = self,let  oxygen = oxygen else {return}
            print(oxygen)
            //   self.sendMessage(with: "\(oxygen)")
        }
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastOxygenRate = ""
        var lastHeartRate = 0.0
        for sample in samples {
            if type == .oxygenSaturation {
                lastOxygenRate = sample.quantity.description
            }
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
        }
        
        print(lastHeartRate)
        print(lastOxygenRate)
    }
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-running query.
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            // A sample that represents a quantity, including the value and the units.
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            self.process(samples, type: quantityTypeIdentifier)
            
        }
        
        // It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // query execution
        
        healthStore.execute(query)
    }
    
    // MARK: - stepCount
    func getStepsCount(forSpecificDate:Date, completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let (start, end) = self.getWholeDate(date: forSpecificDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        self.healthStore.execute(query)
    }
    
    private func getWholeDate(date : Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }
    
}

extension HealthManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
}
