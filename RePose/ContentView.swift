//
//  ContentView.swift
//  RePose
//
//  Created by mona alruthaya on 06/11/1446 AH.
//
import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

// MARK: - Workout Model
struct Workout: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Main View
struct ContentView: View {
    let workouts: [Workout] = [
        Workout(imageName: "img1", title: "Burpees", subtitle: "Bodyweight Strength"),
        Workout(imageName: "img2", title: "Jumping Jack", subtitle: "Cardio Blast"),
        Workout(imageName: "img3", title: "Lunges", subtitle: "Leg Power")
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
        .padding(.bottom, 33)
    }
}

// MARK: - Detail View with Video
struct WorkoutDetailView: View {
    let workout: Workout
    @State private var showWorkoutScreen = false // ✅هنا

    var body: some View {
        VStack(spacing: 24) {
            if let url = Bundle.main.url(forResource: workout.imageName, withExtension: "mp4") {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 250)
                    .cornerRadius(16)
                    .padding(.horizontal)
            } else {
                Image(workout.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16)
                    .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(workout.title)
                    .font(.system(size: 28, weight: .bold))
                Text("Get ready for your \(workout.subtitle.lowercased()). This workout is great for all fitness levels and will help you stay in shape.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                showWorkoutScreen = true // ✅ هنا
            }) {
                Text("Start Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(14)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
        .navigationTitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showWorkoutScreen) {
            MainViewWrapper() // ✅ هنا يتم فتح شاشة MainViewController
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

