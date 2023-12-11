//
//  ContentView.swift
//  HealthDataApplication
//
//  Created by User on 08.12.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var manager: HealthStore
    @State private var authorized = false
    @State private var navigateToLoaderView = false
    @State private var isLoading = false
    
    var body: some View {

            
            VStack {
                if isLoading {
                    ProgressView("Loading") // Show loading indicator
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.0)
                }
                Text("We need access to your Health & Activity data")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("To provide you with a personalized and rewarding health experience, we request your permission to access your health and activity data. Enable access to your health data now.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                    Button(action: {
                        isLoading = true
                        requestHealthkitAuth()
                        print("manager.isAuthorised - \(manager.isAuthorised)")
                        //                            navigateToLoaderView = true
                    }) {
                        Text("Go to Permissions")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                
            }
            .padding()
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $navigateToLoaderView) {
                LoadingView()
            }
    }

    private func requestHealthkitAuth() {
        if manager.isAuthorised {
            isLoading = false
            navigateToLoaderView = true
        }
           Task {
               // Hide loading indicator when request completes
               do {
                  
                   let result = try await manager.requestAuthorization()
                   isLoading = false
                   print("Result - \(result)")
                   if result {
                       navigateToLoaderView = true
                   }
                  
               } catch {
                   isLoading = false
                   print("Error while requesting authorization: \(error)")
               }
           }
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
