//
//  RangeSliderTests.swift
//  RangeSliderTests
//
//  Created by Frenetic Studios on 7/2/20.
//  Copyright © 2020 Frenetic Studios. All rights reserved.
//

import XCTest
import SwiftUI

@testable import RangeSlider

class RangeSliderTests: XCTestCase {

    @State var testRange = 2.0...5.0

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {

        var body : some View {
            RangeSlider(
                self.$testRange,
                limits: 10...105,
                precision: 2,
                onValueChanged: { (bound, value) in
                    print ("value changed: \(String(describing: value))")
                })
                .padding()
                .background(Color.blue.opacity(0.1))
        }
        
    }
}
