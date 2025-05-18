//
//  OnboardingScreens.swift
//  RePose
//
//  Created by Mashael Aldosari on 07/11/1446 AH.
//

import SwiftUI

struct OnboardingScreen1: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to").font(.title)
                .padding(.top, -125)
            Text("Motion").font(.title).bold().foregroundColor(.accent)
                .padding(.top, -115)
            Image("plank") // Replace with your image name
                .resizable().scaledToFit().frame(height: 300)
                .padding(.top, -25)
            Text("Move better\nTrain smarter")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct OnboardingScreen2: View {
    var body: some View {
        VStack {
            Spacer()
            Image("squat") // Replace with your image
                .resizable().scaledToFit().frame(height: 300)
            Text("Real-Time Feedback")
                .font(.title).bold().foregroundColor(.accent)
            Text("Perfect your form instantly")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct OnboardingScreen3: View {
    var onFinish: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Image("strech") // Replace with your image
                .resizable().scaledToFit().frame(height: 300)
                .padding(.top, 60)
            Text("Choose Your Workout")
                .font(.title).bold().foregroundColor(.accent)
            Spacer()
            Button(action: {
                onFinish()
            }) {
                Text("Let’s Get Started")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
        .padding()
    }
}

