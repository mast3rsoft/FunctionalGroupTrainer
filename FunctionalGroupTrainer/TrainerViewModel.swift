//
//  TrainerViewModel.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 05.04.20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class TrainerViewModel: ObservableObject {
    @Published var currentView: CurrentNavView?
    var attempts = -1 // because each next() increments, and next() is called at the beginning of training unconditionally
    var remainingCards: Int {
        if let iter = trainingDeckIterator {
            return iter._storage.filter {!$0.known}.count
        } else {
            return 0
        }
    }
    var identifiedCards: Int {
        if let iter = trainingDeckIterator {
            return iter._storage.filter {$0.known}.count
        } else  {
            return 0
        }
    }
    var totalCards: Int {
        if let iter = trainingDeckIterator {
            return iter._storage.count
        } else {
            return 0
        }
    }
    var knownAtFirstCards: Int {
        if let iter = trainingDeckIterator {
            return iter._storage.filter {$0.knownAtFirstGuess}.count
        } else {
            return 0
        }
    }
    var learnedCards: Int {
        return trainer.flashCards.filter({card in card.deck == trainer.finalDeck}).count
    }
    var isResumable: Bool {
        objectWillChange.send()
       return trainer.isResumable
        
    }
    var trainingIsOver = false {
        didSet {
            if trainingIsOver {
                currentView = .stats
                objectWillChange.send()
            }
        }
    }
    var count = 0
    var objectWillChange = PassthroughSubject<Void,Never>()
    var currentCard =  FlashCard(){
        didSet {
            objectWillChange.send()
        }
    }
    init() {
        print("Not doing anythning")
    }
    func load(newTraining: Bool) {
        if newTraining {
            print("New training")
            self.newTraining()
        } else {
            print("Continue training")
            self.resumeTraining()
        }
    }
    var trainer = Trainer() {
        didSet {
            objectWillChange.send()
        }
    }
    var trainingDeckIterator: TrainingDeck.Iterator?
    // TODO: Add images
    func imageForCard() -> Image {
        Image(currentCard.name)
    }
    func nameForCard() -> Text {
        Text(currentCard.name)
    }
    func answered(_ correct: Bool) {
        currentCard.answered(correct)
    }
    func stop() {
        trainer.stopTraining()
    }
    func erase() {
        trainer.eraseEverything()
    }
    func next() {
        if let card = trainingDeckIterator?.next() {
            currentCard = card
        } else {
            // we are done - show summary screen
            stop()
            
            trainingIsOver = true
            currentView = .stats
        }
        attempts += 1
        objectWillChange.send()
    }
    func newTraining() {
        trainer.newTraining()
        trainingIsOver = false
        trainingDeckIterator = trainer.trainingDeck?.makeIterator()
        attempts = -1
        next()
    }
    func resumeTraining() {
        trainer.resumeTraining()
        trainingIsOver = false
        trainingDeckIterator = trainer.trainingDeck?.makeIterator()
        attempts = -1
        next()
    }
}
