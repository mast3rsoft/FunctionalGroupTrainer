//
//  FunctionalGroupTrainerTests.swift
//  FunctionalGroupTrainerTests
//
//  Created by Niko Neufeld on 2/22/20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import XCTest
@testable import FunctionalGroupTrainer

class FunctionalGroupTrainerTests: XCTestCase {
    var trainer = Trainer()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        trainer.flashCards.removeAll()
        for group in groups {
            trainer.flashCards.append(FlashCard(group))
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNewTraining() {
        trainer.createTrainingDeck(day: 1)
        XCTAssert(trainer.trainingDeck!._storage.count == trainer.initialBatchSize)
    }
    
    func test2ndDayTraining() {
        trainer.flashCards[0].deck = 2
        trainer.flashCards[1].deck = 2
        trainer.flashCards[2].deck = 1
        trainer.flashCards[3].deck = 4
        trainer.flashCards[4].deck = 4
        for i in 5..<trainer.flashCards.count {
            trainer.flashCards[i].deck = trainer.finalDeck
        }
        trainer.createTrainingDeck(day: 2)
        XCTAssert(trainer.trainingDeck!._storage.count == 3)
    }
    
    func testTrainingTwoRoundsOnTwoDays() {
        trainer.eraseEverything()
        trainer.newTraining()
        for card in trainer.trainingDeck! {
            card.known = true
            card.knownAtFirstGuess = false
        }
        trainer.trainingDeck!._storage[2].knownAtFirstGuess = true
        trainer.trainingDeck!._storage[10].knownAtFirstGuess = true
        trainer.stopTraining()
        trainer.resumeTraining(Date() + 86400)
        XCTAssert(trainer.trainingDeck!._storage.count == 12
        )
        for card in trainer.trainingDeck! {
            card.known = true
            card.knownAtFirstGuess = false
        }
        trainer.trainingDeck!._storage[2].knownAtFirstGuess = true
        trainer.trainingDeck!._storage[10].knownAtFirstGuess = true
        trainer.trainingDeck!._storage[1].knownAtFirstGuess = true
        trainer.trainingDeck!._storage[3].knownAtFirstGuess = true
        trainer.stopTraining()
        trainer.resumeTraining(Date() + 2 * 86400)
        XCTAssert(trainer.trainingDeck!._storage.count == 10
        )

    
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
