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
    var trainingIsOver = false
    var count = 0
    var objectWillChange = PassthroughSubject<Void,Never>()
    var currentCard =  FlashCard(deck: 99, name: "?????????", knownAtFirstGuess: false, known: false){
        didSet {
            objectWillChange.send()
        }
    }
    var trainer = Trainer() {
        didSet {
            objectWillChange.send()
        }
    }
    var trainingDeckIterator: TrainingDeck.Iterator? = nil
    // TODO: Add images
    func imageForCard() -> Image {
        Image(currentCard.name)
    }
    func nameForCard() -> Text {
        Text(currentCard.name)
    }
    func next() {
        if let card  = trainingDeckIterator!.next() {
            currentCard = card
        } else {
            // we are done - show summary screen
            trainingIsOver = true
        }
        objectWillChange.send()
    }
    func newTraining() {
        trainer.newTraining()
        trainingDeckIterator = trainer.trainingDeck!.makeIterator()
        currentCard = trainingDeckIterator!.next()!
        trainingIsOver = false
    }
    func resumeTraining() {
        trainer.resumeTraining()
        trainingDeckIterator = trainer.trainingDeck!.makeIterator()
        currentCard = trainingDeckIterator!.next()!
        trainingIsOver = false
    }
}
