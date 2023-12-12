//
//  LoadingView.swift
//  HealthDataApplication
//
//  Created by User on 08.12.2023.
//

import SwiftUI
struct LoadingView: View {
    @EnvironmentObject var manager: HealthStore
    @State private var progress: CGFloat = 0.0
    @State private var isImportComplete = false
    @State private var navigateToNextView = false

    var body: some View {
        VStack {
            Text("Importing Health Data")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 40)
            ZStack {
                Circle()
                    .stroke(lineWidth: 30.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(.degrees(-90))
                    .animation(nil)
                    .onAppear {
                        startProgressAnimation()
                    }

                Text("\(Int(progress * 100))%") // Display percentage
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .padding(20)
            }
            .padding()

            if isImportComplete {
                Button(action: {
                    navigateToNextView = true
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }

            Spacer()
        }
        .task {
            do {
                // we can also send this statistics toserver or save in local database at this stage
                try await manager.calculateStatistics()
            } catch {
                print(error)
            }
        }
        .fullScreenCover(isPresented: $navigateToNextView) {
            HealthInsightsView()
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
        timer.fire()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
