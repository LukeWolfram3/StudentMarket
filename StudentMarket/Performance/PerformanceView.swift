//
//  PerformanceView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 2/5/25.
//

import SwiftUI
import FirebasePerformance

// Generally for functions when we want to see how long they take

struct PerformanceView: View {
    
    @State private var title: String = "Some title"
    
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                configure()
            }
    }
    
    private func configure() {
        let trace = Performance.startTrace(name: "performance_view_loading")
        trace?.setValue(title, forAttribute: "title_text")
        
        Task {
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            trace?.setValue("Started downloading", forAttribute: "func_state")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            trace?.setValue("Continued downloading", forAttribute: "func_state")

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            trace?.setValue("Continued downloading", forAttribute: "func_state")

            
            trace?.stop()
        }
    }
}

#Preview {
    PerformanceView()
}
