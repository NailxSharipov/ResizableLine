//
//  EditableLineView+Plank.swift
//  ResizableLine
//
//  Created by Nail Sharipov on 06.04.2022.
//

import SwiftUI

extension EditableLineView {

    struct Plank: View {

        private let rect: CGRect
        private let a: CGFloat
        private let b: CGFloat
        private let cornerRadius: CGFloat
        private let color: Color

        init(rect: CGRect, a: CGFloat, b: CGFloat, cornerRadius: CGFloat, color: Color) {
            self.rect = rect
            self.a = a
            self.b = b
            self.cornerRadius = cornerRadius
            self.color = color
        }

        var body: some View {
            Path { path in
                let rect0 = Path(roundedRect: rect, cornerRadius: cornerRadius)

                let rect1 = Path(roundedRect: CGRect(
                    x: rect.minX + a,
                    y: rect.minY + b,
                    width: rect.width - 2 * a,
                    height: rect.height - 2 * b
                ), cornerRadius: cornerRadius)
                
                path.addPath(rect0)
                path.addPath(rect1)
                
            }
            .fill(style: .init(eoFill: true, antialiased: true))
            .foregroundColor(color)
        }
        
    }

}
