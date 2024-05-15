//
//  CreatorsPostView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import SwiftUI

struct CreatorPostsView: View {
    @State private var creatorID: String = ""
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            TextField("Enter Creator ID", text: $creatorID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Fetch Posts") {
                fetchPosts()
            }
            .padding()
            
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
                List(posts) { post in
                    VStack(alignment: .leading) {
                        Text(String(post.title!)).font(.headline)
                        Text(String(post.service!)).font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("User Specific Posts")
    }
    
    private func fetchPosts() {
        guard !creatorID.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        ApiService.shared.fetchCreatorPosts(service: "onlyfans", creatorID: creatorID) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
