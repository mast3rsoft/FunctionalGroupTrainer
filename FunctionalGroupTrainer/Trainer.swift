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
            let item = _storage[count]
            count += 1
            return item
        }
    }
}

struct FlashCard: Equatable {
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
    mutating func answered(_ correct: Bool) {
        if (correct) {
            known = true
        } else {
            known = false
            knownAtFirstGuess = false
        }
    }
}

struct Trainer {
    let finalDeck = 10
    var flashCards = [FlashCard]()
    var deck = [FlashCard]()
    let today = Date()
    var trainingStart = Date()
    var trainingDay = 1
    var trainingDeck: TrainingDeck?
    var initialBatchSize = 12
    var lastTraining = Date()
    var db = try! Realm()
    let calendar = Calendar.current
    mutating func resumeTraining() {
        // get data from Realm
        let realm = try! Realm()
        flashCards = realm.objects(Card.self).map(FlashCard.db2card)
        guard let dbTrainingDay = db.objects(UserDates.self).first else { fatalError("No date object in db")}
        lastTraining = dbTrainingDay.lastTraining
        trainingStart = dbTrainingDay.trainingStart
        // calculate day of training
       trainingDay = calendar.dateComponents([.day], from: trainingStart, to: today).day! + 1
        for card in flashCards {
            if (trainingDay % card.deck == 0) {
                deck.append(card)
            }
        }
        if deck.count < initialBatchSize {
            var i = initialBatchSize - deck.count
            for card in flashCards {
                if card.deck == 0 {
                    deck.append(card)
                    i -= 1
                    if i == 0 {
                        break
                    }
                }
            }
        }
        trainingDeck = TrainingDeck(deck)
    }
    mutating func newTraining() {
        for var card in flashCards {
            card.deck = 0
        }
        trainingStart = Date() // today
        trainingDay = 1
        // select cards to start training
        let firstBatch = Array(0..<flashCards.count).shuffled()
        for i in firstBatch {
            flashCards[i].deck = 1
            deck.append(flashCards[i])
        }
        trainingDeck = TrainingDeck(deck)
    }
    func stop(_ trainingDeck: TrainingDeck) {
        let realm = try! Realm()
        realm.add(trainingDeck._storage.map(FlashCard.card2db), update: .all)
        realm.add(UserDates(training: trainingStart, lastTrain: today), update: .all)
    }
    mutating func updateScore() {
        for var card in flashCards {
            if (card.knownAtFirstGuess) {
                card.deck += 1
            } else {
                card.deck = 1
            }
        }
    }
}




