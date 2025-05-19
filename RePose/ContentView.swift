//
//  ContentView.swift
//  RePose
//
//  Created by mona alruthaya on 06/11/1446 AH.
//

import SwiftUI
import AVKit
import AVFoundation
import _AVKit_SwiftUI

// MARK: - Workout Model
struct Workout: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let videoName: String
}

// MARK: - Content View
struct ContentView: View {
    let workouts: [Workout] = [
        Workout(imageName: "img1", title: "Burpees", subtitle: "Bodyweight Strength", videoName: "Burpees"),
        Workout(imageName: "img2", title: "Jumping Jack", subtitle: "Cardio Blast", videoName: "JumpingJack"),
        Workout(imageName: "img3", title: "Lunges", subtitle: "Leg Power", videoName: "Lunges")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome")
                        .font(.system(size: 28, weight: .bold))

                    Text("Choose your workout and shine today!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)

                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutCard(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(30)
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Workout Card
struct WorkoutCard: View {
    let workout: Workout

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(workout.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 316, height: 190)
                .clipped()
                .cornerRadius(20)

            ZStack {
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                    .clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]))

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(workout.subtitle)
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 77.19)
            .frame(width: 316)
        }
        .frame(width: 316, height: 190)
        .shadow(color: Color.black.opacity(0.1), radius: 0.5, x: 0, y: 1)
        .padding(.bottom, 33)
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var showWorkoutScreen = false

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // النص قبل الفيديو
                Text("Before starting your workout we recommend to watch the ")
                    + Text("video:")
                        .foregroundColor(Color.accent)
                
                // فيديو التمرين
                if let url = Bundle.main.url(forResource: workout.videoName, withExtension: "mp4") {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 250)
                        .cornerRadius(20)
                        .padding(.horizontal)
                } else {
                    Text("Video not found.")
                        .foregroundColor(.red)
                }

                // النص الإرشادي Form Tip
                VStack(alignment: .leading, spacing: 4) {
                    Text("Form Tip:")
                        .font(.headline)
                        .foregroundColor(Color.accent)
                    Text("Keep your back straight and your front knee above your ankle")
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // زر Start Workout
                Button(action: {
                    showWorkoutScreen = true
                }) {
                    Text("Start Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220) // عرض متوسط
                        .background(Color.accent)
                        .cornerRadius(14)
                }
                .padding(.top, 30)
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationTitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showWorkoutScreen) {
            MainViewWrapper()
            .ignoresSafeArea()// ✅ هنا يتم فتح شاشة MainViewController

        }
    }
}


// MARK: - UIKit Blur
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

// MARK: - Rounded Corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


// MARK: - Preview
#Preview {
    ContentView()
}
