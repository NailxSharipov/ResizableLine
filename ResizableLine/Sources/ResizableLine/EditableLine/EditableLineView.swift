//
//  EditableLineView.swift
//  ResizableLine
//
//  Created by Nail Sharipov on 06.04.2022.
//

import SwiftUI

public struct EditableLineView<Content: View>: View {
    
    struct DragState {
        enum State {
            case left
            case right
            case middle
            case empty
        }
        
        let state: State
        let startLeft: CGFloat
        let startRight: CGFloat
    }

    @Binding private var leftEnd: CGFloat
    @Binding private var rightEnd: CGFloat
    @State private var feedbackGenerator: UISelectionFeedbackGenerator? = nil
    
    @State private var dragState: DragState? {
        didSet {
            guard ruler != nil else { return }
            if dragState != nil {
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                self.feedbackGenerator = generator
            } else {
                self.feedbackGenerator = nil
            }
        }
    }

    private let a: CGFloat
    private let b: CGFloat
    private let rearColor: Color
    private let frontColor: Color
    private let cornerRadius: CGFloat = 4
    private let content: Content
    private let ruler: Ruler?
    
    
    public init(
        a: CGFloat,
        b: CGFloat,
        rearColor: Color,
        frontColor: Color,
        ruler: Ruler? = nil,
        leftEnd: Binding<CGFloat>,
        rightEnd: Binding<CGFloat>,
        @ViewBuilder content: () -> Content
    ) {
        self.a = a
        self.b = b
        self.rearColor = rearColor
        self.frontColor = frontColor
        self.ruler = ruler
        self._leftEnd = leftEnd
        self._rightEnd = rightEnd
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                content
                Plank(rect: CGRect(origin: .zero, size: proxy.size), a: a, b: b, cornerRadius: cornerRadius, color: rearColor)
                Plank(rect: flexible(size: proxy.size), a: a, b: b, cornerRadius: cornerRadius, color: frontColor)
                Path { path in

                    let rect = flexible(size: proxy.size)
                    
                    let my = 0.5 * proxy.size.height
                    
                    let offset: CGFloat = 6
                    let dx: CGFloat = a - 2 * offset
                    let dy: CGFloat = ceil(0.5 * my)
                    
                    let lm = CGPoint(x: rect.minX + offset, y: my)
                    let rm = CGPoint(x: rect.maxX - offset, y: my)
                    
                    path.move(to: CGPoint(x: lm.x + dx, y: lm.y - dy))
                    path.addLine(to: lm)
                    path.addLine(to: CGPoint(x: lm.x + dx, y: lm.y + dy))
                    
                    path.move(to: CGPoint(x: rm.x - dx, y: rm.y - dy))
                    path.addLine(to: rm)
                    path.addLine(to: CGPoint(x: rm.x - dx, y: rm.y + dy))
                    
                }.stroke(style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round)).foregroundColor(.black)
            }
            .gesture(DragGesture()
                .onChanged { data in
                    if self.dragState == nil {
                        self.dragState = self.start(data: data, size: proxy.size)
                    }
                    self.drag(data: data, size: proxy.size)
                }
                .onEnded { data in
                    self.drag(data: data, size: proxy.size)
                    self.dragState = nil
                }
            )
        }
    }
    
    private func flexible(size: CGSize) -> CGRect {
        let width = size.width - 2 * a
        let left = width * leftEnd
        let right = width * rightEnd
        
        return CGRect(
            x: left,
            y: 0,
            width: right - left + 2 * a,
            height: size.height
        )
    }

    private func start(data: DragGesture.Value, size: CGSize) -> DragState {
        let sensority: CGFloat = 40
        let width = size.width - 2 * a
        let left = width * leftEnd + a
        let right = width * rightEnd + a
        
        let x = data.startLocation.x
        
        let ltSensor = abs(left - x)
        let rtSensor = abs(right - x)

        let isLfFactor = ltSensor < sensority
        let isRtFactor = rtSensor < sensority
        let isMiddle = left < x && x < right

        let state: DragState.State
        
        if isLfFactor && isRtFactor {
            if x < left && data.predictedEndTranslation.width < 0 {
                state = .left
            } else if x > right && data.predictedEndTranslation.width > 0 {
                state = .right
            } else {
                state = .middle
            }
        } else if isLfFactor {
            state = .left
        } else if isRtFactor {
            state = .right
        } else if isMiddle {
            state = .middle
        } else {
            state = .empty
        }
        
        return DragState(state: state, startLeft: leftEnd, startRight: rightEnd)
    }
    
    private func drag(data: DragGesture.Value, size: CGSize) {
        guard let dragState = self.dragState else { return }
        let width = size.width - 2 * a

        let delta = data.translation.width / width
        
        var newLeft = self.leftEnd
        var newRight = self.rightEnd
        
        switch dragState.state {
        case .empty:
            break
        case .left:
            newLeft = min(dragState.startRight, max(0, dragState.startLeft + delta))
        case .right:
            newRight = max(dragState.startLeft, min(1, dragState.startRight + delta))
        case .middle:
            let lf = dragState.startLeft + delta
            let rt = dragState.startRight + delta
            let len = dragState.startRight - dragState.startLeft
            if lf < 0 {
                newLeft = 0
                newRight = len
            } else if rt > 1 {
                newLeft = 1 - len
                newRight = 1
            } else {
                newLeft = dragState.startLeft + delta
                newRight = dragState.startRight + delta
            }
        }

        if let ruler = self.ruler {
            let count = CGFloat(ruler.count)
            let tikLeft = Int(newLeft * count) != Int(self.leftEnd * count)
            let tikRight = Int(newRight * count) != Int(self.rightEnd * count)
            
            if tikLeft || tikRight {
                self.feedbackGenerator?.selectionChanged()
                self.feedbackGenerator?.prepare()
            }
        }
        
        
        if !newLeft.isSame(self.leftEnd) {
            self.leftEnd = newLeft
        }
        if !newRight.isSame(self.rightEnd) {
            self.rightEnd = newRight
        }
    }
    
}

struct EditableLineView_Previews: PreviewProvider {
    static var previews: some View {
        EditableLineView(a: 16, b: 4, rearColor: .gray, frontColor: .yellow, leftEnd: .constant(0), rightEnd: .constant(1)) {
            Color.red
        }
    }
}


private extension CGFloat {
    
    func isSame(_ value: CGFloat) -> Bool {
        return abs(self - value) < 0.00001
    }
    
}
