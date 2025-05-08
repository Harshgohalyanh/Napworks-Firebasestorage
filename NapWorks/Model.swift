//
//  Model.swift
//  NapWorks
//
//  Created by Harsh Gohalyan on 07/05/25.
//

import SwiftUI

struct FirebaseImage: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let timestamp: Int
}
