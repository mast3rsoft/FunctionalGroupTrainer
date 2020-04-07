//
//  UserDates@Realm.swift
//  FGTrainer WatchKit Extension
//
//  Created by Niko Neufeld on 30.03.20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import Foundation
import RealmSwift
class UserDates: Object {
    init(training: Date, lastTrain: Date) {
        trainingStart = training
        lastTraining = lastTrain
    }
    
     required init() {
    }
    dynamic var trainingStart = Date()
    dynamic var lastTraining = Date()
}
