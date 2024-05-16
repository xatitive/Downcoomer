//
//  ProfileDownloadView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import SwiftUI
import Combine
import Cocoa
import AppKit

struct ProfileDownloadView: View {
    @State private var creatorID: String = ""
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var offset = 0
    @State private var cancellables = Set<AnyCancellable>()
    @State private var selectedDirectory: URL? = nil
    @State private var showingDirectoryPicker = false
    
    var body: some View {
            VStack {
                TextField("Enter Creator ID", text: $creatorID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Select Download Directory") {
                    showingDirectoryPicker = true
                }
                .padding()
                
                if let selectedDirectory = selectedDirectory {
                    Text("Selected Directory: \(selectedDirectory.path)")
                        .padding()
                }
                
                Button("Fetch All Posts") {
                    fetchAllPosts()
                }
                .padding()
                
                if isLoading {
                    ProgressView("Loading posts...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else {
                    List(posts) { post in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(post.title!).font(.headline)
                                Text(post.service!).font(.subheadline)
                            }
                            Spacer()
                            Button("Download") {
                                downloadPostMedia(post: post)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Download Profile")
            .sheet(isPresented: $showingDirectoryPicker) {
                DirectoryPicker(selectedDirectory: $selectedDirectory)
            }
        }
    
    private func fetchAllPosts() {
        guard !creatorID.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        offset = 0
        posts.removeAll()
        
        fetchPosts()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }, receiveValue: { newPosts in
                posts.append(contentsOf: newPosts)
                if newPosts.count == 50 {
                    offset += 50
                    fetchAllPosts() // Fetch the next set of posts
                }
            })
            .store(in: &cancellables)
    }
    
    private func fetchPosts() -> AnyPublisher<[Post], Error> {
        let url = URL(string: "https://kemono.su/api/v1/onlyfans/user/\(creatorID)?o=\(offset)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func downloadPostMedia(post: Post) {
        guard let file = post.file, let selectedDirectory = selectedDirectory else { return }
        
        let fileURL = URL(string: "https://coomer.su\(file.path)")!
        
        let downloadTask = URLSession.shared.downloadTask(with: fileURL) { localURL, response, error in
            guard let localURL = localURL else {
                print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let destinationURL = selectedDirectory.appendingPathComponent(file.name!)
            
            do {
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                print("Downloaded to: \(destinationURL.path)")
            } catch {
                print("File move error: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }
}

struct ProfileDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDownloadView()
    }
}


struct DirectoryPicker: NSViewControllerRepresentable{
    func makeNSViewController(context: Context) -> NSViewController {
        return NSViewController()
    }
    
    @Binding var selectedDirectory: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Directory"
        
        panel.begin { response in
            if response == .OK {
                self.selectedDirectory = panel.url
            }
        }
    }

    class Coordinator: NSObject {
        var parent: DirectoryPicker

        init(_ parent: DirectoryPicker) {
            self.parent = parent
        }
    }
}
