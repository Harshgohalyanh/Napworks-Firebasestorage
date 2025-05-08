//
//  NapWorksApp.swift
//  NapWorks
//
//  Created by Harsh Gohalyan on 07/05/25.
//

import SwiftUI
import Firebase

@main
struct NapWorksApp: App {
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
            
        }
    }
}
