
import SwiftUI

enum DoubleSliderLabelPosition {
    case top
    case bottom
}

struct RangeSlider<V> : View where V: BinaryInteger {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var minValue: V
    @Binding var maxValue: V
    @Binding var strideBy: V
    
    var range: ClosedRange<V>
        
    var size: CGSize = CGSize(width: 300, height: 3)
    
    var label: Text? = nil
    var labelPosition: DoubleSliderLabelPosition = .top

    var valueLabelFont: Font? = nil

    var indicatorDiameter: CGFloat = 12

    var gutterColor: Color? = nil
    var rangeColor: Color? = nil
    var minIndicatorColor: Color = Color.primary
    var maxIndicatorColor: Color = Color.primary
    var matchColor: Color? = nil

    // -------------------------------------------- //
    
    var body: some View {
        
        let leftDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x >= 0 &&
                      value.location.x <= (self.convertToOffsetUnits(self.maxValue) -
                                           self.convertToOffsetUnits(self.range.lowerBound)) else {
                    return
                }
                self.minValue = self.range.lowerBound + self.convertToValueUnits(value.location.x)
        }
        
        let rightDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x >= (self.convertToOffsetUnits(self.minValue) -
                                           self.convertToOffsetUnits(self.range.lowerBound)) &&
                      value.location.x <= self.size.width else {
                    return
                }
                self.maxValue = self.convertToValueUnits(value.location.x) + self.range.lowerBound
        }
                
        return
            VStack {
                if self.label != nil && self.labelPosition == .top {
                    self.label!
                }
                ZStack (alignment: .leading) {
                    Rectangle()
                        .frame(
                            width: getUnitSize() * getNumStrides(),
                            height: self.size.height)
                        .foregroundColor(self.getGutterColor())
                        .zIndex(0)
                    Rectangle()
                        .frame(width: self.getSelectionRangeWidth(),
                               height: self.size.height)
                        .offset(x:convertToOffsetUnits(self.minValue) - convertToOffsetUnits(self.range.lowerBound))
                        .foregroundColor(self.getRangeColor())
                        .zIndex(1)
                    
                    VStack {
                        Text(" ")
                            .font(self.getValueLabelFont())
                        Circle()
                            .fill(self.minIndicatorColor)
                            .frame(width: self.indicatorDiameter, height: self.indicatorDiameter)
                        Text(String(self.minValue))
                            .font(self.getValueLabelFont())
                            .foregroundColor(self.maxValue == self.minValue ? self.getMatchColor() : Color.primary)
                    }
                    .frame(alignment: .center)
                    .offset(x: convertToOffsetUnits(self.minValue) - convertToOffsetUnits(self.range.lowerBound) - self.indicatorDiameter, y: 0)
                    .gesture(leftDragGesture)
                    .zIndex(1)

                    VStack {
                        Text(String(self.maxValue))
                            .font(self.getValueLabelFont())
                            .foregroundColor(self.maxValue == self.minValue ? self.getMatchColor() : Color.primary)
                        Circle()
                            .fill(self.minIndicatorColor)
                            .frame(width: self.indicatorDiameter, height: self.indicatorDiameter)
                        Text(" ")
                            .font(self.getValueLabelFont())
                    }
                    .frame(alignment: .center)
                    .offset(x: convertToOffsetUnits(self.maxValue) - convertToOffsetUnits(self.range.lowerBound) - self.indicatorDiameter, y: 0)
                    .gesture(rightDragGesture)
                    .zIndex(1)
                }
                if self.label != nil && self.labelPosition == .bottom {
                    self.label!
                }
            }
        .padding()
    }
    
    func getUnitSize () -> CGFloat {
        return size.width / getNumStrides()
    }
    
    func convertToOffsetUnits (_ value: V) -> CGFloat {
        return getUnitSize() * CGFloat(value)
    }
    
    func convertToValueUnits( _ value: CGFloat) -> V {
        return V(value / getUnitSize())
    }
    
    func getNumStrides () -> CGFloat {
        return CGFloat((self.range.upperBound - self.range.lowerBound + 1) / self.strideBy)
    }
    
    func getSelectionRangeWidth () -> CGFloat {
        let width = size.width
        let leftInset = convertToOffsetUnits(minValue) - convertToOffsetUnits(range.lowerBound)
        let rightInset = width - (convertToOffsetUnits(maxValue) - convertToOffsetUnits(range.lowerBound))
        return width - (leftInset + rightInset)
    }
    
    func getGutterColor () -> Color {
        if gutterColor != nil {
            return gutterColor!
        }
        return colorScheme == .dark ? Color.darkGray : Color.lightGray
    }

    func getRangeColor () -> Color {
        if rangeColor != nil {
            return rangeColor!
        }
        return Color.accentColor
    }
    
    func getMatchColor () -> Color {
        if matchColor != nil {
            return matchColor!
        }
        return Color.green
    }
    
    func getValueLabelFont() -> Font {
        if self.valueLabelFont != nil {
            return self.valueLabelFont!
        }
        return Font.caption
    }
}

/**
 Custom colors for default RangeSlider
 */
extension Color {
    
    public static var darkGray: Color {
        get { return Color.init(red: 0.33, green: 0.33, blue: 0.35) }
    }
    
    public static var lightGray: Color {
       get { return Color.init(red: 0.9, green: 0.9, blue: 0.9) }
    }
}

#if DEBUG
struct DoubleSlider_Previews : PreviewProvider {
        
    static var previews: some View {
        RangeSlider<Int>(minValue: .constant(0),
                            maxValue: .constant(100),
                            strideBy: .constant(1),
                            range: 0...100)
    }
}
#endif
