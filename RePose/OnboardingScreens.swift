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
            Text("Welcome to").font(.system(size: 40)).bold()
                .padding(.top, -125)
            Text("PosePal").font(.system(size: 45)).bold().foregroundColor(.accent)
                .padding(.top, -105)
            Image("plank") // Replace with your image name
                .resizable().scaledToFit().frame(height: 300)
                .padding(.top, -25)
            Text("Move better\nTrain smarter")
                .multilineTextAlignment(.center)
                .font(.system(size: 33, weight: .light))
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
                .resizable().scaledToFit().frame(height: 400)
            Text("Real-Time\nFeedback")
                .font(.system(size: 40)).bold().foregroundColor(.accent)
                .offset(x: 2, y: -70)
            Text("Perfect your form instantly")
                .offset(x: 2, y: -45)
               .multilineTextAlignment(.center)
                .font(.system(size: 27, weight: .light))
              //  .padding()
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
                .resizable().scaledToFit().frame(height: 450)
              //  .padding(.top, 30)
            Text("Choose Your Workout")
                .font(.system(size: 30)).bold().foregroundColor(.accent)
                .offset(x: 2, y: -45)
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
            .padding(.bottom, 100)
        }
        .padding()
    }
}

#Preview {
    OnboardingScreen2()
}
