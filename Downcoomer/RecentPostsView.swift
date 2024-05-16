//
//  RecentPostsView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import SwiftUI
import AVKit

struct RecentPostsView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(posts) { post in
                        VStack(alignment: .leading) {
                            Text(String(post.title!)).font(.headline)
                            Text(String(post.service!)).font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("Recent Posts")
        .onAppear {
            ApiService.shared.fetchRecentPosts() { result in
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
}

struct RecentPostsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentPostsView()
    }
}
