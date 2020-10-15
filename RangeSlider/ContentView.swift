//
//  ContentView.swift
//  RangeSlider
//
//  Created by Frenetic Studios on 7/2/20.
//  Copyright © 2020 Frenetic Studios. All rights reserved.
//

import SwiftUI

enum Month: Float, Comparable {
    typealias RawValue = Float
        
    case January  = 1
    case February
    case March
    case April
    case May
    case June
    case July
    case August
    case September
    case October
    case November
    case December
    
    func toString() -> String {
        return String(describing:self)
    }
    
    static func < (lhs: Month, rhs: Month) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static var allValues: [Month] =
        [
            .January,
            .February,
            .March,
            .April,
            .May,
            .June,
            .July,
            .August,
            .September,
            .October,
            .November,
            .December
        ]
}

struct ContentView: View {
        
    @State private var sliderVal: Float = 34
    @State private var sliderVal2: Float = 3

    @State private var yearRange: ClosedRange<Float> = 1975...2015
    @State private var valueRange: ClosedRange<Float> = 4...12
    @State private var floatRange: ClosedRange<Float> = 41...80
    @State private var floatRange2: ClosedRange<Float> = 8...15
    @State private var monthRange: ClosedRange<Float> = 2...8

    var body: some View {
        VStack {
            Text("Default SwiftUI Slider")
                .padding()
            Slider(value: self.$sliderVal,
                   in: 1...100)
                .padding()
            Slider(value: self.$sliderVal2,
                   in: 0...10,
                   step: 1,
                   onEditingChanged:{ value in },
                   minimumValueLabel: Text("0"),
                   maximumValueLabel: Text("10"),
                   label: { Text("Label") } )
                .padding()
            Divider()
            Text("RangeSlider Examples")
                .padding()
            RangeSlider(
                self.$yearRange,
                limits: 1965...2040,
                step: 5,
                onValueChanged: { (bound, value) in
                    print ("value changed: \(String(describing: value))")
                })
                .padding()
                .background(Color.red.opacity(0.1))
            RangeSlider(
                self.$valueRange,
                limits: 0...100,
                step: 2,
                onValueChanged: { (bound, value) in
                    print ("value changed: \(String(describing: value))")
                })
                .padding()
                .background(Color.green.opacity(0.1))
            RangeSlider(
                self.$floatRange,
                limits: 10...105,
                step: 2.5,
                precision: 2,
                onValueChanged: { (bound, value) in
                    print ("value changed: \(String(describing: value))")
                })
                .padding()
                .background(Color.blue.opacity(0.1))
            RangeSlider(
                self.$monthRange,
                limits: 1...12,
                step: 1,
                onValueChanged: { (bound, value) in
                    print ("value changed: \(String(describing: value))")
                },
                describeValue: { value in
                    for m in Month.allValues {
                        if m.rawValue == value {
                            return m.toString()
                        }
                    }
                    return ""
                })
                .padding()
                .background(Color.purple.opacity(0.1))
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
