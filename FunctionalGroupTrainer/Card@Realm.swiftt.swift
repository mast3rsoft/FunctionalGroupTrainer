//
//  Card@Realm.swiftt.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 30.03.20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import Foundation
import RealmSwift

class Card: Object {
    @objc dynamic var deck: Int = 1
    @objc dynamic var name: String = ""
    override class func primaryKey() -> String? {
        return "name"
    }

}
