//
//  ContentView.swift
//  Wasserpumpe WatchKit Extension
//
//  Created by Simon Schulte on 02.07.20.
//  Copyright © 2020 Simon Schulte. All rights reserved.
//

import SwiftUI

enum PUMP_STATES {
    case on
    case off
}

let PUMP_STATE_TEXT = [
    PUMP_STATES.on: "Stoppen",
    PUMP_STATES.off: "Bewässern"
]

struct ContentView: View {
    @State var scrollAmount = 0.0
    @State var buttonText = PUMP_STATE_TEXT[PUMP_STATES.off]!
    @State var currentPumpState = ""
    @State var pumpState = PUMP_STATES.off
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Water Pump 💦")
                .font(.callout)
                .foregroundColor(Color.blue)
                .multilineTextAlignment(.center)
                .lineLimit(0)
                .padding()
            Text(currentPumpState).font(.footnote)
            
            if (pumpState == PUMP_STATES.off) {
                Text("\(Int(scrollAmount * 10)) Minuten")
                Slider(value: $scrollAmount)
                    .digitalCrownRotation($scrollAmount,
                                          from: 1,
                                          through: 10,
                                          by: 1,
                                          sensitivity: .low,
                                          isHapticFeedbackEnabled: true)
            }

            Button(action: {
                if(self.pumpState == PUMP_STATES.off && self.scrollAmount > 0){
                    self.currentPumpState = water(waterTime: self.scrollAmount*10)
                    self.pumpState = PUMP_STATES.on
                    self.buttonText = PUMP_STATE_TEXT[PUMP_STATES.on]!
                } else {
                    self.currentPumpState = water(waterTime: 0.0)
                    self.pumpState = PUMP_STATES.off
                    self.buttonText = PUMP_STATE_TEXT[PUMP_STATES.off]!
                }
            }) {
                Text(buttonText)
            }
        }
    }
}

func water(waterTime:Double) -> String{
    let getURL = URL(string: "http://raspberrypi:5000/pump?waterTime=" + String(Int(waterTime)))!
    let semaphore = DispatchSemaphore(value: 0)
    var result: String = ""
    let getRequest = URLRequest(url: getURL)
    let task = URLSession.shared.dataTask(with: getRequest as URLRequest) { (data: Data?, _, _) in
            result = String(data: data!, encoding: String.Encoding.utf8)!
            result = String(result.split(whereSeparator: \.isNewline)[0])
            semaphore.signal()
        }
    task.resume()
    semaphore.wait()
    return result
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
    }
}
