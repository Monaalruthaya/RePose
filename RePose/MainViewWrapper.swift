//
//  MainViewWrapper.swift
//  RePose
//
//  Created by mona alruthaya on 19/11/1446 AH.
//


import SwiftUI

// ✅ هذا الملف يربط SwiftUI مع MainViewController من UIKit
struct MainViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
    }

    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
        // ما نحتاج نحدث شي هنا الآن
    }
}
