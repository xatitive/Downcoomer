//
//  PostDetailVie.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import AVKit
import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(post.title!)
                    .font(.largeTitle)
                    .padding(.top)
                
                if let content = post.content {
                    Text(content)
                        .padding(.horizontal)
                }
                
                if let fileDetails = post.file, ((fileDetails.name?.hasSuffix(".mp4")) != nil) {
                    VideoPlayerView(videoURL: "https://coomer.su\(String( fileDetails.path!))")
                        .padding()
                }
                
                if let attachments = post.attachments {
                    ForEach(attachments) { attachment in
                        if attachment.name.hasSuffix(".jpg") || attachment.name.hasSuffix(".png") {
                            RemoteImageView(url: URL(string: "https://coomer.su\(attachment.path)"))
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("Post Details")
    }
}

struct VideoPlayerView: View {
    let videoURL: String
    @State var player = AVPlayer()
    
    var body: some View {
        let player=AVPlayer(url: URL(string: videoURL)!)
        
        VideoPlayer(player: AVPlayer(url: URL(string: videoURL)!))
            .frame(height: 540)
            .cornerRadius(10)
            .scaledToFit()
            .onAppear(){
                player.play()
            }
    }
}


struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: Post(id: "78277999" ,user:"beefybull" ,service: "onlyfans"))
    }
}

