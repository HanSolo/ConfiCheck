//
//  FloatingNotice.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 28.01.25.
//

import Foundation
import SwiftUI


struct FloatingNotice: View {
    @Binding var showNotice: Bool

    var body: some View {
        VStack (alignment: .center, spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .font(.system(size: 48, weight: .regular, design: .rounded))
                .padding(EdgeInsets(top: 20, leading: 5, bottom: 5, trailing: 5))
            Text("Copied")
                .font(.system(size: 16, weight: .light, design: .rounded))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 5, trailing: 30))
        }
        .background(Color.gray.opacity(0.75))
        .cornerRadius(10)
        .transition(.scale)
        .transition(.opacity)
        .onAppear(perform: {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.showNotice = false
                }
            }
        })
    }
}
