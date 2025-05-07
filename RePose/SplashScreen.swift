//
//  SplashScreen.swift
//  RePose
//
//  Created by Mashael Aldosari on 07/11/1446 AH.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var showOnboarding = false
    @State private var opacity = 1.0

    var body: some View {
        if showOnboarding {
            OnboardingContainerView()
        } else {
            ZStack {
                Color.purple.edgesIgnoringSafeArea(.all)
                Image("logo") // Replace with your actual asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showOnboarding = true
                }
            }
        }
    }
}

struct OnboardingContainerView: View {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @State private var currentIndex = 0
    
    init() {
        // Customize the dots
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
    }
    
    var body: some View {
        if hasLaunchedBefore {
            ContentView() // هنا ربطنا ContentView
        } else {
            ZStack {
                TabView(selection: $currentIndex) {
                    OnboardingScreen1().tag(0)
                    OnboardingScreen2().tag(1)
                    OnboardingScreen3 {
                        hasLaunchedBefore = true
                    }.tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            hasLaunchedBefore = true
                        }
                        .foregroundColor(.purple)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
