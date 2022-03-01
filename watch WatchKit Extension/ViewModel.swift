//
//  ViewModel.swift
//  watch WatchKit Extension
//
//  Created by usama farooq on 28/02/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity

class ViewModel: NSObject, WCSessionDelegate {
    
    var session: WCSession
    let heartRateQuantity = HKUnit(from: "count/min")
    var value: Int = 0
    var ableToSend: Bool = false
    private var healthStore = HKHealthStore()
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
        autorizeHealthKit() 
    }
    
    func autorizeHealthKit() {
        
        // Used to define the identifiers that create quantity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        // Requests permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { success, error in
            if success {
             //   self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
            }
            print(error)
        }
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
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // variable initialization
        var lastHeartRate = 0.0
        
        // cycle and value assignment
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            self.value = Int(lastHeartRate)
           
        }
        if ableToSend {
            session.sendMessage(["heartRate": self.value], replyHandler: nil) { error in
                print(error)
        }
            ableToSend = false
       
        }
    }
    
//    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
//        // variable initialization
//        var lastHeartRate = 0.0
//
//        // cycle and value assignment
//        for sample in samples {
//            if type == .heartRate {
//                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
//            }
//
//            self.value = Int(lastHeartRate)
//
//
    
//        }
//        session.sendMessage(["heartRate": self.value], replyHandler: nil) { error in
//            print(error)
//        }
//        print(value)
//    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        if message["message"] as! String == "get_heartrate" {
            ableToSend = true
            startHeartRateQuery(quantityTypeIdentifier: .heartRate)
        }
        
    }
}
