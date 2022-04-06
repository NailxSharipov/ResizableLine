//
//  RulerView.swift
//  ResizableLine
//
//  Created by Nail Sharipov on 06.04.2022.
//

import SwiftUI

public struct RulerView: View {

    private let a: CGFloat
    private let majorHeight: CGFloat
    private let minorHeight: CGFloat
    private let ruler: Ruler
    private let majorColor: Color
    private let minorColor: Color
    
    public init(a: CGFloat, majorHeight: CGFloat, minorHeight: CGFloat, ruler: Ruler, majorColor: Color, minorColor: Color) {
        self.a = a
        self.majorHeight = majorHeight
        self.minorHeight = minorHeight
        self.ruler = ruler
        self.majorColor = majorColor
        self.minorColor = minorColor
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Path { path in

                let dx = (proxy.size.width - 2 * a) / CGFloat(ruler.count)
                var x = a
                
                let y0 = 0.5 * (proxy.size.height - majorHeight)
                let y1 = y0 + majorHeight
                for i in 0...ruler.count {
                    if i % ruler.step == 0 {
                        path.move(to: CGPoint(x: x, y: y0))
                        path.addLine(to: CGPoint(x: x, y: y1))
                    }
                    x += dx
                }
            }
            .stroke(lineWidth: 1)
            .foregroundColor(majorColor)
            Path { path in

                let dx = (proxy.size.width - 2 * a) / CGFloat(ruler.count)
                var x = a
                
                let y0 = 0.5 * (proxy.size.height - minorHeight)
                let y1 = y0 + minorHeight
                for i in 0...ruler.count {
                    if i % ruler.step != 0 {
                        path.move(to: CGPoint(x: x, y: y0))
                        path.addLine(to: CGPoint(x: x, y: y1))
                    }
                    x += dx
                }
            }
            .stroke(lineWidth: 1)
            .foregroundColor(minorColor)
        }
    }
}
