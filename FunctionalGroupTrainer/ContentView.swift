//
//  ContentView.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 2/22/20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import SwiftUI

struct StartingScreen: View {
    let viewModel = TrainerViewModel()
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ContentView(viewModel: viewModel).onAppear() { self.viewModel.load(newTraining: true) })
                    {
                        Text("New Training")
                    }
                NavigationLink(destination: ContentView(viewModel: viewModel).onAppear() {
                    self.viewModel.load(newTraining: false)})
                    {
                    Text("Continue Training")
                }
            }.navigationBarTitle("FT Trainer")
        }
    }
    
}
let groups1 = ["Alkane", "Alkene", "Alkyne", "Arene", "Haloalkane", "Alcohol", "Aldehyde", "Ketone", "Carboxylic Acid", "Acid Anhydride","Acid Halide", "Amide", "Amine", "Epoxide", "Ester", "Ether", "Nitrate", "Nitrile", "Nitrite", "Nitro", "Nitroso", "Imine", "Imide", "Azide", "Cyanate", "Isocyanate", "Azo Compound", "Thiol", "Sulfide", "Disulfide", "Sulfoxide", "Sulfone", "Sulfinic Acid", "Sulfonate Ester", "Thiocyanate", "Isothiocyanate", "Thial", "Thioketone", "Phosphine"]
struct ContentView: View {
    @ObservedObject var viewModel: TrainerViewModel
    @State var isNew: Bool = false
    @State var index = 1
    @State var sequence = Array(0..<groups1.count).shuffled()
    static let redColors = Gradient(colors: [Color(hue: 0, saturation: 100, brightness: 100), Color(hue: 0, saturation: 10, brightness: 70), Color(hue: 40, saturation: 100, brightness: 40)])
    let redAngularGradient = RadialGradient(gradient: redColors, center: .center, startRadius: 0.0, endRadius: 100.0)
    @State var showText = true
    @State var score = 0
    @State var numQuestions = 0
    var percentage: Double {
        get {
            if numQuestions == 0 {
                return 0.0
            } else {
                return 100 * Double(score) / Double(numQuestions)
            }
        }
    }
    func advance(increment: Int) {
        self.score = self.score + increment
        if self.score < 0 {
            self.score = 0
        }
        self.numQuestions += 1
        self.index += 1
        if self.index == groups.count {
            self.index = 0
        }
        if Int.random(in: 0...5) > 2 {
            self.showText.toggle()
        }
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Correct: \(simpleDouble: self.percentage)%").font(.title)
                Spacer()
            }
            Spacer()
            Button(action: { self.showText = !self.showText}) {
                if showText {
                    Text(groups1[sequence[index]]).font(.largeTitle).foregroundColor(.black)
                } else {
                    Image(groups1[sequence[index]]).renderingMode(  .original)
                }
            }.gesture(DragGesture().onEnded {_ in 
                self.showText.toggle()
            })
            Spacer()
            HStack(alignment: .bottom) {
                Spacer(minLength: 100)
                Circle().foregroundColor(.green).frame(width: 100, height: 100, alignment: .center).onTapGesture {
                    self.advance(increment: 1)
                }
                Spacer(minLength: 100)
                Circle().fill(self.redAngularGradient).frame(width: 100, height: 100, alignment: .center).onTapGesture {
                    self.advance(increment: 0)
                }
                Spacer(minLength: 100)
            }
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
