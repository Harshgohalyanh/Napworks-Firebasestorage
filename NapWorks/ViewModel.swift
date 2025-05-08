//
//  ViewModel.swift
//  NapWorks
//
//  Created by Harsh Gohalyan on 07/05/25.
//

import SwiftUI
import FirebaseStorage

class ImageListViewModel: ObservableObject {
    @Published var images: [FirebaseImage] = []

    func fetchImages() {
        
        let storageRef = Storage.storage().reference().child("images")

        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing images: \(error.localizedDescription)")
                return
            }

            var fetchedImages: [FirebaseImage] = []

            let dispatchGroup = DispatchGroup()

            for item in result?.items ?? []{
                dispatchGroup.enter()
                
                item.getMetadata { metadata, _ in
                    let displayName = metadata?.customMetadata?["displayName"] ?? item.name
                    let timestamp = Int(metadata?.customMetadata?["timestamp"] ?? "0") ?? 0
                
                    item.downloadURL { url, error in
                        if let url = url {
                            let image = FirebaseImage(name: displayName, url: url, timestamp: timestamp)
                            fetchedImages.append(image)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                fetchedImages = fetchedImages.sorted { $0.timestamp > $1.timestamp }
                self.images = fetchedImages
            }
        }
    }
}
