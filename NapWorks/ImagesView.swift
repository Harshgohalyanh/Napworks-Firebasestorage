//
//  ImagesView.swift
//  NapWorks
//
//  Created by Harsh Gohalyan on 07/05/25.
//


import SwiftUI
import FirebaseStorage

struct ImagesView: View {
    @State private var imageURLs: [URL] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(imageURLs, id: \.self) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 300)
                        case .failure:
                            Image(systemName: "xmark.octagon")
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchImageURLs()
        }
    }
    
    func fetchImageURLs() {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("images")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error)")
                return
            }
            
            guard let result = result else {
                print("No result returned from Firebase.")
                return
            }
            
            for item in result.items {
                print(item.name)
                item.downloadURL { (url, error) in
                    if let url = url {
                        DispatchQueue.main.async {
                            imageURLs.append(url)
                        }
                    } else {
                        print("Failed to get URL: \(error?.localizedDescription ?? "unknown error")")
                    }
                }
            }
        }
    }
}

