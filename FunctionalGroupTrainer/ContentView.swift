//
//  ContentView.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 2/22/20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import SwiftUI

let groups = ["Alkane", "Alkene", "Alkyne", "Arene", "Haloalkane", "Alcohol", "Aldehyde", "Ketone", "Carboxylic Acid", "Acid Anhydride","Acid Halide", "Amide", "Amine", "Epoxide", "Ester", "Ether", "Nitrate", "Nitrile", "Nitrite", "Nitro"]

struct ContentView: View {
    @State var index = 1
    @State var sequence = Array(0..<groups.count).shuffled()
    var redAngularGradient: Gradient {
    Gradient(colors: [Color(hue: 0, saturation: 100, brightness: 100), Color(hue: 0, saturation: 100, brightness: 70), Color(hue: 0, saturation: 100, brightness: 40)])
    }
    @State var showText = true;
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
                    Text(groups[sequence[index]]).font(.largeTitle).foregroundColor(.black)
                } else {
                    Image(groups[sequence[index]]).renderingMode(  .original)
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
                Circle().frame(width: 100, height: 100, alignment: .center).foregroundColor(.red).onTapGesture {
                    self.advance(increment: 0)
                }
                Spacer(minLength: 100)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(simpleDouble: Double) {
        var format = NumberFormatter()
        format.maximumFractionDigits = 2
        format.maximumIntegerDigits = 3
        let result = format.string(from: NSNumber(floatLiteral: simpleDouble))
        appendLiteral(result!)
    }
}
