//
//  RePoseApp.swift
//  RePose
//
//  Created by mona alruthaya on 06/11/1446 AH.
//

import SwiftUI
import TipKit

@main
struct RePoseApp: App {
    
    init() {
        // تفعيل TipKit مرة واحدة عند تشغيل التطبيق
        if #available(iOS 17.0, *) {
            try? Tips.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
