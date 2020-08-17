//
//  RangeSlider.swift
//  RangeSlider
//
//  LICENSE: MIT (see below)
//
//  TODO: change some ivars to modifiers?
//
//  Created by Frenetic Studios on 8/16/20.
//  Copyright © 2020 Frenetic Studios. All rights reserved.
//

/**
 
 Copyright 2020 Frenetic Studios LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import SwiftUI

let kDefaultHandleWidth: CGFloat = 15
let kDefaultHandleHeight: CGFloat = 16
let kDefaultTrackHeight: CGFloat = 3
let kDefaultLabelFontSize: CGFloat = 14
let kDefaultValueLabelFontSize: CGFloat = 12


/// Enumeration used to specify which bound is referenced in calls such as
/// the onValueChanged call.
public enum RangeSliderBound {
    case lower
    case upper
}

// MARK: -

/// View to represent a range of values within specified limits. Designed to fit in
/// with other SwiftUI elements in terms of appearance.
public struct RangeSlider<T: BinaryFloatingPoint>: View {
    
    @Environment(\.colorScheme) var colorScheme

    @Binding var value: ClosedRange<T>
    var limits: ClosedRange<T>
    var label: String?
    var step: T.Stride
    var precision: Int = 0
    var onValueChanged: (RangeSliderBound, ClosedRange<T>) -> Void
    var describeValue: ((T) -> String?)?
    
    public var selectedColor: Color = Color.accentColor
    public var valueColor: Color = Color.primary
    public var trackColor: Color {
        get {
            self.colorScheme == .dark ? Color.rangeSliderDarkGray : Color.rangeSliderMediumGray
        }
    }
    public var handleColor: Color {
        get {
            self.colorScheme == .dark ? Color.rangeHandleColor : Color.white
        }
    }
    public var valueFont: Font = Font.system(size: kDefaultValueLabelFontSize)
    public var trackHeight: CGFloat = kDefaultTrackHeight
    public var handleWidth: CGFloat = kDefaultHandleWidth
    public var handleHeight: CGFloat = kDefaultHandleHeight
        
    /// Creates a range selection slider using the provided parameters.
    /// - Parameters:
    ///   - value: The current selection range
    ///   - limits: The lower and upper bounds of the seletable range
    ///   - step: The stride value of each increment/decrement step of the slider
    ///   - precision: The number of decimal points to which to round values
    ///   - onValueChanged: Function to call when user changes either range value. Which value that
    ///   the user changed is specified via a RangeSliderBound value.
    ///   - describeValue: Optional. Called whenever a value needs to be described for display.
    public init (_ value: Binding<ClosedRange<T>>,
                 limits: ClosedRange<T>,
                 step: T.Stride = 1,
                 precision: Int = 0,
                 onValueChanged: @escaping (RangeSliderBound, ClosedRange<T>) -> Void,
                 describeValue: @escaping (T) -> String? = {value in nil}) {
        self._value = value
        self.limits = limits
        self.step = step
        self.precision = precision
        self.onValueChanged = onValueChanged
        self.describeValue = describeValue
    }
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                self.renderSlider(with: geometry)
            }
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(self.describe(value: self.value.lowerBound))
                    .font(self.valueFont)
                    .foregroundColor(self.valueColor)
                Text(" - ")
                Text(self.describe(value: self.value.upperBound))
                    .font(self.valueFont)
                    .foregroundColor(self.valueColor)
            }
        }
    }
    
    private func renderSlider (with geometry: GeometryProxy) -> some View {
        /**
         Drag gesntures to let the user change the lower and upper range values.
         */
        let leftDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { mouse in
                guard mouse.location.x >= 0 &&
                    mouse.location.x <= self.offset(of: self.value.upperBound, in: geometry)
                else {
                    return
                }
                let newLowerBound =
                    Float.minimum(Float(self.limits.lowerBound) + Float(self.offsetToStride(mouse.location.x, in: geometry)),
                        Float(self.value.upperBound))
                self.value = T(self.roundValue(Double(newLowerBound), places: self.precision))...self.value.upperBound
                self.onValueChanged(.lower, self.value)
        }

        let rightDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { mouse in
                guard mouse.location.x >= self.offset(of: self.value.lowerBound - abs(self.limits.lowerBound), in: geometry) &&
                    mouse.location.x <= geometry.size.width else {
                    return
                }
                var newUpperBound = self.roundValue(
                                            Double(self.limits.lowerBound +
                                                    self.offsetToStride(mouse.location.x, in: geometry)),
                                            places: self.precision)
                if newUpperBound < self.value.lowerBound {
                    newUpperBound = self.value.lowerBound
                }
                self.value = self.value.lowerBound...newUpperBound
                self.onValueChanged(.upper, self.value)
        }
        
        return ZStack (alignment: .leading) {
                    // Track Rectangle
                    RoundedRectangle(cornerRadius: 3)
                        .frame(
                            width: geometry.size.width,
                            height: self.trackHeight)
                        .foregroundColor(self.trackColor)
                        .zIndex(0)
                    // Selection Rectangle
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: self.selectionWidth(in: geometry), height: self.trackHeight)
                        .offset(x: self.offset(of: self.value.lowerBound, in: geometry))
                        .foregroundColor(self.selectedColor)
                        .zIndex(1)
                    // Lower range value draggable handle
                    RangeSliderHandle()
                        .fill(self.handleColor)
                        .frame(width: self.handleWidth, height: self.handleHeight, alignment: .center)
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0.5)
                        .zIndex(2)
                        .offset(x: self.offset(of: self.value.lowerBound, in: geometry) - (self.handleWidth/2),
                                y: 0)
                        .gesture(leftDragGesture)
                    // Upper range value draggable handle
                    RangeSliderHandle()
                        .fill(self.handleColor)
                        .frame(width: self.handleWidth, height: self.handleHeight, alignment: .center)
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0.5)
                        .zIndex(2)
                        .offset(x: self.offset(of: self.value.upperBound, in: geometry) - (self.handleWidth/2),
                                y: 0)
                        .gesture(rightDragGesture)
                }
    }
    
    // MARK: - Utility methods -
            
    
    /// Converts range value to an offset into the track of the slider control.
    /// - Parameters:
    ///   - value: The range value
    ///   - geometry: The geometry inside of which the range slider is being rendered
    /// - Returns: The offset of the value into the slider track.
    func offset (of value: T, in geometry: GeometryProxy) -> CGFloat {
        return (strideWidth(in: geometry) * CGFloat(value-self.limits.lowerBound))
    }

    
    /// Converts an offset into the track into a range value.
    /// - Parameters:
    ///   - offset: The offset into the track of the range slider control.
    ///   - geometry: The geometry inside of which the range slider is being rendered
    /// - Returns: The converted range value.
    func offsetToStride (_ offset: CGFloat, in geometry: GeometryProxy) -> T {
        return T(offset / strideWidth(in: geometry))
    }
    
    
    /// Calculates the width of a single stride inside the track.
    /// - Parameter geometry: The geometry inside of which the range slider is being rendered
    /// - Returns: The width of a single stride inside of the track.
    func strideWidth (in geometry: GeometryProxy) -> CGFloat {
        let numStrides = self.limits.upperBound - self.limits.lowerBound
        return geometry.size.width / CGFloat(numStrides)
    }
    
    
    /// Calculates the width of the selected range
    /// - Parameter geometry: The geometry inside of which the range slider is being rendered.
    /// - Returns: The width of the range selection inside the track.
    func selectionWidth (in geometry: GeometryProxy) -> CGFloat {
        let minOffset = self.offset(of: self.value.lowerBound, in: geometry)
        let maxOffset = self.offset(of: self.value.upperBound, in: geometry)
        return maxOffset - minOffset
    }
    
    
    /// Rounds a value to nearest precision specified by the places parameter.
    /// - Parameters:
    ///   - value: The value to round.
    ///   - places: The number of decimal places to round to
    /// - Returns: The rounded value.
    func roundValue(_ value:Double, places:Int) -> T {
        let divisor = pow(10.0, Double(places))
        return T(round(value * divisor) / divisor)
    }
    
    
    /// Returns a string describing a range value. If instantiated with
    /// a describeValue function, attempts to get the value description
    /// by calling it. Otherwise creates a description based on value
    /// precision.
    /// - Parameter value: The range value.
    /// - Returns: The string describing the range value.
    func describe(value: T) -> String {
        if let describeFunc = self.describeValue {
            if let description = describeFunc (value) {
                return description
            }
        }
        if self.precision > 0 {
            return String(format:"%." + String(self.precision) + "f", value as! CVarArg)
        } else {
            return String(Int(value))
        }
    }
}

// MARK: - RangeIndicator -

/// RangeSliderHandle is used to render a single "handle" that the user can tap/click and
/// drag or swipe to change a range's lower or upper bound value.

struct RangeSliderHandle: Shape {
        
    let radius: CGFloat = 4
    
    func path(in rect: CGRect) -> Path {
                
        let topLeft = CGPoint (x: rect.origin.x, y: rect.origin.y)
        let topRight = CGPoint (x: rect.origin.x + rect.size.width, y: rect.origin.y)
        let bottomRight = CGPoint( x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)
        let bottomLeft = CGPoint( x: rect.origin.x, y: rect.origin.y + rect.size.height)
        
        let triangleHeight = (rect.size.height / 2)
        let boxHalf = rect.size.width/2
        
        var path = Path()
        path.move(to: CGPoint(x: topLeft.x + radius, y: topLeft.y))
        path.addLine(to: CGPoint(x: topRight.x - radius, y: topRight.y))
        path.addCurve(to: CGPoint(x: topRight.x, y: topRight.y + radius), control1: topRight, control2: topRight)
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - triangleHeight))
        path.addLine(to: CGPoint(x: bottomLeft.x + boxHalf, y: bottomLeft.y))
        path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - triangleHeight))
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + radius))
        path.addCurve(to: CGPoint(x: topLeft.x + radius, y: topLeft.y), control1: topLeft, control2: topLeft)
        
        return path
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        RangeSlider<Float>(
            .constant(2...5),
            limits: 1...10,
            onValueChanged: { (bound, value) in
                print ("value changed: \(String(describing: value))")
            })
    }
}


// MARK: - Supplementary -

/**
 Custom colors for default RangeSlider
 */
fileprivate extension Color {
    
    static var rangeSliderDarkGray: Color {
        get { return Color.init(red: 0.33, green: 0.33, blue: 0.33) }
    }
    
    static var rangeSliderLightGray: Color {
       get { return Color.init(red: 0.9, green: 0.9, blue: 0.9) }
    }

    static var rangeHandleColor: Color {
       get { return Color.init(red: 0.8, green: 0.8, blue: 0.8) }
    }

    static var rangeSliderMediumGray: Color {
       get { return Color.init(red: 0.72, green: 0.72, blue: 0.72) }
    }
}
