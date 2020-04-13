//
//  Trainer.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 31.03.20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import Foundation
import RealmSwift

let groups = ["Alkane", "Alkene", "Alkyne", "Arene", "Haloalkane", "Alcohol", "Aldehyde", "Ketone", "Carboxylic Acid", "Acid Anhydride","Acid Halide", "Amide", "Amine", "Epoxide", "Ester", "Ether", "Nitrate", "Nitrile", "Nitrite", "Nitro", "Nitroso", "Imine", "Imide", "Azide", "Cyanate", "Isocyanate", "Azo Compound", "Thiol", "Sulfide", "Disulfide", "Sulfoxide", "Sulfone", "Sulfinic Acid", "Sulfonate Ester", "Thiocyanate", "Isothiocyanate", "Thial", "Thioketone", "Phosphine"]

struct TrainingDeck: Sequence {
    init(_ deck: [FlashCard]) {
        _storage = deck
    }
    __consuming func makeIterator() -> Iterator {
        return Iterator(_storage: _storage, count: 0)
    }
    var _storage = [FlashCard]()
    mutating func updateElement(element: FlashCard) {
        guard let indexOfElement = _storage.firstIndex(of: element) else {fatalError("Not found")}
        _storage[indexOfElement] = element
    }
    struct Iterator: IteratorProtocol {
        var _storage = [FlashCard]()
        typealias Element = FlashCard
        var count = 0
        mutating func next() -> FlashCard? {
            guard _storage.contains(where: {!$0.known}) else {return nil}
            while _storage[count].known {
                count += 1
                if count >= _storage.endIndex {
                    count = 0
                }
            }
            let item = _storage[count]
            count += 1
            if count >= _storage.endIndex {
                count = 0
            }
            return item
        }
    }
}

class FlashCard: Equatable {
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.name == rhs.name
    }
    init(_ name: String) {
        self.name = name
    }
    init() {}
    
    var deck = 0
    var name: String = "????????????????"
    var knownAtFirstGuess = true
    var known = false
    static func db2card(_ card: Card) -> FlashCard {
        var `self` = FlashCard()
        self.deck = card.deck
        self.name = card.name
        return self
    }
    static func card2db(_ fcard: FlashCard)-> Card {
        let `self` = Card()
        self.deck = fcard.deck
        self.name = fcard.name
        return self
    }
    static func load(_ name: String) -> FlashCard {
        let realm = try! Realm()
        return FlashCard.db2card(realm.object(ofType: Card.self, forPrimaryKey: name)!)
    }
    func answered(_ correct: Bool) {
        if (correct) {
            known = true
        } else {
            known = false
            knownAtFirstGuess = false
        }
    }
}

struct Trainer {
    var isResumable: Bool {
        if db.isEmpty {
           return false
        }
        if flashCards.filter({ card in
            card.deck > 0 && card.deck < finalDeck && trainingDay % card.deck == 0
        }).count > 0 {
            return true
        }
        return false
    }
    let finalDeck = 10
    var flashCards = [FlashCard]()
    var trainingStart = Date()
    var trainingDay = 1
    var trainingDeck: TrainingDeck?
    var initialBatchSize = 12
    var lastTraining = Date()
    var db = try! Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    let calendar = Calendar.current
    
    init() {
        if db.isEmpty {
            return
        }
        getDataAndDay(Date())
    }
    mutating func getDataAndDay(_ date: Date) {
        flashCards = db.objects(Card.self).map(FlashCard.db2card)
        guard let dbTrainingDay = db.objects(UserDates.self).first else { fatalError("No date object in db")}
        lastTraining = dbTrainingDay.lastTraining
        trainingStart = dbTrainingDay.trainingStart
        // calculate day of training
        trainingDay = calendar.dateComponents([.day], from: trainingStart, to: date).day! + 1
    }
    mutating func eraseEverything() {
        flashCards.removeAll()
        trainingDeck?._storage.removeAll()
        try! db.write {
            db.deleteAll()
        }
    }
    mutating func resumeTraining () {
        let today = Date()
        resumeTraining(today)
    }
    mutating func resumeTraining(_ date: Date) {
        // get data from Realm
        getDataAndDay(date)
        createTrainingDeck(day: trainingDay)
    }
    mutating func createTrainingDeck(day: Int) {
        var deck = [FlashCard]()
        for card in flashCards {
            if card.deck == finalDeck || card.deck == 0 {
                continue
            }
            if (day % card.deck == 0) {
                deck.append(card)
            }
        }
        var i = flashCards.makeIterator()
        while (flashCards.filter({$0.deck > 0 && $0.deck < finalDeck}).count < initialBatchSize) {
            if let card = i.next() {
                if card.deck == 0 {
                    card.deck = 1
                    deck.append(card)
                } else {
                    break
                }
            }
        }
        trainingDeck = TrainingDeck(deck)
    }
    mutating func newTraining() {
        try! db.write {
            db.delete(db.objects(UserDates.self))
        }
        flashCards.removeAll()
        for group in groups {
            flashCards.append(FlashCard(group))
        }
        trainingStart = Date() // today
        trainingDay = 1
        flashCards.shuffle()
        createTrainingDeck(day: trainingDay)
    }
    mutating func stopTraining() {
        print("Stopping Training")
        updateScore()
        let today = Date()
        try! db.write {
        db.add(flashCards.map(FlashCard.card2db), update: .all)
            db.add(UserDates(training: trainingStart, lastTrainingDate: today), update: .all)
        }
    }
    mutating func updateScore() {
        for card in trainingDeck!._storage {
            if (card.knownAtFirstGuess) {
                card.deck += 1
            } else {
                card.deck = 1
            }
        }
    }
}




