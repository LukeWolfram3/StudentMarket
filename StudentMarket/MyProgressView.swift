//
//  isLoadingView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/31/24.
//

import SwiftUI

struct MyProgressView: View {
    
    @State private var currentIndex = 0
    
    @State private var isUp = false
    
    let totalRectangles: Int = 5
    
    var body: some View {
        ZStack {
            Color("MainColor").ignoresSafeArea()
            VStack {
                Image(systemName: "graduationcap.fill").font(.system(size: 60))
                Text("Student Market").font(.title).bold()

                HStack {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .frame(width: 25, height: 25)
                            .offset(y: (index == currentIndex && isUp) ? -20 : 0)
                            .animation(.easeInOut(duration: 0.3), value: isUp)
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .padding(40)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                isUp.toggle()
                
                if !isUp {
                    currentIndex = (currentIndex + 1) % totalRectangles
                }
            }
        }
    }
}

#Preview {
    MyProgressView()
}
