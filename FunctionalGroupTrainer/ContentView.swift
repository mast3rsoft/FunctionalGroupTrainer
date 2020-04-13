//
//  ContentView.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 2/22/20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import SwiftUI
enum CurrentNavView: String {
    case stats
    case start
    case training
}
struct StartingScreen: View {
    @ObservedObject var viewModel = TrainerViewModel()
    var body: some View {
        NavigationView {
            VStack {
                Button("Erase all progress") {
                    self.viewModel.erase()
                }
                NavigationLink(destination: ContentView(viewModel: viewModel).onAppear() { self.viewModel.load(newTraining: true) })
                    {
                        Text("New Training")
                }
                NavigationLink(destination:
                    StatView(viewModel: viewModel),
                                   tag: .stats,
                                   selection: $viewModel.currentView)
                {
                                   EmptyView()
                }
                NavigationLink(destination: ContentView(viewModel: viewModel).onAppear() {
                    self.viewModel.load(newTraining: false)})
                    {
                        Text("Continue Training")
                }.disabled(!viewModel.trainer.isResumable)
            }.navigationBarTitle("FT Trainer")
        }
    }
    
}

struct ContentView: View {
    @State var currentNavView: CurrentNavView? = nil
    @ObservedObject var viewModel: TrainerViewModel {
        didSet {
            currentNavView = viewModel.currentView
        }
    }
    @State var isNew: Bool = false
    @State var index = 1
    static let redColors = Gradient(colors: [Color(hue: 0, saturation: 100, brightness: 100), Color(hue: 0, saturation: 10, brightness: 70), Color(hue: 40, saturation: 100, brightness: 40)])
    let redAngularGradient = RadialGradient(gradient: redColors, center: .center, startRadius: 0.0, endRadius: 100.0)
    @State var showText = true
    @State var score = 0
    @State var numQuestions = 0
    
    func advance(correct: Bool) {
        viewModel.answered(correct)
        viewModel.next()
        if viewModel.trainingIsOver {
            return
        }
        if Int.random(in: 0...5) > 2 {
            self.showText.toggle()
        }
    }
    var body: some View {

            VStack {
                HStack {
                    Spacer()
                    Text("\(viewModel.identifiedCards)/\(viewModel.totalCards)").font(.title)
                    Spacer()
                }
                Spacer()
                Button(action: { self.showText = !self.showText}) {
                    if showText {
                        viewModel.nameForCard().font(.largeTitle).foregroundColor(.black)
                    } else {
                        viewModel.imageForCard().renderingMode(  .original)
                    }
                }.gesture(DragGesture().onEnded {_ in
                    self.showText.toggle()
                })
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer(minLength: 100)
                    Circle().foregroundColor(.green).frame(width: 100, height: 100, alignment: .center).onTapGesture {
                        self.advance(correct: true)
                    }
                    Spacer(minLength: 100)
                    Circle().fill(self.redAngularGradient).frame(width: 100, height: 100, alignment: .center).onTapGesture {
                        self.advance(correct: false)
                    }
                    Spacer(minLength: 100)
                }
                NavigationLink(destination: StatView(viewModel: self.viewModel), tag: .stats, selection: $currentNavView) {
                    EmptyView()
            }
        }
    }
}

struct StatView: View {
    @ObservedObject var viewModel: TrainerViewModel
    var body: some View {
        VStack {
            Text("Number of attempts: \(viewModel.attempts)")
            Text("Correct at first sight: \(viewModel.knownAtFirstCards)")
            Text("Learned cards: \(viewModel.learnedCards)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("hello world")
    }
}

extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(simpleDouble: Double) {
        let format = NumberFormatter()
        format.maximumFractionDigits = 2
        format.maximumIntegerDigits = 3
        let result = format.string(from: NSNumber(floatLiteral: simpleDouble))
        appendLiteral(result!)
    }
}
