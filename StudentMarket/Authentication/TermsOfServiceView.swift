//
//  TermsOfService.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/16/24.
//

import SwiftUI

struct TermsOfService: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView() {
            Image(systemName: "xmark")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle).bold()
                .padding(25)
                .onTapGesture {
                    dismiss()
                }
            Text("TERMS OF SERVICE")
                .font(.title)
        }
    }
}

#Preview {
    TermsOfService()
}
