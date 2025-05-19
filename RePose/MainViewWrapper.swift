//
//  MainViewWrapper.swift
//  RePose
//
//  Created by mona alruthaya on 19/11/1446 AH.
//


import SwiftUI


struct MainViewWrapper: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

     func makeUIViewController(context: Context) -> UINavigationController {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController

         // اضيفي الكولباك
         vc.onDismiss = {
             dismiss()
         }

         return UINavigationController(rootViewController: vc)
         
         
     }


    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
