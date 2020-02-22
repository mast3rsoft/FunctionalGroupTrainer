//
//  ContentView.swift
//  FunctionalGroupTrainer
//
//  Created by Niko Neufeld on 2/22/20.
//  Copyright © 2020 Niko Neufeld. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var redAngularGradient: Gradient {
    Gradient(colors: [Color(hue: 0, saturation: 100, brightness: 100), Color(hue: 0, saturation: 100, brightness: 70), Color(hue: 0, saturation: 100, brightness: 40)])
    }
    @State var showText = true;
    var body: some View {
        VStack {
            Spacer()
            Button(action: { self.showText = !self.showText}) {
                if showText {
                    Text("Alkane").font(.largeTitle).foregroundColor(.black)
                } else {
                    Image("alkane").renderingMode(  .original)
                }
            }.gesture(DragGesture().onEnded {_ in 
                self.showText.toggle()
            })
            Spacer()
            HStack(alignment: .bottom) {
                Spacer(minLength: 100)
                Circle().foregroundColor(.red).frame(width: 100, height: 100, alignment: .center)
                Spacer(minLength: 100)
                Circle().frame(width: 100, height: 100, alignment: .center).foregroundColor(.green)
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
