//
//  ProgressDialog.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/10.
//

import Foundation
import SwiftUI

struct ProgressDialog: View {
    @Binding var progress: Double

    var body: some View {
        VStack {
            Text("Progress: \(Int(progress * 100))%")
                .font(.headline)
                .padding()

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Slider(value: $progress, in: 0...1)
                .padding()

            Button(action: {
                // Close the dialog
            }) {
                Text("Close")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
