//
//  CreatorsPostView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import SwiftUI
import AVKit

struct CreatorPostsView: View {
    @State private var creatorID: String = ""
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var offset = 0
    
    
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
                    NavigationStack{
                        VStack{
                            NavigationLink(destination: PostDetailView(post: post)) {
                                VStack(alignment: .leading) {
                                    Text(String(post.title!)).font(.headline)
                                    Text(String(post.content!)).font(.subheadline)
                                }
                            }
                        }
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

struct CreatorPostsView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorPostsView()
    }
}
