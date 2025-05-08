//
//  ContentView.swift
//  NapWorks
//
//  Created by Harsh Gohalyan on 07/05/25.
//



import SwiftUI
import PhotosUI
import FirebaseStorage

struct ContentView: View {
    
    @State private var selectedTab = 0
    @State private var selectedImage: UIImage?
    @State private var showImageSubmitPage = false
    @State private var submittedImages: [(UIImage, String)] = []
    @State private var imageName: String = ""
    
    @State private var selectedImageData: Data?
    @State private var isUploading = false
    @State private var uploadStatus: String = ""
    
    @State private var showingPhotoPicker = false
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        TabView(selection: $selectedTab) {
            
            uploadTab
                .tabItem {
                    Label("Upload", systemImage: "square.and.arrow.up")
                }
                .tag(0)
            
            ImageListView()
                .tabItem {
                    Label("Images", systemImage: "photo.on.rectangle")
                }
                .tag(1)
        }
        .edgesIgnoringSafeArea(.all)

        .shadow(radius: 10)
    }

    var uploadTab: some View {
        NavigationView {
            VStack {
                if showImageSubmitPage, let image = selectedImage {
                    selectedImageView(image: image)
                } else {
                    selectionButtons
                }
            }
            .navigationTitle("")
            .onChange(of: photoItem) { _ in
                loadPhoto()
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .onChange(of: uploadStatus) { _, newValue in
                if newValue.contains("Upload successful") {
                    imageName = ""
                    selectedTab = 1
                    showImageSubmitPage = false
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var selectionButtons: some View {
        VStack(spacing: 20) {
            VStack {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundColor(.green)
                    .padding()
                
                Button("Select from Gallery") {
                    showingPhotoPicker = true
                }
            }
            .foregroundColor(Color.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.green)
            )

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                Text("or")
                    .foregroundColor(.gray)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Button("Camera") {
                // TODO: Implement camera functionality
            }
            .foregroundColor(Color.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.green)
            )
        }
        .padding()
        .photosPicker(isPresented: $showingPhotoPicker, selection: $photoItem)
    }

    func selectedImageView(image: UIImage) -> some View {
        VStack {
            // Cross button
            HStack {
                Spacer()
                Button(action: {
                    // Return to previous page
                    showImageSubmitPage = false
                    selectedImage = nil
                    imageName = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .padding([.top, .trailing])
            }

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 450) // allows growth without extra padding
                .clipped()
                .padding(.horizontal)

            
            TextField("Enter image name", text: $imageName)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal)

            
            Button(isUploading ? "Uploading..." : "Submit") {
                let name = imageName.isEmpty ? "Unnamed Image" : imageName
                if let data = selectedImageData {
                    uploadImage(data: data, name: name)
                }
            }
            .disabled(isUploading)
            .buttonStyle(.borderedProminent)
            .tint(.green) // ✅ Set button color here
            .padding()

           
            
            Spacer()
        }
    }

    func loadPhoto() {
        guard let item = photoItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.selectedImage = image
                self.showImageSubmitPage = true
            }
        }
    }

    func uploadImage(data: Data, name: String) {
        isUploading = true
        uploadStatus = "Uploading..."
        
        let timestamp = Int(Date().timeIntervalSince1970)
            let fileName = "images/\(timestamp)_\(UUID().uuidString).jpg"
            let imageRef = Storage.storage().reference().child(fileName)

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            metadata.customMetadata = ["displayName":name,
                                       "timeStamp" : String(timestamp)
                                       ]
       
        imageRef.putData(data, metadata: metadata) { _, error in
            isUploading = false
            if let error = error {
                uploadStatus = "Upload failed: \(error.localizedDescription)"
                return
            }
            imageRef.downloadURL { url, error in
                if let url = url {
                    uploadStatus = "Upload successful! URL: \(url.absoluteString)"
                } else {
                    uploadStatus = "Uploaded but failed to get URL"
                }
            }
        }
    }
}





