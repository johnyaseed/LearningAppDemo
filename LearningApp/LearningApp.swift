//
//  LearningAppApp.swift
//  LearningApp
//
//  Created by Christopher Ching on 2021-03-03.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct LearningApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
        }
    }
}
