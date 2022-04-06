//
//  ContentView.swift
//  DebugApp
//
//  Created by Nail Sharipov on 06.04.2022.
//

import SwiftUI
import ResizableLine

struct ContentView: View {
    
    final class ViewModel: ObservableObject {
        
        @Published var leftEnd: CGFloat = 0.2 {
            didSet {
                print(leftEnd)
            }
        }
        @Published var rightEnd: CGFloat = 0.8 {
            didSet {
                print(rightEnd)
            }
        }
        
    }
    
    @StateObject var viewModel = ViewModel()
    private let ruler = Ruler(count: 40, step: 10)
    
    var body: some View {
        VStack {
            Color(uiColor: .blue)
                .frame(maxHeight: .infinity)
            EditableLineView(
                a: 16,
                b: 4,
                rearColor: Color(white: 0.12),
                frontColor: .yellow,
                ruler: ruler,
                leftEnd: $viewModel.leftEnd,
                rightEnd: $viewModel.rightEnd) {
                RulerView(
                    a: 16,
                    majorHeight: 20,
                    minorHeight: 16,
                    ruler: ruler,
                    majorColor: .white,
                    minorColor: Color(white: 1, opacity: 0.5)
                ).background(.black)
            }
            .frame(maxHeight: 40)
            .padding(16)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
