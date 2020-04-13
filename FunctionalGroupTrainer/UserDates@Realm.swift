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
    init(training: Date, lastTrainingDate: Date) {
        trainingStart = training
        lastTraining = lastTrainingDate
    }
    required init() {
    }
    override class func primaryKey() -> String? {
        "id"
    }
    @objc dynamic var id = UUID().hashValue
    @objc dynamic var trainingStart = Date()
    @objc dynamic var lastTraining = Date()
}
