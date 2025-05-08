//
//  View.swift
//  NapWorks
//
//  Created by Harsh Gohalyan on 07/05/25.
//

import SwiftUI

struct ImageListView: View {
    @StateObject private var viewModel = ImageListViewModel()

    // Two fixed columns with minimal spacing
    private let columns = [
        GridItem(.fixed(170), spacing: 10),
        GridItem(.fixed(170), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.images) { image in
                        VStack {
                            AsyncImage(url: image.url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 160)
                                        .clipped()
                                        .cornerRadius(10)
                                } else if phase.error != nil {
                                    Color.red
                                        .frame(width: 170, height: 160)
                                        .cornerRadius(10)
                                } else {
                                    ProgressView()
                                        .frame(width: 170, height: 160)
                                }
                            }

                            Text(image.name)
                                .font(.caption)
                                .lineLimit(1)
                                .padding(.top, 4)
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(2) // minimal item padding
                    }
                }
                .padding(10) // minimal grid padding
            }
            .navigationTitle("Uploaded Images")
            .onAppear {
                viewModel.fetchImages()
            }
        }
    }
}
