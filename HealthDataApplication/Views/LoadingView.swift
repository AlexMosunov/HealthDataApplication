//
//  LoadingView.swift
//  HealthDataApplication
//
//  Created by User on 08.12.2023.
//

import SwiftUI

struct LoadingView: View {
    @State private var progress: CGFloat = 0.0
    @State private var isImportComplete = false
    @State private var navigateToNextView = false // State to control navigation

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(.degrees(-90))
                    .animation(nil) // Disable animation initially
                    .onAppear {
                        startProgressAnimation()
                    }
                
                Text("\(Int(progress * 100))%") // Display percentage
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .padding(40)
            }
            .padding()
            
            if isImportComplete {
                Button(action: {
                    print("dick")
                    navigateToNextView = true // Navigate to AnotherView when button tapped
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
//                .disabled(progress != 1.0) // Disable button until progress reaches 100%
            }
            
            Spacer()
        }
        .fullScreenCover(isPresented: $navigateToNextView) {
            MainView()
        }
    }
    
    private func startProgressAnimation() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            progress += 0.01
            if progress >= 1.0 {
                timer.invalidate()
                isImportComplete = true
            }
        }
        // Fire the timer manually for the first time
        timer.fire()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
